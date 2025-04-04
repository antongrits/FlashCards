//
//  CardEventPublisher.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 4.04.25.
//

import Combine

struct CardEventPublisher {
    static let shared = CardEventPublisher()
    let cardAdded = CurrentValueSubject<Bool, Never>(false)
}
