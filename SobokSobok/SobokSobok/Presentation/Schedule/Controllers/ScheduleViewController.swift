//
//  ScheduleViewController.swift
//  SobokSobok
//
//  Created by taehy.k on 2022/05/18.
//

import UIKit
import FSCalendar

final class ScheduleViewController: BaseViewController {
    
    // MARK: - Properties
    
    let scheduleManager: ScheduleServiceable = ScheduleManager(apiService: APIManager(), environment: .development)
    let stickerManageer: StickerServiceable = StickerManager(apiService: APIManager(), environment: .development)
    
    let gregorian = Calendar(identifier: .gregorian)
    var friendName: String? { didSet { updateUI() } }

    var schedules: [Schedule] = [] {
        didSet {
            parseSchedules()
        }
    }
    
    var doingDates: [String] = []
    var doneDates: [String] = []
    
    var pillLists: [PillList] = [] {
        didSet {
            dataSource.update(with: pillLists)
            collectionView.reloadData()
        }
    }

    var currentDate: Date = Date() {
        didSet {
            fetchSchedules(for: scheduleType)
            fetchPillLists(for: scheduleType)
        }
    }

    var calendarHeight: CGFloat = 308.0.adjustedHeight
    var collectionViewHeight: CGFloat = 409.0.adjustedHeight
    var collectionViewBottomInset: CGFloat = 32.0.adjustedHeight
    
    private var scheduleType: ScheduleType
    private lazy var dataSource = ScheduleDataSource(
        pillSchedules: pillLists,
        scheduleType: scheduleType,
        viewController: self
    )
    
    var stickers: [Stickers] = []
    
    
    // MARK: - Initializer

    
    init(scheduleType: ScheduleType) {
        self.scheduleType = scheduleType
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - UI Components
    
    lazy var scrollView = UIScrollView()
    lazy var stackView = UIStackView()
    lazy var friendNameView = FriendNameView()
    lazy var calendarTopView = CalendarTopView()
    lazy var calendarView = FSCalendar()
    lazy var collectionView = DynamicHeightCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    )

    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchSchedules(for: scheduleType)
        fetchPillLists(for: scheduleType)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setCollectionViewHeight()
    }

    
    // MARK: - Overriding Functions
    
    override func style() {
        configureInitialSetup()
    }
    
    override func hierarchy() {
        view.addSubviews(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubviews(
            friendNameView, calendarTopView, calendarView, collectionView
        )
    }
    
    override func layout() {
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        friendNameView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        calendarTopView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        calendarView.snp.makeConstraints {
            // calendar left, right padding 10씩 조정하기
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(calendarHeight)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.height.equalTo(collectionViewHeight)
        }
    }
}


// =============================================
// MARK: - Initial Setup
// =============================================

extension ScheduleViewController {
    
    private func configureInitialSetup() {
        
        configureAttributes()
        registerCells()
        setCalendar()
        setCalendarStyle()
        setDelegation()
        addObservers()
    }
    
    private func configureAttributes() {
        
        scrollView.do {
            $0.showsVerticalScrollIndicator = false
            $0.backgroundColor = Color.gray150
        }
        
        stackView.do {
            $0.backgroundColor = .systemBackground
            $0.axis = .vertical
            $0.distribution = .fill
            $0.alignment = .center
        }
        
        friendNameView.do {
            $0.isHidden = scheduleType == .main
            $0.friendNameLabel.text = friendName
            
        }
        
        calendarTopView.do {
            $0.dateLabel.text = calendarTopView.scopeState == .week ? currentDate.toString(of: .day) : currentDate.toString(of: .month)
        }
        
        collectionView.do {
            $0.backgroundColor = Color.gray150
            $0.collectionViewLayout = self.generateLayout()
        }
    }
    
    // MARK: - CollectionView
    
    private func registerCells() {
        
        calendarView.register(
            CalendarDayCell.self,
            forCellReuseIdentifier: CalendarDayCell.reuseIdentifier
        )
        
        collectionView.register(
            MainScheduleCell.self,
            forCellWithReuseIdentifier: MainScheduleCell.reuseIdentifier
        )
        
        collectionView.register(
            ShareScheduleCell.self,
            forCellWithReuseIdentifier: ShareScheduleCell.reuseIdentifier
        )
        
        collectionView.register(
            ScheduleHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ScheduleHeaderView.reuseIdentifier
        )
    }
    
