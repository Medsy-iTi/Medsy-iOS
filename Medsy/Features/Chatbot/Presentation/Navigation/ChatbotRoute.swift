//
//  ChatbotRoute.swift
//  Medsy
//

enum ChatbotRoute: Hashable {
    case chatDetail
    case medicineDetails(medicineId: String)
    case pharmacyMap
    case category(id: Int, name: String)
    case completeRequest([AIChatProduct])
}
