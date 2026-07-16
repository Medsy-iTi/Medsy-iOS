//
//  ProfileRowItem.swift
//  Medsy
//
//  Created by Ahmed Elkady on 15/07/2026.
//

import SwiftUI

struct ProfileRowItem: Identifiable {
    let id: String
    let titleKey: String
    let subtitleKey: String?
    let iconName: String
    let iconColor: Color
    let trailingTextKey: String?
    let isEnabled: Bool

    init(
        id: String,
        titleKey: String,
        subtitleKey: String? = nil,
        iconName: String,
        iconColor: Color,
        trailingTextKey: String? = nil,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.iconName = iconName
        self.iconColor = iconColor
        self.trailingTextKey = trailingTextKey
        self.isEnabled = isEnabled
    }
}
