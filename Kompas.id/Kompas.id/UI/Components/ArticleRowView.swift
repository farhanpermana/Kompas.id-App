//
//  ArticleRowView.swift
//  Kompas.id
//
//  Created by Farhan on 06/08/25.
//

import UIKit
import SnapKit
import SDWebImage

class ArticleRowView: UIView {
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .fill
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 6
        iv.isHidden = true
        return iv
    }()
    
    private let titleRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .top
        stackView.distribution = .fill
        return stackView
    }()
    
    private let timeAndIconsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()
    
    private let iconsStackView: IconStackView = {
        let stackView = IconStackView(spacing: 8)
        return stackView
    }()
    
    private var article: GenericArticle?
    var onTap: ((GenericArticle) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleRowStackView)
        contentStackView.addArrangedSubview(timeAndIconsStackView)
        
        titleRowStackView.addArrangedSubview(titleLabel)
        titleRowStackView.addArrangedSubview(thumbnailImageView)
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        thumbnailImageView.setContentHuggingPriority(.required, for: .horizontal)
        thumbnailImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        thumbnailImageView.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(60)
        }
        timeAndIconsStackView.addArrangedSubview(timeLabel)
        timeAndIconsStackView.addArrangedSubview(UIView())
        timeAndIconsStackView.addArrangedSubview(iconsStackView)
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(12)
        }
        iconsStackView.addBookmarkTapGesture(target: self, action: #selector(bookmarkTapped))
        iconsStackView.addShareTapGesture(target: self, action: #selector(shareTapped))
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapRow))
        addGestureRecognizer(tap)
    }
    
    func configure(with article: GenericArticle) {
        self.article = article
        titleLabel.text = article.title
        timeLabel.text = article.publishedTime
        
        if let imageURLString = article.image, !imageURLString.isEmpty, let url = URL(string: imageURLString) {
            thumbnailImageView.isHidden = false
            let thumbSize = CGSize(width: 80, height: 60)
            let pixelSize = CGSize(width: thumbSize.width * UIScreen.main.scale,
                                    height: thumbSize.height * UIScreen.main.scale)
            let context: [SDWebImageContextOption: Any] = [
                .imageThumbnailPixelSize: pixelSize,
                .imageTransformer: SDImageResizingTransformer(size: thumbSize, scaleMode: .aspectFill)
            ]
            thumbnailImageView.sd_setImage(
                with: url,
                placeholderImage: UIImage(named: "placeholder"),
                options: [.scaleDownLargeImages, .continueInBackground],
                context: context
            )
        } else {
            thumbnailImageView.isHidden = true
            thumbnailImageView.image = nil
        }
        
        let articleID = article.id ?? article.generateID()
        let isBookmarked = BookmarkManager.shared.isArticleBookmarked(articleID)
        iconsStackView.configureBookmarkState(isBookmarked: isBookmarked)
    }
    
    @objc private func bookmarkTapped() {
        guard let article = self.article else { return }
        
        let articleID = article.id ?? article.generateID()

        if BookmarkManager.shared.isArticleBookmarked(articleID) {
            BookmarkManager.shared.removeBookmark(for: articleID)
            iconsStackView.configureBookmarkState(isBookmarked: false)
        } else {
            BookmarkManager.shared.bookmarkArticle(article)
            iconsStackView.configureBookmarkState(isBookmarked: true)
        }
    }
    
    @objc private func didTapRow() {
        guard let article else { return }
        onTap?(article)
    }

    @objc private func shareTapped() {
        guard let article = self.article else { return }
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
}
