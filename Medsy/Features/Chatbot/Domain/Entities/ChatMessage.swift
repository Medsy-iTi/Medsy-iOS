//
//  MessageSender.swift
//  Medsy
//
//  Created by ITI_JETS on 23/07/2026.
//



import Foundation


struct ChatMessage: Identifiable, Sendable {
    let id: String
    let text: String
    let sender: MessageSender
    let timestamp: Date
    let customCard: CustomCardType
}



