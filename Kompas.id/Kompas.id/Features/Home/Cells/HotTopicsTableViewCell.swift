//
//  HotTopicsTableViewCell.swift
//  Kompas.id
//
//  Created by Farhan on 08/08/25.
//

import UIKit
import SnapKit

class HotTopicsTableViewCell: UITableViewCell {
    static let identifier = "HotTopicsTableViewCell"
    
    private var topics: [HotTopic] = []
    private var collectionViewHeightConstraint: Constraint?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.alwaysBounceVertical = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(HotTopicCollectionViewCell.self, forCellWithReuseIdentifier: HotTopicCollectionViewCell.identifier)
        return collectionView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 0
        return label
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
        backgroundColor = .white
        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.trailing.leading.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            self.collectionViewHeightConstraint = make.height.equalTo(0).constraint
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func configure(with response: HotTopicsResponse) {
        self.topics = response.topics
        titleLabel.text = response.section
        
        let collectionViewHeight = CGFloat(topics.count) * 72
        collectionViewHeightConstraint?.update(offset: collectionViewHeight)
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension HotTopicsTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotTopicCollectionViewCell.identifier, for: indexPath) as? HotTopicCollectionViewCell else {
            return UICollectionViewCell()
        }
        let topic = topics[indexPath.item]
        cell.configure(with: topic)
        return cell
    }
}

extension HotTopicsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 72)
    }
}
