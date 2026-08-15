//
//  AIChatContractMapper.swift
//  Medsy
//

import Foundation

enum AIChatContractMapper {
    static func map(_ dto: AIChatMessageResponseDTO) -> AIChatAssistantResponse {
        AIChatAssistantResponse(
            conversationID: dto.conversationId,
            messageID: dto.messageId,
            intent: mapIntent(dto.intent),
            answer: dto.answer,
            products: (dto.products ?? []).compactMap(mapProduct),
            alternatives: (dto.alternatives ?? []).compactMap(mapProduct),
            doctorSpecializations: dto.doctorSpecializations ?? [],
            emergencyNumbers: (dto.emergencyNumbers ?? []).compactMap(mapEmergencyNumber),
            categories: (dto.categories ?? []).compactMap(mapCategory),
            pharmacistRankings: (dto.pharmacistRankings ?? []).compactMap(mapRanking),
            disclaimer: dto.disclaimer,
            action: mapAction(dto.action),
            reminder: mapReminder(dto.reminder),
            analytics: mapAnalytics(dto.analytics)
        )
    }

    static func map(_ dto: AIChatHistoryResponseDTO) -> AIChatHistory {
        AIChatHistory(
            conversationID: dto.conversationId,
            messages: (dto.messages ?? []).map(mapHistoryMessage)
        )
    }

    static func map(_ dto: AIChatCartInteractionsResponseDTO) -> [AIChatInteractionWarning] {
        (dto.warnings ?? []).compactMap(mapInteractionWarning)
    }

    private static func mapHistoryMessage(_ dto: AIChatHistoryMessageDTO) -> AIChatHistoryMessage {
        AIChatHistoryMessage(
            id: dto.id,
            role: mapRole(dto.role),
            content: strippingImageMarker(from: dto.content),
            intent: dto.intent.map(mapIntent),
            products: (dto.products ?? []).compactMap(mapProduct),
            alternatives: (dto.alternatives ?? []).compactMap(mapProduct),
            doctorSpecializations: dto.doctorSpecializations ?? [],
            emergencyNumbers: (dto.emergencyNumbers ?? []).compactMap(mapEmergencyNumber),
            categories: (dto.categories ?? []).compactMap(mapCategory),
            pharmacistRankings: (dto.pharmacistRankings ?? []).compactMap(mapRanking),
            analytics: mapAnalytics(dto.analytics),
            createdAt: parseDate(dto.createdAt)
        )
    }

    private static func mapIntent(_ value: String) -> AIChatIntent {
        switch value.uppercased() {
        case "GREETING": return .greeting
        case "MEDICINE_REQUEST": return .medicineRequest
        case "SYMPTOM_ADVICE": return .symptomAdvice
        case "DOCTOR_SPECIALIZATION": return .doctorSpecialization
        case "EMERGENCY": return .emergency
        case "MEDICINE_USAGE": return .medicineUsage
        case "CATEGORY_BROWSE": return .categoryBrowse
        case "ADD_TO_CART": return .addToCart
        case "CREATE_REQUEST": return .createRequest
        case "SET_REMINDER": return .setReminder
        // DELETE_REMINDER / LIST_REMINDERS removed — backend no longer sends them
        case "PHARMACIST_PERFORMANCE": return .pharmacistPerformance
        case "PHARMACY_ANALYTICS": return .pharmacyAnalytics
        default: return .other
        }
    }

    private static func mapRole(_ value: String) -> AIChatMessageRole {
        switch value.uppercased() {
        case "USER": return .user
        case "ASSISTANT": return .assistant
        default: return .unknown(value)
        }
    }

    private static func mapProduct(_ dto: AIChatProductDTO) -> AIChatProduct? {
        guard let id = dto.id,
              let name = dto.name,
              let price = dto.price else {
            return nil
        }
        return AIChatProduct(
            id: id,
            name: name,
            productName: dto.productName,
            strength: dto.strength,
            packSize: dto.packSize,
            form: dto.form,
            price: price,
            scientificName: dto.scientificName,
            scientificCategory: dto.scientificCategory,
            categoryID: dto.categoryId,
            consumerCategory: dto.consumerCategory,
            company: dto.company,
            route: dto.route,
            description: dto.description,
            imageURL: dto.imageUrl
        )
    }

