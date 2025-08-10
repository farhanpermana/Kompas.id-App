//
//  ArticleTableViewCell.swift
//  Kompas.id
//
//  Created by Farhan on 07/08/25.
//

import UIKit
import SnapKit

class ArticleTableViewCell: UITableViewCell {
    static let identifier = "ArticleTableViewCell"

    let articleRowView = ArticleRowView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.addSubview(articleRowView)
        articleRowView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configure(with article: GenericArticle) {
        articleRowView.configure(with: article)
    }
}
