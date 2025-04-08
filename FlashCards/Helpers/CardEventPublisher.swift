//
//  CardEventPublisher.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 4.04.25.
//

import Combine
import Foundation

struct CardEventPublisher {
    static let shared = CardEventPublisher()
    let cardAdded = CurrentValueSubject<CardModel?, Never>(nil)
}