    private static func mapEmergencyNumber(_ dto: AIChatEmergencyNumberDTO) -> AIChatEmergencyNumber? {
        guard let rawService = dto.service,
              let number = dto.number else {
            return nil
        }
        let service: AIChatEmergencyNumber.Service
        switch rawService.uppercased() {
        case "AMBULANCE": service = .ambulance
        case "POLICE": service = .police
        case "FIRE": service = .fire
        default: return nil
        }
        return AIChatEmergencyNumber(service: service, number: number)
    }

    private static func mapCategory(_ dto: AIChatCategoryDTO) -> AIChatCategory? {
        guard let id = dto.id,
              let name = dto.name else {
            return nil
        }
        return AIChatCategory(id: id, name: name)
    }

    private static func mapAction(_ dto: AIChatActionDTO?) -> AIChatAction? {
        guard let dto,
              let rawType = dto.type else {
            return nil
        }
        let type: AIChatAction.ActionType
        switch rawType.uppercased() {
        case "ADDED_TO_CART": type = .addedToCart
        case "CREATE_REQUEST": type = .createRequest
        default: return nil
        }
        return AIChatAction(
            type: type,
            addedProductIDs: dto.addedProductIds ?? [],
            quantity: dto.quantity,
            cartItemCount: dto.cartItemCount
        )
    }

    private static func mapRanking(_ dto: AIChatPharmacistRankingDTO) -> AIChatPharmacistRanking? {
        guard let rawMetric = dto.metric,
              let rawPeriod = dto.period else {
            return nil
        }
        return AIChatPharmacistRanking(
            metric: mapPerformanceMetric(rawMetric),
            period: mapPerformancePeriod(rawPeriod),
            direction: mapPerformanceDirection(dto.direction),
            entries: (dto.entries ?? []).compactMap(mapPerformanceEntry)
        )
    }

    private static func mapPerformanceMetric(_ value: String) -> AIChatPerformanceMetric {
        switch value.uppercased() {
        case "OFFERS_CREATED": return .offersCreated
        case "SUCCESSFUL_ORDERS": return .successfulOrders
        default: return .unknown(value)
        }
    }

    private static func mapPerformancePeriod(_ value: String) -> AIChatPerformancePeriod {
        switch value.uppercased() {
        case "LAST_DAY": return .lastDay
        case "LAST_WEEK": return .lastWeek
        case "LAST_MONTH": return .lastMonth
        case "LAST_YEAR": return .lastYear
        default: return .unknown(value)
        }
    }

    private static func mapPerformanceDirection(
        _ value: String?
    ) -> AIChatPerformanceDirection {
        guard let value else { return .top }
        switch value.uppercased() {
        case "TOP": return .top
        case "BOTTOM": return .bottom
        default: return .unknown(value)
        }
    }

    private static func mapPerformanceEntry(
        _ dto: AIChatPharmacistPerformanceEntryDTO
    ) -> AIChatPharmacistPerformanceEntry? {
        guard let rank = dto.rank,
              let pharmacistID = dto.pharmacistId,
              let firstName = dto.firstName,
              let lastName = dto.lastName,
              let count = dto.count else {
            return nil
        }
        return AIChatPharmacistPerformanceEntry(
            rank: rank,
            pharmacistID: pharmacistID,
            firstName: firstName,
            lastName: lastName,
            count: count
        )
    }

    private static func mapInteractionWarning(
        _ dto: AIChatInteractionWarningDTO
    ) -> AIChatInteractionWarning? {
        guard let title = dto.title,
              let advice = dto.advice else {
            return nil
        }
        let severity: AIChatInteractionSeverity = dto.severity?.uppercased() == "HIGH"
            ? .high
            : .moderate
        return AIChatInteractionWarning(
            severity: severity,
            title: title,
            advice: advice,
            involvedProducts: (dto.involvedProducts ?? []).compactMap(mapInteractionProduct)
        )
    }

    private static func mapInteractionProduct(
        _ dto: AIChatInteractionProductDTO
    ) -> AIChatInteractionProduct? {
        guard let productID = dto.productId,
              let productName = dto.productName else {
            return nil
        }
        return AIChatInteractionProduct(
            productID: productID,
            productName: productName,
            ingredient: dto.ingredient
        )
    }

