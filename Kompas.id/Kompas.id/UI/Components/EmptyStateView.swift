//
//  EmptyStateView.swift
//  Kompas.id
//
//  Created by Farhan on 10/08/25.
//

import UIKit
import SnapKit

final class EmptyStateView: UIView {
    
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    private var onButtonTap: (() -> Void)?
    
    init(iconName: String? = nil,
         title: String,
         message: String? = nil,
         buttonTitle: String? = nil,
         onButtonTap: (() -> Void)? = nil) {
        self.onButtonTap = onButtonTap
        super.init(frame: .zero)
        setupUI()
        configure(iconName: iconName, title: title, message: message, buttonTitle: buttonTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(64)
        }
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        actionButton.setTitleColor(tintColor, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        actionButton.isHidden = true
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(actionButton)
    }
    
    private func configure(iconName: String?, title: String, message: String?, buttonTitle: String?) {
        if let iconName, let image = UIImage(named: iconName) {
            imageView.image = image.withRenderingMode(.alwaysTemplate)
        } else {
            imageView.isHidden = true
        }
        
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.isHidden = (message == nil)
        
        if let buttonTitle {
            actionButton.setTitle(buttonTitle, for: .normal)
            actionButton.isHidden = false
        }
    }
    
    @objc private func buttonTapped() {
        onButtonTap?()
    }
}


