//
//  BookmarkViewController.swift
//  Kompas.id
//
//  Created by Farhan on 07/08/25.
//

import UIKit
import SnapKit

class BookmarkViewController: BaseViewController {
    
    var viewModel: BookmarkViewModel!
    var coordinator: BookmarkCoordinator!
    private let tableView = UITableView()
    private var bookmarkedArticles: [BookmarkedArticle] = []
    private lazy var emptyView: EmptyStateView = {
        let view = EmptyStateView(
            iconName: "bookmark",
            title: "Belum ada bookmark",
            message: "Simpan artikel untuk membacanya kembali di sini.",
            buttonTitle: nil,
            onButtonTap: nil
        )
        return view
    }()
    
    //MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
        viewModel.inputs.onViewDidLoad()
        loadBookmarks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBookmarks()
    }
}

// MARK: Private
extension BookmarkViewController {
    
    func setupViews() {
        view.backgroundColor = .white
        
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.backgroundView = emptyView
    }
    
    private func loadBookmarks() {
        bookmarkedArticles = BookmarkManager.shared.fetchBookmarkedArticles()
        tableView.reloadData()
        
        emptyView.isHidden = !bookmarkedArticles.isEmpty
    }
    
    func bindViewModel() {
        observeUpdate()
    }
    
    func observeUpdate() {
        viewModel.outputs.update
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.loadBookmarks()
            })
            .disposed(by: disposeBag)
        BookmarkManager.shared.bookmarkStatusChanged
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.loadBookmarks()
            })
            .disposed(by: disposeBag)
    }
}

extension BookmarkViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarkedArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier, for: indexPath) as? ArticleTableViewCell else {
            fatalError("Failed to dequeue ArticleTableViewCell")
        }
        
        let bookmarkedArticle = bookmarkedArticles[indexPath.row]
        
        let genericArticle = GenericArticle(
            id: bookmarkedArticle.identifier,
            title: bookmarkedArticle.title ?? "",
            publishedTime: bookmarkedArticle.publishedTime,
            description: nil,
            imageDescription: nil,
            mediaCount: nil,
            image: nil
        )
        
        cell.configure(with: genericArticle)
        return cell
    }
}
