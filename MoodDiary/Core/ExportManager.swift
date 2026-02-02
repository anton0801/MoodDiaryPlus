import UIKit
import PDFKit

class ExportManager {
    static let shared = ExportManager()
    
    private init() {}
    
    // MARK: - Single Entry PDF Export
    func exportEntryToPDF(entry: MoodEntry) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "MoodDiary",
            kCGPDFContextAuthor: "MoodDiary User",
            kCGPDFContextTitle: "Mood Entry - \(entry.date.formatted(date: .abbreviated, time: .omitted))"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.white.withAlphaComponent(0.9)
            ]
            
            let labelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.7)
            ]
            
            // Background gradient
            if let cgContext = UIGraphicsGetCurrentContext() {
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let colors = [
                    UIColor(hexString: entry.colorTheme).withAlphaComponent(0.3).cgColor,
                    UIColor(hexString: "1a1a2e").cgColor
                ]
                if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 1]) {
                    cgContext.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: pageRect.height), options: [])
                }
            }
            
            var yPosition: CGFloat = 50
            
            // Title
            let title = "MoodDiary Entry"
            title.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
            yPosition += 50
            
            // Date
            "Date".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: labelAttributes)
            yPosition += 25
            entry.date.formatted(date: .complete, time: .shortened).draw(at: CGPoint(x: 50, y: yPosition), withAttributes: bodyAttributes)
            yPosition += 40
            
            // Mood
            "Mood".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: labelAttributes)
            yPosition += 25
            "\(entry.moodEmoji) \(entry.moodScore)/10".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: bodyAttributes)
            yPosition += 40
            
            // Photo
            if let photoData = entry.photoData, let image = UIImage(data: photoData) {
                "Photo".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: labelAttributes)
                yPosition += 25
                
                let imageSize = CGSize(width: 300, height: 300)
                let imageRect = CGRect(x: 50, y: yPosition, width: imageSize.width, height: imageSize.height)
                image.draw(in: imageRect)
                yPosition += imageSize.height + 40
            }
            
            // Note
            if !entry.note.isEmpty {
                "Note".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: labelAttributes)
                yPosition += 25
                
                let noteRect = CGRect(x: 50, y: yPosition, width: pageRect.width - 100, height: pageRect.height - yPosition - 50)
                entry.note.draw(in: noteRect, withAttributes: bodyAttributes)
                yPosition += 100
            }
            
            // Activities
            if !entry.selectedActivities.isEmpty {
                if yPosition < pageRect.height - 100 {
                    "Activities".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: labelAttributes)
                    yPosition += 25
                    entry.selectedActivities.joined(separator: ", ").draw(at: CGPoint(x: 50, y: yPosition), withAttributes: bodyAttributes)
                }
            }
            
            // Footer
            let footer = "Created with MoodDiary"
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]
            footer.draw(at: CGPoint(x: 50, y: pageRect.height - 40), withAttributes: footerAttributes)
        }
        
        // Save to temporary directory
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("MoodEntry_\(entry.id).pdf")
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Error saving PDF: \(error)")
            return nil
        }
    }
    
    // MARK: - Instagram Story Export
    func createInstagramStory(entry: MoodEntry) -> UIImage? {
        let size = CGSize(width: 1080, height: 1920)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background gradient
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor(hexString: entry.colorTheme).withAlphaComponent(0.8).cgColor,
                UIColor(hexString: entry.colorTheme).withAlphaComponent(0.4).cgColor
            ]
            
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 1]) {
                context.cgContext.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size.height), options: [])
            }
            
            // Photo
            if let photoData = entry.photoData, let photo = UIImage(data: photoData) {
                let photoSize = CGSize(width: 900, height: 900)
                let photoRect = CGRect(
                    x: (size.width - photoSize.width) / 2,
                    y: 300,
                    width: photoSize.width,
                    height: photoSize.height
                )
                
                // Draw rounded rectangle background
                let path = UIBezierPath(roundedRect: photoRect.insetBy(dx: -20, dy: -20), cornerRadius: 40)
                UIColor.white.setFill()
                path.fill()
                
                // Draw photo
                let imagePath = UIBezierPath(roundedRect: photoRect, cornerRadius: 30)
                imagePath.addClip()
                photo.draw(in: photoRect)
            }
            
            // Mood emoji
            let emojiSize: CGFloat = 120
            let emojiAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: emojiSize)
            ]
            let emojiString = entry.moodEmoji as NSString
            let emojiRect = CGRect(x: (size.width - emojiSize) / 2, y: 150, width: emojiSize, height: emojiSize)
            emojiString.draw(in: emojiRect, withAttributes: emojiAttributes)
            
            // Date
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let dateString = entry.date.formatted(date: .abbreviated, time: .omitted) as NSString
            let dateSize = dateString.size(withAttributes: dateAttributes)
            dateString.draw(at: CGPoint(x: (size.width - dateSize.width) / 2, y: 1300), withAttributes: dateAttributes)
            
            // Mood score
            let scoreAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48, weight: .heavy),
                .foregroundColor: UIColor.white
            ]
            let scoreString = "\(entry.moodScore)/10" as NSString
            let scoreSize = scoreString.size(withAttributes: scoreAttributes)
            scoreString.draw(at: CGPoint(x: (size.width - scoreSize.width) / 2, y: 1360), withAttributes: scoreAttributes)
            
            // Watermark (only for free version)
            let isPremium = UserDefaults.standard.bool(forKey: "isPremium")
            if !isPremium {
                let watermarkAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 24, weight: .medium),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.6)
                ]
                let watermark = "MoodDiary" as NSString
                let watermarkSize = watermark.size(withAttributes: watermarkAttributes)
                watermark.draw(at: CGPoint(x: (size.width - watermarkSize.width) / 2, y: size.height - 100), withAttributes: watermarkAttributes)
            }
        }
    }
}

// MARK: - UIColor Extension для hex
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
