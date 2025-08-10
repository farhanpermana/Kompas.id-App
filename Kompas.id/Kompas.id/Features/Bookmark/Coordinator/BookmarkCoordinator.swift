//
//  BookmarkCoordinator.swift
//  Kompas.id
//
//  Created by Farhan on 07/08/25.
//  

import Foundation

struct BookmarkCoordinator {
    static func createBookmarkViewController() -> BookmarkViewController {
        let controller = BookmarkViewController()
        controller.viewModel = BookmarkViewModel()
        controller.coordinator = BookmarkCoordinator()
        return controller
    }
}
