//
//  BreakingNewsTableViewCell.swift
//  Kompas.id
//
//  Created by Farhan on 03/08/25.
//

import UIKit
import SnapKit
import SDWebImage

class BreakingNewsTableViewCell: UITableViewCell {
    static let identifier = "BreakingNewsTableViewCell"
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        return stackView
    }()
    
    private let headerView = UIView()
    private var headerArticle: GenericArticle?
    
    private let articlesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        return stackView
    }()
    
    private let iconsStackView: IconStackView = {
        let stackView = IconStackView(spacing: 8)
        return stackView
    }()
    
    var onArticleSelected: ((GenericArticle) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .white
        
        contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(headerView)
        mainStackView.addArrangedSubview(articlesStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with news: BreakingNewsResponse) {
        configureHeaderView(with: news)
        
        articlesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, article) in news.articles.enumerated() {
            let articleRowView = ArticleRowView()
            articleRowView.configure(with: article)
            articleRowView.onTap = { [weak self] article in
                guard let self else { return }
                self.onArticleSelected?(article)
            }
            articlesStackView.addArrangedSubview(articleRowView)
            
            if index < news.articles.count - 1 {
                let separatorView = UIView()
                separatorView.backgroundColor = .systemGray5
                articlesStackView.addArrangedSubview(separatorView)
                separatorView.snp.makeConstraints { make in
                    make.height.equalTo(0.5)
                    make.leading.trailing.equalToSuperview()
                }
            }
        }
    }
    
    private func configureHeaderView(with news: BreakingNewsResponse) {
        headerView.subviews.forEach { $0.removeFromSuperview() }
        
        let breakingNewsImageView = UIImageView(image: UIImage(named: "breakingnews"))
        let imageView = UIImageView()
        let headlineLabel = UILabel()
        let subheadlineLabel = UILabel()
        let timeLabel = UILabel()
        let timeAndIconsStackView = UIStackView()
        
        breakingNewsImageView.contentMode = .scaleAspectFit
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        headlineLabel.font = UIFont.boldSystemFont(ofSize: 18)
        headlineLabel.numberOfLines = 0
        subheadlineLabel.font = UIFont.systemFont(ofSize: 14)
        subheadlineLabel.textColor = .systemGray
        subheadlineLabel.numberOfLines = 0
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .systemGray
        
        timeAndIconsStackView.axis = .horizontal
        timeAndIconsStackView.spacing = 8
        timeAndIconsStackView.alignment = .center
        
        headerView.addSubview(breakingNewsImageView)
        headerView.addSubview(imageView)
        headerView.addSubview(headlineLabel)
        headerView.addSubview(subheadlineLabel)
        headerView.addSubview(timeAndIconsStackView)
        
        timeAndIconsStackView.addArrangedSubview(timeLabel)
        timeAndIconsStackView.addArrangedSubview(UIView())
        timeAndIconsStackView.addArrangedSubview(iconsStackView)
        
        iconsStackView.addShareTapGesture(target: self, action: #selector(didTapShare))
        iconsStackView.addBookmarkTapGesture(target: self, action: #selector(didTapBookmark))
        iconsStackView.addAudioTapGesture(target: self, action: #selector(didTapAudio))
        
        headlineLabel.text = news.headline
        subheadlineLabel.text = news.subheadline
        timeLabel.text = news.publishedTime
        
        if let imageURLString = news.image, let url = URL(string: imageURLString) {
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
        
        let headerGeneric = GenericArticle(
            id: news.headline.replacingOccurrences(of: " ", with: "_"),
            title: news.headline,
            publishedTime: news.publishedTime,
            description: news.subheadline,
            imageDescription: nil,
            mediaCount: nil,
            image: news.image
        )
        self.headerArticle = headerGeneric
        
        let headerID = headerGeneric.id ?? headerGeneric.generateID()
        let isBookmarked = BookmarkManager.shared.isArticleBookmarked(headerID)
        iconsStackView.configureBookmarkState(isBookmarked: isBookmarked)
        
        breakingNewsImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(130)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(breakingNewsImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        
        headlineLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        subheadlineLabel.snp.makeConstraints { make in
            make.top.equalTo(headlineLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        timeAndIconsStackView.snp.makeConstraints { make in
            make.top.equalTo(subheadlineLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(tap)
    }
}

extension BreakingNewsTableViewCell {
    @objc private func didTapShare() {
        guard let article = self.headerArticle else { return }
        let title = article.title
        let slug = title.slugified()
        let urlString = "https://kompas.com/artikel/\(slug)"
        UIPasteboard.general.string = urlString
        let alert = UIAlertController(title: nil, message: "Tautan disalin", preferredStyle: .alert)
        if let topVC = UIApplication.topMostViewController() {
            topVC.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc private func didTapBookmark() {
        guard let article = self.headerArticle else { return }
        
        let articleID = article.id ?? article.generateID()
        
        if BookmarkManager.shared.isArticleBookmarked(articleID) {
            BookmarkManager.shared.removeBookmark(for: articleID)
            iconsStackView.configureBookmarkState(isBookmarked: false)
        } else {
            BookmarkManager.shared.bookmarkArticle(article)
            iconsStackView.configureBookmarkState(isBookmarked: true)
        }
    }
    
    @objc private func didTapAudio() {
    }
    
    @objc private func didTapHeader() {
        guard let headerArticle else { return }
        onArticleSelected?(headerArticle)
    }
}
