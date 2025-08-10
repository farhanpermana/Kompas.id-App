//
//  ReusableIconView.swift
//  Kompas.id
//
//  Created by Farhan on 06/08/25.
//

import UIKit
import SnapKit

class ReusableIconView: UIView {
    
    private let imageView: UIImageView
    private let iconName: String
    private let size: CGFloat
    private let isInteractive: Bool
    
    init(iconName: String, size: CGFloat = 34, isInteractive: Bool = false) {
        self.iconName = iconName
        self.size = size
        self.isInteractive = isInteractive
        
        self.imageView = UIImageView(image: UIImage(named: iconName))
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.isUserInteractionEnabled = isInteractive
        
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(size)
        }
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setTintColor(_ color: UIColor?) {
        imageView.tintColor = color
    }

    func setPreferredSymbolConfiguration(_ configuration: UIImage.SymbolConfiguration?) {
        imageView.preferredSymbolConfiguration = configuration
    }

    func addTapGesture(target: Any?, action: Selector?) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        imageView.addGestureRecognizer(tapGesture)
    }
}

class ShareIconView: ReusableIconView {
    init(size: CGFloat = 34) {
        super.init(iconName: "share", size: size, isInteractive: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BookmarkIconView: ReusableIconView {
    init(size: CGFloat = 34) {
        super.init(iconName: "bookmark", size: size, isInteractive: true)
        setTintColor(.label)
        let symbolPointSize = max(10, size - 6)
        let base = UIImage.SymbolConfiguration(pointSize: symbolPointSize, weight: .regular)
        let config = base.applying(UIImage.SymbolConfiguration(scale: .small))
        setPreferredSymbolConfiguration(config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBookmarkState(isBookmarked: Bool) {
        if isBookmarked {
            setImage(UIImage(systemName: "bookmark.fill"))
        } else {
            setImage(UIImage(named: "bookmark"))
        }
    }
}

class AudioIconView: ReusableIconView {
    init(size: CGFloat = 34) {
        super.init(iconName: "audio", size: size, isInteractive: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class IconStackView: UIStackView {
    
    private let shareIcon: ShareIconView
    private let bookmarkIcon: BookmarkIconView
    private let audioIcon: AudioIconView
    
    init(spacing: CGFloat = 8) {
        self.shareIcon = ShareIconView()
        self.bookmarkIcon = BookmarkIconView()
        self.audioIcon = AudioIconView()
        
        super.init(frame: .zero)
        
        self.axis = .horizontal
        self.spacing = spacing
        self.distribution = .fill
        self.alignment = .center
        
        setupIcons()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupIcons() {
        addArrangedSubview(shareIcon)
        addArrangedSubview(bookmarkIcon)
        addArrangedSubview(audioIcon)
        
        [shareIcon, bookmarkIcon, audioIcon].forEach { icon in
            icon.snp.makeConstraints { make in
                make.width.height.equalTo(34)
            }
        }
    }
    
    func addBookmarkTapGesture(target: Any?, action: Selector?) {
        bookmarkIcon.addTapGesture(target: target, action: action)
    }
    
    func configureBookmarkState(isBookmarked: Bool) {
        bookmarkIcon.setBookmarkState(isBookmarked: isBookmarked)
    }
    
    func addShareTapGesture(target: Any?, action: Selector?) {
        shareIcon.addTapGesture(target: target, action: action)
    }
    
    func addAudioTapGesture(target: Any?, action: Selector?) {
        audioIcon.addTapGesture(target: target, action: action)
    }
}