    // MARK: - Calendar
    
    func setCalendar() {
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.headerHeight = 0
        calendarView.firstWeekday = 2
        calendarView.setScope(.week, animated: false)
        calendarView.select(Date())
    }
    
    func setCalendarStyle() {
        calendarView.appearance.weekdayFont = TypoStyle.body7.font
        calendarView.appearance.weekdayTextColor = Color.gray600
        calendarView.appearance.titleFont = UIFont.font(.pretendardRegular, ofSize: 16)
        calendarView.appearance.titleDefaultColor = Color.black
        calendarView.appearance.titleTodayColor = Color.black
        calendarView.appearance.todayColor = .clear
        calendarView.placeholderType = .none
    }
    
    // MARK: - Delegation
    
    private func setDelegation() {
        scrollView.delegate = self
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarTopView.delegate = self
        collectionView.dataSource = dataSource
    }
}


// =============================================
// MARK: - UI
// =============================================

extension ScheduleViewController {
    
    private func updateUI() {
        friendNameView.isHidden = friendName == nil ? true : false
        friendNameView.friendNameLabel.text = friendName
        calendarTopView.dateLabel.text = calendarTopView.scopeState == .week ? currentDate.toString(of: .day) : currentDate.toString(of: .month)
    }
    
    // TODO: - 높이 문제 해결 필요
    
    func setCollectionViewHeight() {
        var newCollectionViewHeight = pillLists.isEmpty ? 409.0 : collectionView.contentSize.height
        newCollectionViewHeight = newCollectionViewHeight < 409.0 ? 409.0 : newCollectionViewHeight
        if newCollectionViewHeight > 0 {
            collectionViewHeight = newCollectionViewHeight
            collectionView.snp.updateConstraints {
                $0.height.equalTo(collectionViewHeight + collectionViewBottomInset)
            }
        }
    }
}


// =============================================
// MARK: - Observing
// =============================================

extension ScheduleViewController {
    
    private func addObservers() {
        showAllStickerObserver()
        sendStickerObserver()
    }
    
    private func removeObservers() {
        Notification.Name.showAllSticker.removeObserver(observer: self)
        Notification.Name.sendSticker.removeObserver(observer: self)
    }
    
    func showAllStickerObserver() {
        Notification.Name.showAllSticker.addObserver { notification in
            if let notification = notification.userInfo,
               let scheduleId = notification["scheduleId"] as? Int {
                self.getStickers(for: scheduleId) { [weak self] in
                    self?.showStickerBottomSheet(stickers: self?.stickers)
                }
            }
        }
    }
    
    func sendStickerObserver() {
        if scheduleType == .share {
            Notification.Name.sendSticker.addObserver { [weak self] notification in
                guard let self = self else { return }
                
                if let notification = notification.userInfo,
                   let isLikedState = notification["isLikedState"] as? Bool,
                   let scheduleId = notification["scheduleId"] as? Int,
                   let likeScheduleId = notification["likeScheduleId"] as? Int,
                   let stickerId = notification["stickerId"] as? Int
                {
                    if isLikedState {
                        print("✂️ 호출")
                        self.changeSticker(for: likeScheduleId, withSticker: stickerId) { [weak self] in
                            guard let self = self else { return }
                            self.getMemberPillLists(memberId: 187, date: self.currentDate.toString(of: .year))
                        }
                    }
                    else {
                        print("🛳 호출")
                        self.postSticker(for: scheduleId, withSticker: stickerId) { [weak self] in
                            guard let self = self else { return }
                            self.getMemberPillLists(memberId: 187, date: self.currentDate.toString(of: .year))
                        }
                    }
                }
            }
        }
    }
}


// =============================================
// MARK: - Network Call
// =============================================

extension ScheduleViewController {

    private func fetchSchedules(for type: ScheduleType) {
        switch type {
        case .main:
            getMySchedules(date: currentDate.toString(of: .year))
            
        case .share:
            getMemberSchedules(memberId: 187, date: currentDate.toString(of: .year))
        }
    }
    
