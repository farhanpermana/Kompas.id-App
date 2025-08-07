//
//  MainTabController.swift
//  Kompas.id
//
//  Created by Farhan on 03/08/25.
//

import UIKit
import SnapKit

class MainTabController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabs()
        self.setupCustomNavigationBar()
    }
    
    private func setupCustomNavigationBar() {
        let statusBarView = UIView()
        statusBarView.backgroundColor = UIColor.fromHex("#00559a")
        view.addSubview(statusBarView)
        
        statusBarView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        let navBar = UINavigationBar()
        navBar.barTintColor = UIColor.fromHex("#00559a")
        navBar.isTranslucent = false
        navBar.tintColor = .white
        
        view.addSubview(navBar)
        
        navBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        let hamburgerButton = UIBarButtonItem(image: UIImage(systemName: "list.dash"), style: .plain, target: self, action: #selector(hamburgerTapped))
        let searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchTapped))
        
        let logoImageView = UIImageView(image: UIImage(named: "kompaslogo"))
        logoImageView.contentMode = .scaleAspectFit
        
        let logoView = UIView()
        logoView.addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        
        let navigationItem = UINavigationItem(title: "")
        navigationItem.leftBarButtonItems = [hamburgerButton, searchButton]
        navigationItem.titleView = logoView
        
        let notificationButton = UIBarButtonItem(image: UIImage(systemName: "bell.fill"), style: .plain, target: self, action: #selector(notificationTapped))
        navigationItem.rightBarButtonItem = notificationButton
        
        navBar.setItems([navigationItem], animated: false)
    }
    @objc func hamburgerTapped() {
        print("Hamburger button tapped")
    }
    
    @objc func searchTapped() {
        print("Search button tapped")
    }
    
    @objc func notificationTapped() {
        print("Notification button tapped")
    }
    
    private func setupTabs() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor.fromHex("#003366")
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.5)
        
        let home = createNav(with: "Products", and: UIImage(systemName: "house"), vc: HomeCoordinator.createHomeViewController())
        let bookmark = createNav(with: "Bookmarks", and: UIImage(systemName: "bookmark.fill"), vc: BookmarkCoordinator.createBookmarkViewController())
        
        self.setViewControllers([home, bookmark], animated: true)
    }
    
    private func createNav(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        return nav
    }
}
