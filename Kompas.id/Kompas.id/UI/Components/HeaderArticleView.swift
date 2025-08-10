//
//  HeaderArticleView.swift
//  Kompas.id
//
//  Created by Farhan on 09/08/25.
//

import UIKit
import SnapKit
import SDWebImage
import RxSwift
import RxRelay

class HeaderArticleView: UIView {
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 2
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemGray
        return label
    }()
    
    private let timeAndIconsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let iconsStackView: IconStackView = {
        let stackView = IconStackView(spacing: 8)
        return stackView
    }()
    
    private var article: GenericArticle?
    var onTap: ((GenericArticle) -> Void)?
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    private func setupUI() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(timeAndIconsStackView)
        
        timeAndIconsStackView.addArrangedSubview(timeLabel)
        timeAndIconsStackView.addArrangedSubview(UIView())
        timeAndIconsStackView.addArrangedSubview(iconsStackView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        timeAndIconsStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGesture)

        iconsStackView.addShareTapGesture(target: self, action: #selector(shareTapped))
    }
    
    func configure(with article: GenericArticle) {
        self.article = article
        
        titleLabel.text = article.title
        descriptionLabel.text = article.description
        timeLabel.text = article.publishedTime
        
        if let imageURL = article.image, !imageURL.isEmpty, let url = URL(string: imageURL) {
            imageView.sd_setImage(with: url, placeholderImage: nil)
            imageView.isHidden = false
            imageView.snp.updateConstraints { $0.height.equalTo(200) }
        } else {
            imageView.isHidden = true
            imageView.snp.updateConstraints { $0.height.equalTo(0) }
        }
        
        let articleID = article.id ?? article.generateID()
        
        let updateBookmarkIcon = {
            let isBookmarked = BookmarkManager.shared.isArticleBookmarked(articleID)
            self.iconsStackView.configureBookmarkState(isBookmarked: isBookmarked)
        }
        
        updateBookmarkIcon()
        
        iconsStackView.addBookmarkTapGesture(target: self, action: #selector(bookmarkTapped))
        
        BookmarkManager.shared.bookmarkStatusChanged
            .subscribe(onNext: { _ in
                updateBookmarkIcon()
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func bookmarkTapped() {
        guard let article = self.article else { return }
        
        let articleID = article.id ?? article.generateID()
        
        if BookmarkManager.shared.isArticleBookmarked(articleID) {
            BookmarkManager.shared.removeBookmark(for: article)
        } else {
            BookmarkManager.shared.bookmarkArticle(article)
        }
    }

    @objc private func handleTap() {
        guard let article = self.article else { return }
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
