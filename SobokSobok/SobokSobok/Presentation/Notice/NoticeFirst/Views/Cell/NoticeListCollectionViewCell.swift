//
//  NoticeListCollectionViewCell.swift
//  SobokSobok
//
//  Created by 정은희 on 2022/06/23.
//

import UIKit

import SnapKit
import Then

final class NoticeListCollectionViewCell: UICollectionViewCell, NoticeListPresentable {
    // MARK: - Properties
    lazy var info: (() -> Void) = {}
    lazy var accept: (() -> Void) = {}
    lazy var refuse: (() -> Void) = {}
    
    var sectionType: SectionType = .pill {
        didSet {
            setNeedsLayout()
        }
    }
    var statusType: StatusType = .waite {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - UI Components
    private lazy var topStackView =  UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
    }
    private lazy var iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    let nameLabel = UILabel().then {
        $0.font = UIFont.font(.pretendardSemibold, ofSize: 18)
        $0.textAlignment = .left
        $0.textColor = Color.gray900
    }
    private lazy var detailLabel = UILabel().then {
        $0.font = UIFont.font(.pretendardMedium, ofSize: 14)
        $0.text = "상세보기"
        $0.textColor = Color.gray900
    }
    private lazy var detailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = Image.icMoreBlack48
    }
    let detailButton = UIButton()
    let toolTipView = NoticeToolTipView(tipStartX: 184, tipWidth: 10, tipHeight: 6.2).then {
        $0.isHidden = true
    }
    private lazy var middleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 4
    }
    private lazy var lineView = UIView().then {
        $0.backgroundColor = Color.gray150
    }
    let descriptionLabel = UILabel().then {
        $0.font = UIFont.font(.pretendardMedium, ofSize: 14)
        $0.lineBreakMode = .byCharWrapping
        $0.numberOfLines = 2
        $0.textAlignment = .left
        $0.textColor = Color.gray600
    }
    let timeLabel = UILabel().then {
        $0.font = UIFont.font(.pretendardMedium, ofSize: 12)
        $0.textAlignment = .left
        $0.textColor = Color.gray500
    }
    private lazy var bottomStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 7
    }
    let refuseButton = SobokButton(frame: .zero, mode: .lightMint, text: "거절", fontSize: 13)
    let acceptButton = SobokButton(frame: .zero, mode: .mainMint, text: "수락", fontSize: 13)
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView(section: .pill, status: .waite)
        setupConstraint()
        
        presentDetailView()
        addAcceptAlert()
        addRefuseAlert()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Functions
    func setupView(section: SectionType, status: StatusType) {
        sectionType = section
        statusType = status
        divideSection()
        
        topStackView.addArrangedSubviews(iconImageView, nameLabel, detailButton, detailLabel, detailImageView)
        [detailLabel, detailImageView].forEach { $0.bringSubviewToFront(detailButton) }
        topStackView.bringSubviewToFront(toolTipView)
        middleStackView.addArrangedSubviews(lineView, descriptionLabel, timeLabel)
        bottomStackView.addArrangedSubviews(refuseButton, acceptButton)
        
        contentView.addSubviews(topStackView, toolTipView, middleStackView, bottomStackView)
        contentView.backgroundColor = Color.white
        contentView.makeRounded(radius: 12)
    }
    
    func setupConstraint() {
        topStackView.snp.makeConstraints { make in
            make.width.equalTo(299.adjustedWidth)
            make.height.equalTo(42.adjustedHeight)
            make.top.equalToSuperview().offset(18)
            make.centerX.equalToSuperview()
        }
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(22)
            make.top.equalTo(topStackView.snp.bottom).offset(1.5)
            make.leading.equalTo(topStackView.snp.leading)
        }
        nameLabel.snp.makeConstraints { make in
            make.width.equalTo(156.adjustedWidth)
            make.height.equalTo(25.adjustedHeight)
            make.top.equalTo(topStackView.snp.bottom)
            make.leading.equalTo(iconImageView.snp.trailing)
        }
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(topStackView.snp.bottom).offset(2)
            make.centerX.equalTo(detailButton)
        }
        detailImageView.snp.makeConstraints { make in
            make.width.equalTo(48.adjustedWidth)
            make.top.equalTo(topStackView.snp.bottom).offset(4.5)
            make.leading.equalTo(detailLabel.snp.trailing).inset(1)
        }
        detailButton.snp.makeConstraints { make in
            make.width.equalTo(72.adjustedWidth)
            make.height.equalTo(21.adjustedHeight)
            make.leading.equalTo(nameLabel.snp.trailing).offset(39)
        }
        toolTipView.snp.makeConstraints { make in
            make.width.equalTo(247.adjustedWidth)
            make.height.equalTo(39.adjustedHeight)
            make.top.equalToSuperview().offset(42)
            make.trailing.equalToSuperview()
        }
        middleStackView.snp.makeConstraints { make in
            make.width.equalTo(299.adjustedWidth)
            make.height.equalTo(62.adjustedHeight)
            make.top.equalTo(topStackView.snp.bottom)
            make.leading.equalToSuperview().offset(18)
        }
        lineView.snp.makeConstraints { make in
            make.height.equalTo(2.adjustedHeight)
            make.top.centerX.equalTo(middleStackView)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(8)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom)
        }
        bottomStackView.snp.makeConstraints { make in
            make.width.equalTo(299.adjustedWidth)
            make.height.equalTo(40.adjustedHeight)
            make.top.equalTo(middleStackView.snp.bottom).offset(8)
            make.centerX.equalTo(middleStackView)
            make.bottom.equalToSuperview().offset(18)
        }
        refuseButton.snp.makeConstraints { make in
            make.width.equalTo(146.adjustedWidth)
            make.height.equalTo(40.adjustedHeight)
        }
    }
    
    func divideSection() {
        switch sectionType {
        case .pill:
            iconImageView.image = Image.icPillAlarm
            [detailLabel, detailImageView, detailButton].forEach { $0.isHidden = false }
        case .calender:
            iconImageView.image = Image.icShareAlarm
            [detailLabel, detailImageView, detailButton].forEach { $0.isHidden = true }
        }
        switch statusType {
        case .waite:
            descriptionLabel.textColor = Color.gray700
            [topStackView, lineView, bottomStackView].forEach {
                contentView.addSubview($0)
                $0.isHidden = false
                middleStackView.sendSubviewToBack($0)
            }
        case .done:
            descriptionLabel.textColor = Color.gray600
            [topStackView, lineView, bottomStackView].forEach {
                $0.isHidden = true
                $0.removeFromSuperview()
            }
        }
    }
}
