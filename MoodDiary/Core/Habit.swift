//
//  Habit.swift
//  MoodDiary
//
//  Created by Anton Danilov on 28/1/26.
//


import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var icon: String
    var color: String
    var createdDate: Date
    var currentStreak: Int
    var bestStreak: Int
    var completionDates: [Date]
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        color: String,
        createdDate: Date = Date(),
        currentStreak: Int = 0,
        bestStreak: Int = 0,
        completionDates: [Date] = [],
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.createdDate = createdDate
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.completionDates = completionDates
        self.isActive = isActive
    }
}

struct PermissionModel {
    var status: PermissionStatus
    var lastAsked: Date?
    
    enum PermissionStatus {
        case notDetermined
        case granted
        case denied
    }
    
    var canAsk: Bool {
        guard status == .notDetermined else { return false }
        
        if let last = lastAsked {
            let days = Date().timeIntervalSince(last) / 86400
            return days >= 3
        }
        return true
    }
    
    static var initial: PermissionModel {
        PermissionModel(status: .notDetermined, lastAsked: nil)
    }
}

// UNIQUE: Launch Configuration
struct LaunchConfig {
    var isFirstLaunch: Bool
    var savedEndpoint: String?
    var operationMode: String?
    
    static var initial: LaunchConfig {
        LaunchConfig(isFirstLaunch: true, savedEndpoint: nil, operationMode: nil)
    }
}