    private func fetchPillLists(for type: ScheduleType) {
        switch type {
        case .main:
            getMyPillLists(date: currentDate.toString(of: .year))
            
        case .share:
            getMemberPillLists(memberId: 187, date: currentDate.toString(of: .year))
        }
    }

    func parseSchedules() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = FormatType.full.description

        let doneItems = schedules
            .filter { $0.isComplete == "done" }
            .map { dateFormatter.date(from: $0.scheduleDate)!.toString(of: .year) }
        let doingItems = schedules
            .filter { $0.isComplete == "doing" }
            .map { dateFormatter.date(from: $0.scheduleDate)!.toString(of: .year) }
        
        self.doneDates = doneItems
        self.doingDates = doingItems
        
        calendarView.reloadData()
    }
}


// =============================================
// MARK: - Transition
// =============================================

extension ScheduleViewController {
    
    func editFriendName() {
        friendNameView.completion = {
            let editFriendNameViewController = EditFriendNameViewController.instanceFromNib()
            editFriendNameViewController.modalPresentationStyle = .fullScreen
            self.present(editFriendNameViewController, animated: true)
        }
    }
    
    func showStickerBottomSheet(stickers: [Stickers]?) {
        let stickerBottomSheet = StickerBottomSheet()
        stickerBottomSheet.modalPresentationStyle = .overCurrentContext
        stickerBottomSheet.modalTransitionStyle = .crossDissolve
        stickerBottomSheet.stickers = stickers
        self.tabBarController?.present(stickerBottomSheet, animated: false) {
            stickerBottomSheet.showSheetWithAnimation()
        }
    }
    
    func showStickerPopUp(scheduleId: Int, isLikedSchedule: Bool, likeScheduleId: Int) {
        let stickerPopUpView = SendStickerPopUpViewController.instanceFromNib()
        stickerPopUpView.modalPresentationStyle = .overCurrentContext
        stickerPopUpView.modalTransitionStyle = .crossDissolve
        stickerPopUpView.scheduleId = scheduleId
        stickerPopUpView.likeScheduleId = likeScheduleId
        stickerPopUpView.isLikedState = isLikedSchedule
        self.present(stickerPopUpView, animated: false, completion: nil)
    }
}


// =============================================
// MARK: - Delegate
// =============================================


// MARK: - UIScrollViewDelegate

extension ScheduleViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.bounces = scrollView.contentOffset.y > 0
        scrollView.backgroundColor = scrollView.contentOffset.y > 0 ? Color.gray150 : Color.white
    }
}


// MARK: - CalendarTopViewDelegate

extension ScheduleViewController: CalendarTopViewDelegate {
    
    func calendarTopView(scope: CalendarScopeState) {
        calendarView.setScope(scope == .week ? .week : .month, animated: true)
        calendarTopView.scopeButton.setTitle(scope == .week ? "주" : "월", for: .normal)
        calendarTopView.scopeButton.setImage(scope == .week ? Image.icArrowDropDown16 : Image.icArrowUp16, for: .normal)
        calendarTopView.dateLabel.text = scope == .week ? currentDate.toString(of: .day) : currentDate.toString(of: .month)
    }
}


// MARK: - MainScheduleCellDelegate

extension ScheduleViewController: MainScheduleCellDelegate {
    
    func checkButtonTapped(_ cell: MainScheduleCell) {
        guard let scheduleId = cell.pill?.scheduleId else { return }
        
        if cell.isChecked {
            showAlert(
                title: "복약하지 않은 약인가요?",
                message: "복약을 취소하면 소중한 사람들의 응원도 같이 삭제되어요",
                completionTitle: "복약 취소",
                cancelTitle: "취소"
            ) { [weak self] _ in
                cell.isChecked.toggle()
                self?.uncheckPillSchedule(scheduleId: scheduleId) {
                    self?.fetchSchedules(for: .main)
                    self?.calendarView.reloadData()
                }
            }
        }
        else {
            cell.isChecked.toggle()
            self.checkPillSchedule(scheduleId: scheduleId) {
                self.fetchSchedules(for: .main)
                self.calendarView.reloadData()
            }
        }
    }
}
