//
//  HotTopicCollectionViewCell.swift
//  Kompas.id
//
//  Created by Farhan on 08/08/25.
//

import UIKit
import SnapKit
import SDWebImage

class HotTopicCollectionViewCell: UICollectionViewCell {
    static let identifier = "HotTopicCollectionViewCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.masksToBounds = true
        return view
    }()

    private let topicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        if let chevronImage = UIImage(systemName: "chevron.right") {
            imageView.image = chevronImage.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        }
        imageView.contentMode = .center
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white

        addSubview(containerView)
        containerView.addSubview(topicImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(chevronImageView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        topicImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.height.equalTo(56)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(topicImageView.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(chevronImageView.snp.leading).offset(-8)
        }

        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }

    func configure(with topic: HotTopic) {
        titleLabel.text = topic.title

        topicImageView.image = nil
        topicImageView.backgroundColor = .systemGray5

        if let imageURLString = topic.image, !imageURLString.isEmpty, let url = URL(string: imageURLString) {
             topicImageView.sd_setImage(
                with: url,
                placeholderImage: nil,
                options: [],
                completed: nil
             )
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        topicImageView.sd_cancelCurrentImageLoad()
        topicImageView.image = nil
        topicImageView.backgroundColor = .systemGray5
        titleLabel.text = nil
    }
}
