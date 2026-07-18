//
//  WaveShape.swift
//  Medsy
//
//  Created by Shahudaa on 17/07/2026.
//

import SwiftUI


struct WaveShape: Shape {
    var amplitude: CGFloat = 24
    var verticalOffset: CGFloat = 0.62

    func path(in rect: CGRect) -> Path {
        let baseY = rect.height * verticalOffset
        var path = Path()
        path.move(to: CGPoint(x: 0, y: baseY))
        path.addCurve(
            to: CGPoint(x: rect.width, y: baseY - amplitude * 0.4),
            control1: CGPoint(x: rect.width * 0.32, y: baseY - amplitude),
            control2: CGPoint(x: rect.width * 0.68, y: baseY + amplitude)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
