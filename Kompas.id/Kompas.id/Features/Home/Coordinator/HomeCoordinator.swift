//
//  HomeCoordinator.swift
//  Kompas.id
//
//  Created by Farhan on 03/08/25.
//  

import UIKit

struct HomeCoordinator {
    static func createHomeViewController() -> HomeViewController {
        let controller = HomeViewController()
        controller.viewModel = HomeViewModel()
        controller.coordinator = HomeCoordinator()
        return controller
    }
    
    func openArticleDetail(from vc: UIViewController, article: GenericArticle) {
        let detail = ArticleDetailViewController(article: article)
        detail.hidesBottomBarWhenPushed = true
        vc.navigationController?.pushViewController(detail, animated: true)
    }
}
