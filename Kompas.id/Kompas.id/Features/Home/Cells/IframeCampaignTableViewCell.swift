//
//  IframeCampaignTableViewCell.swift
//  Kompas.id
//
//  Created by Farhan on 07/08/25.
//

import UIKit
import SnapKit
import WebKit

class IframeCampaignTableViewCell: UITableViewCell {
    static let identifier = "IframeCampaignTableViewCell"

    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()
    
    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 8
        return stackView
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    private let containerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        }
        
        containerView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(subtitleLabel)
        
        subtitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        mainStackView.addArrangedSubview(headerStackView)
        mainStackView.addArrangedSubview(webView)
        
        webView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
    }

    func configure(with data: IframeCampaignResponse) {
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        
        if let url = URL(string: data.iframeUrl) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
