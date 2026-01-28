//
//  ConfettiView.swift
//  MoodDiary
//
//  Created by Anton Danilov on 28/1/26.
//


import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50) { index in
                ConfettiPiece(index: index)
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    let index: Int
    @State private var yOffset: CGFloat = -100
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .pink, .purple]
    
    var body: some View {
        let color = colors[index % colors.count]
        let size = CGFloat.random(in: 8...15)
        
        RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .frame(width: size, height: size * 1.5)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                let startX = CGFloat.random(in: -UIScreen.main.bounds.width/2...UIScreen.main.bounds.width/2)
                let endX = startX + CGFloat.random(in: -100...100)
                let endY = UIScreen.main.bounds.height + 100
                let duration = Double.random(in: 2...4)
                
                xOffset = startX
                
                withAnimation(.easeOut(duration: duration)) {
                    yOffset = endY
                    xOffset = endX
                    rotation = Double.random(in: -720...720)
                }
                
                withAnimation(.easeIn(duration: duration * 0.7).delay(duration * 0.3)) {
                    opacity = 0
                }
            }
    }
}
