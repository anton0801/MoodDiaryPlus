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
