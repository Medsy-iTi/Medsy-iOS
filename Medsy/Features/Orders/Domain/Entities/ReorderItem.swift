//
//  ReorderItem.swift
//  Medsy
//
//  Created by Shahudaa on 25/07/2026.
//


import Foundation


struct ReorderItem {
    let productId: Int
    let quantity: Int
}


enum ReorderResult: Equatable {

    case success
    case partial(added: Int, total: Int)
    case failure
}
