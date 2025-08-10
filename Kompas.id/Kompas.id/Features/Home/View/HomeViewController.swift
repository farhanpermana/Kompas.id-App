//
//  HomeViewController.swift
//  Kompas.id
//
//  Created by Farhan on 03/08/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HomeViewController: BaseViewController {
    
    let tableView = UITableView()
    private let categoryTabs = CategoryTabView(items: ["Berita Utama", "Terbaru", "Pilihanku", "Terpopuler"])
    private let refreshControl = UIRefreshControl()
    private lazy var errorView: EmptyStateView = {
        let view = EmptyStateView(
            iconName: nil,
            title: "Gagal memuat",
            message: "Terjadi kesalahan. Coba lagi.",
            buttonTitle: "Coba Lagi",
            onButtonTap: { [weak self] in
                guard let self else { return }
                self.viewModel.inputs.refresh()
            }
        )
        view.isHidden = true
        return view
    }()
    
    var viewModel: HomeViewModel!
    var coordinator: HomeCoordinator!
    private var homeSections: [HomeSectionData] = []
    
    //MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
        viewModel.inputs.onViewDidLoad()
    }
}

// MARK: Private
extension HomeViewController {
    
    private func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(categoryTabs)
        view.addSubview(tableView)
        tableView.refreshControl = refreshControl
        tableView.backgroundView = errorView
        
        tableView.register(BreakingNewsTableViewCell.self, forCellReuseIdentifier: BreakingNewsTableViewCell.identifier)
        tableView.register(LiveReportTableViewCell.self, forCellReuseIdentifier: LiveReportTableViewCell.identifier)
        tableView.register(IframeCampaignTableViewCell.self, forCellReuseIdentifier: IframeCampaignTableViewCell.identifier)
        tableView.register(HotTopicsTableViewCell.self, forCellReuseIdentifier: HotTopicsTableViewCell.identifier)
        tableView.register(ReusableArticleSectionTableViewCell.self, forCellReuseIdentifier: ReusableArticleSectionTableViewCell.identifier)
        
        categoryTabs.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(categoryTabs.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        categoryTabs.onSelectIndex = { [weak self] idx in
            guard let self = self else { return }
            self.tableView.isHidden = (idx != 0)
        }
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    private func bindViewModel() {
        viewModel.outputs.homeSections
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] sections in
                guard let self else { return }
                self.homeSections = sections
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.errorView.isHidden = true
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.error
            .subscribe(onNext: { [weak self] apiError in
                guard let self else { return }
                guard let apiError else { return }
                let (title, message) = self.errorText(for: apiError)
                self.errorView.removeFromSuperview()
                let newError = EmptyStateView(iconName: nil, title: title, message: message, buttonTitle: "Coba Lagi", onButtonTap: { [weak self] in
                    guard let self else { return }
                    self.viewModel.inputs.refresh()
                })
                self.errorView = newError
                self.tableView.backgroundView = newError
                self.errorView.isHidden = false
                self.homeSections = []
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        BookmarkManager.shared.bookmarkStatusChanged
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return homeSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionData = homeSections[indexPath.section]
        
        switch sectionData.type {
        case .breakingNews:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BreakingNewsTableViewCell.identifier, for: indexPath) as? BreakingNewsTableViewCell,
                  case let .breakingNews(newsData) = sectionData.data else {
                return UITableViewCell()
            }
            cell.configure(with: newsData)
            cell.onArticleSelected = { [weak self] article in
                guard let self = self else { return }
                self.coordinator.openArticleDetail(from: self, article: article)
            }
            return cell
            
        case .liveReport:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LiveReportTableViewCell.identifier, for: indexPath) as? LiveReportTableViewCell,
                  case let .liveReport(liveData) = sectionData.data else {
                return UITableViewCell()
            }
            cell.configure(with: liveData)
            return cell
            
        case .iframeCampaign:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: IframeCampaignTableViewCell.identifier, for: indexPath) as? IframeCampaignTableViewCell,
                  case let .iframeCampaign(iframeData) = sectionData.data else {
                return UITableViewCell()
            }
            cell.configure(with: iframeData)
            return cell
            
        case .hotTopics:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: HotTopicsTableViewCell.identifier, for: indexPath) as? HotTopicsTableViewCell,
                  case let .hotTopics(hotTopics) = sectionData.data else {
                return UITableViewCell()
            }
            cell.configure(with: hotTopics)
            return cell
            
        case .articles:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReusableArticleSectionTableViewCell.identifier, for: indexPath) as? ReusableArticleSectionTableViewCell,
                  case let .articles(articles) = sectionData.data else {
                return UITableViewCell()
            }
            let reusableSectionData = ReusableArticleSection(section: sectionData.title ?? "Artikel Terbaru", articles: articles)
            cell.configure(with: reusableSectionData)
            cell.onArticleSelected = { [weak self] article in
                guard let self = self else { return }
                self.coordinator.openArticleDetail(from: self, article: article)
            }
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension HomeViewController {
    func errorText(for error: APIError) -> (String, String) {
        switch error {
        case .httpError(let code):
            switch code {
            case 404: return ("Konten tidak ditemukan", "Kode 404: Sumber tidak tersedia.")
            case 500: return ("Terjadi kesalahan server", "Kode 500: Silakan coba lagi nanti.")
            default:  return ("Terjadi kesalahan", "Kode \(code): Silakan coba lagi.")
            }
        case .invalidURL:
            return ("URL tidak valid", "Periksa konfigurasi aplikasi.")
        case .noData:
            return ("Tidak ada data", "Server tidak mengirimkan data.")
        case .decodingError:
            return ("Gagal memproses data", "Terjadi kesalahan saat membaca data.")
        }
    }
    @objc func handleRefresh() {
        viewModel.inputs.refresh()
    }
}
