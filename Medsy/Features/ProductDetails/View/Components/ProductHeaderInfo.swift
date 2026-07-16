//
//  ProductHeaderInfo.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import SwiftUI

struct ProductHeaderInfo: View {
    let title: String
    let subtitle: String
    let price: Double
    let currencyKey: String

    @Environment(LanguageManager.self) private var languageManager
    @ObservedObject private var appSettings = AppSettings.shared

    var body: some View {
        
        VStack(alignment: .leading, spacing: MedsySpacing.xxs) {
            Text(title)
                .font(MedsyFont.title(20))
                .foregroundStyle(AppColor.textPrim)
                .multilineTextAlignment(.leading)

            Text(subtitle)
                .font(MedsyFont.body(14))
                .foregroundStyle(AppColor.textSec)
                .multilineTextAlignment(.leading)

            Text("product.price_format".localized(price.formatted(), currencyKey.localized))
                .font(MedsyFont.price(20))
                .foregroundStyle(AppColor.green)
                .padding(.top, MedsySpacing.xxs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
