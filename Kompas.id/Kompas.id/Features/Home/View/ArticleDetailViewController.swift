//
//  ArticleDetailViewController.swift
//  Kompas.id
//
//  Created by Farhan on 10/08/25.
//

import UIKit
import SnapKit
import SDWebImage

final class ArticleDetailViewController: BaseViewController {
    private let article: GenericArticle
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    init(article: GenericArticle) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configure()
        setupNavigation()
    }
    
    private func setupUI() {
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.alignment = .fill
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.width.equalTo(scrollView.snp.width).offset(-32)
        }
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(180)
        }
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.numberOfLines = 0
        
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0
        
        contentStack.addArrangedSubview(imageView)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(timeLabel)
        contentStack.addArrangedSubview(descriptionLabel)
    }
    
    private func configure() {
        titleLabel.text = article.title
        timeLabel.text = article.publishedTime
        descriptionLabel.text = article.description ?? article.imageDescription
        
        if let imageURLString = article.image, !imageURLString.isEmpty, let url = URL(string: imageURLString) {
            imageView.isHidden = false
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            imageView.isHidden = true
        }
    }
    
    private func setupNavigation() {
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "Kembali", style: .plain, target: self, action: #selector(didTapBack))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}


