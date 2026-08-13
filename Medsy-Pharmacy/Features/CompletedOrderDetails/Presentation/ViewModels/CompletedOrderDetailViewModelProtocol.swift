//
//  CompletedOrderDetailViewModelProtocol.swift
//  Medsy
//

import Foundation


enum CompletedOrderDetailViewState {
    case loading
    case loaded(CompletedOrderDetailPresentationModel)
    case error(String)
    case notFound
}



enum CompletedOrderDetailEvent {
    case load(orderId: Int)
    case retry(orderId: Int)
    case markReady(orderId: Int)
}



@MainActor
protocol CompletedOrderDetailViewModelProtocol: AnyObject {
    var viewState: CompletedOrderDetailViewState { get }
    var isMarkingReady: Bool { get }
    var markReadyError: String? { get }
    func handle(_ event: CompletedOrderDetailEvent)
}
