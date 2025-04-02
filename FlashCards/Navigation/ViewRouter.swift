//
//  ViewRouter.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 2.04.25.
//

import Foundation

class ViewRouter: ObservableObject {
    @Published var currentPage: PageModel = .mainView
}