    private static func strippingImageMarker(from content: String) -> String {
        content
            .replacingOccurrences(
                of: #"\n?\[image\][^\n]*"#,
                with: "",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: value) {
            return date
        }

        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: value) {
            return date
        }

        let localFormatter = DateFormatter()
        localFormatter.locale = Locale(identifier: "en_US_POSIX")
        localFormatter.calendar = Calendar(identifier: .gregorian)
        localFormatter.timeZone = TimeZone(identifier: "Africa/Cairo")

        if let fractionalSeparator = value.firstIndex(of: ".") {
            let seconds = String(value[..<fractionalSeparator])
            let fractionStart = value.index(after: fractionalSeparator)
            let fraction = value[fractionStart...].prefix(3)
            let milliseconds = String(fraction)
                + String(repeating: "0", count: max(0, 3 - fraction.count))
            localFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            return localFormatter.date(from: seconds + "." + milliseconds)
        }

        localFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return localFormatter.date(from: value)
    }
    private static func mapReminder(_ dto: AIChatReminderDTO?) -> AIChatReminder? {
        guard let dto,
              let medicineName = dto.medicineName, !medicineName.isEmpty,
              let times = dto.times, !times.isEmpty,
              let durationDays = dto.durationDays, durationDays > 0 else {
            return nil
        }
        return AIChatReminder(
            medicineName: medicineName,
            times: times,
            durationDays: durationDays
        )
    }
    
    private static func mapAnalytics(_ dto: AIChatAnalyticsDTO?) -> AIChatAnalytics? {
        guard let dto = dto,
              let schemaVersion = dto.schemaVersion,
              let scope = dto.scope,
              let period = dto.period else {
            return nil
        }
        return AIChatAnalytics(
            schemaVersion: schemaVersion,
            scope: scope,
            period: period,
            start: parseDate(dto.start),
            end: parseDate(dto.end),
            metrics: (dto.metrics ?? []).compactMap(mapAnalyticsMetric),
            breakdowns: (dto.breakdowns ?? []).compactMap(mapAnalyticsBreakdown),
            rankings: (dto.rankings ?? []).compactMap(mapPerformanceEntry),
            orderHighlights: (dto.orderHighlights ?? []).compactMap(mapAnalyticsOrderHighlight),
            topProducts: (dto.topProducts ?? []).compactMap(mapAnalyticsTopProduct)
        )
    }
    
    private static func mapAnalyticsMetric(_ dto: AIChatAnalyticsMetricDTO) -> AIChatAnalyticsMetric? {
        guard let key = dto.key, let value = dto.value, let unit = dto.unit else {
            return nil
        }
        return AIChatAnalyticsMetric(
            key: key,
            value: value,
            unit: unit,
            previousValue: dto.previousValue,
            deltaPercent: dto.deltaPercent
        )
    }
    
    private static func mapAnalyticsBreakdown(_ dto: AIChatAnalyticsBreakdownDTO) -> AIChatAnalyticsBreakdown? {
        guard let group = dto.group, let key = dto.key, let count = dto.count else {
            return nil
        }
        return AIChatAnalyticsBreakdown(group: group, key: key, count: count)
    }
    
    private static func mapAnalyticsOrderHighlight(_ dto: AIChatAnalyticsOrderHighlightDTO) -> AIChatAnalyticsOrderHighlight? {
        guard let orderId = dto.orderId, let status = dto.status, let totalPrice = dto.totalPrice else {
            return nil
        }
        return AIChatAnalyticsOrderHighlight(
            orderId: orderId,
            status: status,
            totalPrice: totalPrice,
            date: parseDate(dto.date)
        )
    }
    
    private static func mapAnalyticsTopProduct(_ dto: AIChatAnalyticsTopProductDTO) -> AIChatAnalyticsTopProduct? {
        guard let productId = dto.productId,
              let productName = dto.productName,
              let quantity = dto.quantity,
              let orderCount = dto.orderCount,
              let revenue = dto.revenue else {
            return nil
        }
        return AIChatAnalyticsTopProduct(
            productId: productId,
            productName: productName,
            quantity: quantity,
            orderCount: orderCount,
            revenue: revenue
        )
    }
}
