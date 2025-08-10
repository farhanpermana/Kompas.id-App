//
//  MainTabController.swift
//  Kompas.id
//
//  Created by Farhan on 03/08/25.
//

import UIKit
import SnapKit

class MainTabController: UITabBarController, UINavigationControllerDelegate, UITabBarControllerDelegate {
    private let customNavBar = UINavigationBar()
    private var backButtonItem: UIBarButtonItem!
    private var hamburgerButton: UIBarButtonItem!
    private var searchButton: UIBarButtonItem!
    private var notificationButton: UIBarButtonItem!
    private var logoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.setupCustomNavigationBar()
        self.setupTabs()
        self.refreshCustomNavBar()
    }
    
    private func setupCustomNavigationBar() {
        let statusBarView = UIView()
        statusBarView.backgroundColor = UIColor.fromHex("#00559a")
        view.addSubview(statusBarView)
        
        statusBarView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        customNavBar.barTintColor = UIColor.fromHex("#00559a")
        customNavBar.isTranslucent = false
        customNavBar.tintColor = .white
        
        view.addSubview(customNavBar)
        
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        hamburgerButton = UIBarButtonItem(image: UIImage(systemName: "list.dash"), style: .plain, target: self, action: #selector(hamburgerTapped))
        searchButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchTapped))
        backButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(customBackTapped))
        
        let logoImageView = UIImageView(image: UIImage(named: "kompaslogo"))
        logoImageView.contentMode = .scaleAspectFit
        
        logoView = UIView()
        logoView.addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(35)
            make.width.equalTo(110)
        }
        
        refreshCustomNavBar()
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
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .white
        tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBarAppearance
        }
        tabBar.isTranslucent = false
        tabBar.tintColor = UIColor.fromHex("#00559a")
        tabBar.unselectedItemTintColor = UIColor.darkGray.withAlphaComponent(0.6)
        
        let home = createNav(with: "Home", and: UIImage(systemName: "house"), vc: HomeCoordinator.createHomeViewController())
        let bookmark = createNav(with: "Bookmarks", and: UIImage(systemName: "bookmark.fill"), vc: BookmarkCoordinator.createBookmarkViewController())
        
        self.setViewControllers([home, bookmark], animated: true)
        self.selectedIndex = 0
    }
    
    private func createNav(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        nav.navigationBar.isHidden = true
        nav.delegate = self
        return nav
    }
    
    private func refreshCustomNavBar() {
        guard let nav = selectedViewController as? UINavigationController else { return }
        updateCustomNavBar(for: nav)
    }
    
    private func updateCustomNavBar(for nav: UINavigationController) {
        notificationButton = UIBarButtonItem(image: UIImage(systemName: "bell.fill"), style: .plain, target: self, action: #selector(notificationTapped))
        let isRoot = nav.viewControllers.count <= 1
        let navigationItem = UINavigationItem(title: isRoot ? "" : (nav.topViewController?.title ?? ""))
        if isRoot {
            navigationItem.leftBarButtonItems = [hamburgerButton, searchButton]
            navigationItem.titleView = logoView
            navigationItem.rightBarButtonItem = notificationButton
        } else {
            navigationItem.leftBarButtonItem = backButtonItem
            navigationItem.titleView = nil
            navigationItem.rightBarButtonItem = nil
        }
        customNavBar.setItems([navigationItem], animated: false)
        
        let topInset = customNavBar.bounds.height
        if let topVC = nav.topViewController {
            var insets = topVC.additionalSafeAreaInsets
            insets.top = topInset
            topVC.additionalSafeAreaInsets = insets
        }
    }
    
    @objc private func customBackTapped() {
        (selectedViewController as? UINavigationController)?.popViewController(animated: true)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if navigationController == (selectedViewController as? UINavigationController) {
            updateCustomNavBar(for: navigationController)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        refreshCustomNavBar()
    }
}
