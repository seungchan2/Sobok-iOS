//
//  HomeViewController.swift
//  SobokSobok
//
//  Created by taehy.k on 2022/01/11.
//

import UIKit

final class HomeViewController: BaseViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setCollectionView()
        registerXibs()
        showActionSheet()
    }
    
    private func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = Color.gray150
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 32, right: 0)
    }
    
    private func registerXibs() {
        let nib = UINib(nibName: TimeHeaderView.nibName, bundle: nil)
        collectionView.register(nib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TimeHeaderView.reuseIdentifier)
        collectionView.register(MedicineCollectionViewCell.self)
    }
    
    private func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "약 수정", style: .default) { _ in }
        let stopAction = UIAlertAction(title: "복약 중단", style: .default) { _ in }
        let deleteAction = UIAlertAction(title: "약 삭제", style: .default) { _ in }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        actionSheet.addAction(editAction)
        actionSheet.addAction(stopAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }
}

typealias CollectionViewDelegate = UICollectionViewDelegate & UICollectionViewDataSource

extension HomeViewController: CollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MedicineCollectionViewCell.self)
        cell.contentView.backgroundColor = Color.white
        cell.contentView.makeRounded(radius: 12)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TimeHeaderView.reuseIdentifier,
                for: indexPath
            ) as? TimeHeaderView else { return UICollectionReusableView() }
            if indexPath.section == 0 {
                headerView.editButtonStackView.isHidden = false
            } else {
                headerView.editButtonStackView.isHidden = true
            }
            return headerView
        default:
            assert(false, "헤더 뷰 찾을 수 없음")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = collectionView.frame.width
        let height: CGFloat = 77
        return CGSize(width: width, height: height)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let width = 335 / 375 * screenWidth
        let height = width * 140 / 335
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}
