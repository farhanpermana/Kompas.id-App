//
//  LiveReportTableViewCell.swift
//  Kompas.id
//
//  Created by Farhan on 05/08/25.
//

import UIKit
import SnapKit
import SDWebImage

class LiveReportTableViewCell: UITableViewCell {
    static let identifier = "LiveReportTableViewCell"
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
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
        contentView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }
    }
    
    func configure(with data: LiveReportResponse) {
        mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let headerView = createHeaderView(with: data.reportType, mainArticle: data.mainArticle)
        let mainArticleView = createMainArticleView(with: data.mainArticle)
        let relatedArticlesView = createRelatedArticlesView(with: data.relatedArticles)
        let footerView = createFooterView(with: data.moreReports)
        
        mainStackView.addArrangedSubview(headerView)
        mainStackView.addArrangedSubview(mainArticleView)
        mainStackView.addArrangedSubview(relatedArticlesView)
        
        let separatorLine1 = createSeparatorLine()
        mainStackView.addArrangedSubview(separatorLine1)
        
        mainStackView.addArrangedSubview(footerView)
        
        let separatorLine2 = createSeparatorLine()
        mainStackView.addArrangedSubview(separatorLine2)
        
        for article in data.featuredArticles {
            let featuredArticleView = createFeaturedArticleRow(with: article)
            mainStackView.addArrangedSubview(featuredArticleView)
            mainStackView.setCustomSpacing(8, after: featuredArticleView)
        }
    }
    
    private func createHeaderView(with reportType: String, mainArticle: MainArticle) -> UIView {
        let container = UIView()
        
        let bannerImageView = UIImageView()
        bannerImageView.contentMode = .scaleAspectFill
        bannerImageView.clipsToBounds = true
        bannerImageView.layer.cornerRadius = 8
        bannerImageView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
        container.addSubview(bannerImageView)
        bannerImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if let imageUrlString = mainArticle.image, !imageUrlString.isEmpty, let imageUrl = URL(string: imageUrlString) {
            bannerImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        } else {
            bannerImageView.backgroundColor = .systemGray4
        }
        
        let label = UILabel()
        label.text = reportType
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemRed
        backgroundView.layer.cornerRadius = 4
        
        backgroundView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }
        
        container.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(8)
        }
        
        return container
    }
    
    private func createMainArticleView(with article: MainArticle) -> UIView {
        let container = UIView()
        let subheadlineLabel = UILabel()
        subheadlineLabel.text = article.category
        subheadlineLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subheadlineLabel.textColor = .systemRed
        let headlineLabel = UILabel()
        headlineLabel.text = article.title
        headlineLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        headlineLabel.numberOfLines = 0
        headlineLabel.textColor = .black
        let timeLabel = UILabel()
        timeLabel.text = article.publishedTime
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        timeLabel.textColor = .systemGray
        let stackView = UIStackView(arrangedSubviews: [subheadlineLabel, headlineLabel, timeLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        container.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return container
    }
    
    private func createRelatedArticlesView(with articles: [RelatedArticle]) -> UIView {
        let container = UIView()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        
        container.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        for (index, article) in articles.enumerated() {
            let articleRow = createRelatedArticleRow(with: article,
                                                     isLast: index == articles.count - 1,
                                                     showTopLine: index > 0)
            stackView.addArrangedSubview(articleRow)
        }
        return container
    }
    
    private func createRelatedArticleRow(with article: RelatedArticle, isLast: Bool, showTopLine: Bool) -> UIView {
        let container = UIView()
        
        let articleContentStack = UIStackView()
        articleContentStack.axis = .vertical
        articleContentStack.spacing = 4
        
        let timeLabel = UILabel()
        timeLabel.text = article.publishedTime
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .systemGray
        
        let titleLabel = UILabel()
        titleLabel.text = article.title
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        
        articleContentStack.addArrangedSubview(timeLabel)
        articleContentStack.addArrangedSubview(titleLabel)
        
        let timelineContainer = UIView()
        
        let dotView = UIView()
        dotView.backgroundColor = .systemRed
        dotView.layer.cornerRadius = 4
        
        timelineContainer.addSubview(dotView)
        dotView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(1)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        

        if showTopLine {
            let verticalLineTop = UIView()
            verticalLineTop.backgroundColor = .systemGray3
            timelineContainer.addSubview(verticalLineTop)
            verticalLineTop.snp.makeConstraints { make in
                make.bottom.equalTo(dotView.snp.top)
                make.centerX.equalTo(dotView)
                make.top.equalToSuperview()
                make.width.equalTo(1)
            }
        }
        
        if !isLast {
            let verticalLineBottom = UIView()
            verticalLineBottom.backgroundColor = .systemGray3
            timelineContainer.addSubview(verticalLineBottom)
            verticalLineBottom.snp.makeConstraints { make in
                make.top.equalTo(dotView.snp.bottom)
                make.centerX.equalTo(dotView)
                make.bottom.equalToSuperview()
                make.width.equalTo(1)
            }
        }
        
        container.addSubview(timelineContainer)
        timelineContainer.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(20)
        }
        
        container.addSubview(articleContentStack)
        articleContentStack.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(timelineContainer.snp.trailing)
        }
        
        return container
    }
    
    private func createFooterView(with moreReports: MoreReports) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = moreReports.label
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        let countLabel = UILabel()
        countLabel.text = moreReports.count
        countLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        countLabel.textColor = .white
        countLabel.textAlignment = .center
        let countBackground = UIView()
        countBackground.backgroundColor = .systemRed
        countBackground.layer.cornerRadius = 10
        countBackground.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6))
        }
        let shareIcon = ShareIconView(size: 24)
        let stackView = UIStackView(arrangedSubviews: [label, countBackground, UIView(), shareIcon])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        container.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        shareIcon.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        return container
    }
    
    private func createSeparatorLine() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .systemGray5
        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        return separator
    }
    
    private func createFeaturedArticleRow(with article: FeaturedArticle) -> UIView {
        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.text = article.title
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .black
        let imageView = UIImageView()
        if let imageUrl = article.image, let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url)
        } else {
            imageView.backgroundColor = .systemGray4
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        container.addSubview(titleLabel)
        container.addSubview(imageView)
        titleLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(imageView.snp.leading).offset(-8)
        }
        imageView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.width.height.equalTo(72)
        }
        return container
    }
}
