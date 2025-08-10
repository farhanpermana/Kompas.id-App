//
//  ReusableArticleSectionTableViewCell.swift
//  Kompas.id
//
//  Created by Farhan on 09/08/25.
//

import UIKit
import SnapKit
import SDWebImage

class ReusableArticleSectionTableViewCell: UITableViewCell {
    static let identifier = "ReusableArticleSectionTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.fromHex("#00559a")
        return label
    }()
    
    private let chevronView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor.fromHex("#00559a")
        return iv
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(chevronView)
        contentView.addSubview(mainStackView)
        
        chevronView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.width.equalTo(10)
            make.height.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(chevronView.snp.leading).offset(-8)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    var onArticleSelected: ((GenericArticle) -> Void)?
    
    func configure(with sectionData: ReusableArticleSection) {
        titleLabel.text = sectionData.section
        
        mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let firstArticle = sectionData.articles.first {
            let headerView = createArticleHeaderView(with: firstArticle)
            mainStackView.addArrangedSubview(headerView)
            
            let separatorView = UIView()
            separatorView.backgroundColor = .systemGray5
            mainStackView.addArrangedSubview(separatorView)
            separatorView.snp.makeConstraints { make in
                make.height.equalTo(0.5)
                make.leading.trailing.equalToSuperview()
            }
        }
        
        let remainingArticles = sectionData.articles.dropFirst()
        for (index, articleData) in remainingArticles.enumerated() {
            let articleRowView = ArticleRowView()
            articleRowView.configure(with: articleData)
            articleRowView.onTap = { [weak self] article in
                guard let self else { return }
                self.onArticleSelected?(article)
            }
            mainStackView.addArrangedSubview(articleRowView)
            
            if index < remainingArticles.count - 1 {
                let separatorView = UIView()
                separatorView.backgroundColor = .systemGray5
                mainStackView.addArrangedSubview(separatorView)
                separatorView.snp.makeConstraints { make in
                    make.height.equalTo(0.5)
                    make.leading.trailing.equalToSuperview().inset(16)
                }
            }
        }
    }
    
    private func createArticleHeaderView(with article: GenericArticle) -> UIView {
        let headerView = HeaderArticleView()
        headerView.configure(with: article)
        headerView.onTap = { [weak self] article in
            guard let self else { return }
            self.onArticleSelected?(article)
        }
        return headerView
    }
}
