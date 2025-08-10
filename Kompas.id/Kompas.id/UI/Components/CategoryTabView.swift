//
//  CategoryTabView.swift
//  Kompas.id
//
//  Created by Farhan on 11/08/25.
//

import UIKit
import SnapKit

final class CategoryTabView: UIView {
    var onSelectIndex: ((Int) -> Void)?
    private(set) var selectedIndex: Int = 0

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    private let indicatorView = UIView()

    private let items: [String]

    init(items: [String]) {
        self.items = items
        super.init(frame: .zero)
        setupUI()
        setupButtons()
        select(index: 0, animated: false)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = UIColor.fromHex("#00559a")

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 24
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
            make.height.equalTo(scrollView.snp.height)
        }

        indicatorView.backgroundColor = UIColor.systemGreen
        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom)
            make.height.equalTo(3)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview()
        }
    }

    private func setupButtons() {
        buttons = items.enumerated().map { idx, title in
            let button = UIButton(type: .system)
            button.setTitle(title.uppercased(), for: .normal)
            button.setTitleColor(.white.withAlphaComponent(0.7), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.lineBreakMode = .byClipping
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            button.tag = idx
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            return button
        }
        buttons.forEach { stackView.addArrangedSubview($0) }
    }

    @objc private func didTapButton(_ sender: UIButton) {
        select(index: sender.tag, animated: true)
        onSelectIndex?(sender.tag)
    }

    func select(index: Int, animated: Bool) {
        guard index >= 0, index < buttons.count else { return }
        selectedIndex = index

        for (i, button) in buttons.enumerated() {
            button.setTitleColor(i == index ? .white : .white.withAlphaComponent(0.7), for: .normal)
        }

        let target = buttons[index]
        let inset: CGFloat = 12
        let animations = {
            self.indicatorView.snp.remakeConstraints { make in
                make.top.equalTo(self.scrollView.snp.bottom)
                make.height.equalTo(3)
                make.leading.equalTo(target.snp.leading).offset(inset)
                make.trailing.equalTo(target.snp.trailing).inset(inset)
                make.bottom.equalToSuperview()
            }
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.22, animations: animations)
        } else {
            animations()
        }

        let rectInScroll = target.convert(target.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rectInScroll.insetBy(dx: -16, dy: 0), animated: animated)
    }
}


