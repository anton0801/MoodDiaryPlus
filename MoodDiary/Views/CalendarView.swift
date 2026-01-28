import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CalendarViewModel()
    @AppStorage("currentThemeColor") private var themeColor = "#4ECDC4"
    @Query private var allEntries: [MoodEntry]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(hex: themeColor).opacity(0.2),
                        Color(hex: "1a1a2e").opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Month selector
                        monthSelector
                        
                        // Calendar grid
                        calendarGrid
                        
                        // Entries list
                        entriesList
                    }
                    .padding()
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $viewModel.selectedEntry) { entry in
                EntryDetailView(entry: entry)
            }
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button(action: {
                withAnimation {
                    viewModel.currentMonth = Calendar.current.date(
                        byAdding: .month,
                        value: -1,
                        to: viewModel.currentMonth
                    ) ?? viewModel.currentMonth
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            
            Spacer()
            
            Text(viewModel.currentMonth.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    viewModel.currentMonth = Calendar.current.date(
                        byAdding: .month,
                        value: 1,
                        to: viewModel.currentMonth
                    ) ?? viewModel.currentMonth
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(.ultraThinMaterial))
            }
        }
    }
    
    private var calendarGrid: some View {
        VStack(spacing: 15) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            entry: getEntry(for: date),
                            isCurrentMonth: Calendar.current.isDate(date, equalTo: viewModel.currentMonth, toGranularity: .month),
                            isToday: Calendar.current.isDateInToday(date)
                        ) {
                            if let entry = getEntry(for: date) {
                                viewModel.selectedEntry = entry
                                viewModel.showEntryDetail = true
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 60)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var entriesList: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Entries")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            if filteredEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("No entries this month")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
            } else {
                ForEach(filteredEntries.prefix(10)) { entry in
                    EntryRow(entry: entry) {
                        viewModel.selectedEntry = entry
                        viewModel.showEntryDetail = true
                    }
                }
            }
        }
    }
    
    private var filteredEntries: [MoodEntry] {
        allEntries.filter { entry in
            Calendar.current.isDate(entry.date, equalTo: viewModel.currentMonth, toGranularity: .month)
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .month, for: viewModel.currentMonth)!
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let daysInMonth = calendar.range(of: .day, in: .month, for: viewModel.currentMonth)!.count
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(bySetting: .day, value: day, of: viewModel.currentMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func getEntry(for date: Date) -> MoodEntry? {
        allEntries.first { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: date)
        }
    }
}

struct DayCell: View {
    let date: Date
    let entry: MoodEntry?
    let isCurrentMonth: Bool
    let isToday: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: isToday ? .bold : .medium, design: .rounded))
                    .foregroundColor(isCurrentMonth ? .white : .white.opacity(0.3))
                
                if let entry = entry {
                    Text(entry.moodEmoji)
                        .font(.system(size: 16))
                } else {
                    Circle()
                        .fill(.clear)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isToday ? Color.white : Color.clear, lineWidth: 2)
            )
        }
        .disabled(entry == nil)
    }
    
    private var backgroundColor: Color {
        if let entry = entry {
            return Color(hex: entry.colorTheme).opacity(0.3)
        } else {
            return Color.white.opacity(0.3)
        }
    }
}

struct EntryRow: View {
    let entry: MoodEntry
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Photo thumbnail
                if let photoData = entry.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: entry.colorTheme), lineWidth: 2)
                        )
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(entry.moodEmoji)
                            .font(.system(size: 24))
                        
                        Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    if !entry.note.isEmpty {
                        Text(entry.note)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                    }
                    
                    if !entry.selectedActivities.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(entry.selectedActivities, id: \.self) { activity in
                                    Text(activity)
                                        .font(.system(size: 10, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color(hex: entry.colorTheme).opacity(0.3))
                                        )
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct EntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let entry: MoodEntry
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: entry.colorTheme).opacity(0.3),
                        Color(hex: "1a1a2e").opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Photo
                        if let photoData = entry.photoData,
                           let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 300, maxHeight: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color(hex: entry.colorTheme), lineWidth: 4)
                                )
                        }
                        
                        // Mood info
                        VStack(spacing: 15) {
                            HStack {
                                Text(entry.moodEmoji)
                                    .font(.system(size: 60))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Mood Score")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text("\(entry.moodScore)/10")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Date")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text(entry.date.formatted(date: .complete, time: .shortened))
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        )
                        
                        // Note
                        if !entry.note.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Note")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text(entry.note)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                        
                        // Activities
                        if !entry.selectedActivities.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Activities")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                FlowLayout(spacing: 10) {
                                    ForEach(entry.selectedActivities, id: \.self) { activity in
                                        Text(activity)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(Color(hex: entry.colorTheme).opacity(0.4))
                                            )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Entry Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: entry.colorTheme))
                }
            }
        }
    }
}
