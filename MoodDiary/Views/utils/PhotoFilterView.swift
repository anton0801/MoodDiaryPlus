import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct PhotoFilterView: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage
    let onSave: (UIImage) -> Void
    
    @State private var brightness: Double = 0
    @State private var contrast: Double = 1
    @State private var saturation: Double = 1
    @State private var filteredImage: UIImage?
    
    let context = CIContext()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1a1a2e")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Image preview
                    if let filtered = filteredImage {
                        Image(uiImage: filtered)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 400)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    // Filters
                    VStack(spacing: 20) {
                        FilterSlider(
                            title: "Brightness",
                            value: $brightness,
                            range: -0.5...0.5,
                            icon: "sun.max.fill"
                        )
                        
                        FilterSlider(
                            title: "Contrast",
                            value: $contrast,
                            range: 0.5...1.5,
                            icon: "circle.lefthalf.filled"
                        )
                        
                        FilterSlider(
                            title: "Saturation",
                            value: $saturation,
                            range: 0...2,
                            icon: "paintpalette.fill"
                        )
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let filtered = filteredImage {
                            onSave(filtered)
                        }
                        dismiss()
                    }
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                applyFilters()
            }
            .onChange(of: brightness) { _ in applyFilters() }
            .onChange(of: contrast) { _ in applyFilters() }
            .onChange(of: saturation) { _ in applyFilters() }
        }
    }
    
    private func applyFilters() {
        guard let ciImage = CIImage(image: image) else { return }
        
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.brightness = Float(brightness)
        filter.contrast = Float(contrast)
        filter.saturation = Float(saturation)
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return
        }
        
        filteredImage = UIImage(cgImage: cgImage)
    }
}

struct FilterSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: "%.2f", value))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Slider(value: $value, in: range)
                .tint(.white)
        }
    }
}
