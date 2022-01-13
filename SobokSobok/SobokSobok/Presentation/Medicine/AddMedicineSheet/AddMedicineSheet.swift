//
//  AddMedicineSheet.swift
//  SobokSobok
//
//  Created by 김승찬 on 2022/01/09.
//

import UIKit

import EasyKit

protocol AddMedicineSheetDismiss: AnyObject {
    func addMedicineSheetdismiss()
}

final class AddMedicineSheet: BaseViewController {

    // MARK: Properties
    
    weak var delegate: AddMedicineSheetDismiss?
    private let targetListForMedicine = [
        (image: Image.icMyFillPlus, text: "내 약 추가"),
        (image: Image.icFillSend, text: "다른 사람에게 약 전송")
    ]
 
    // MARK: @IBOutlet Properties
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var medicineTableView: UITableView!
    @IBOutlet var sheetHeight: NSLayoutConstraint!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignDelegation()
    }
    
    override func style() {
        super.style()
        mainView.makeRounded(radius: 20)
        sheetHeight.constant = 0
    }
    // MARK: - Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true) {
            self.delegate?.addMedicineSheetdismiss()
        }
    }
    
    func assignDelegation() {
        medicineTableView.dataSource = self
        medicineTableView.delegate = self
        medicineTableView.register(AddMedicineTableViewCell.self)
    }
    
    func sheetWithAnimation() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.sheetHeight.constant = 258
            self?.view.layoutIfNeeded()
        }
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.addMedicineSheetdismiss()
        }
    }
}

// MARK: - UITableViewDelegate
extension AddMedicineSheet: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource

extension AddMedicineSheet: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targetListForMedicine.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let medicineCell = medicineTableView.dequeueReusableCell(for: indexPath, cellType: AddMedicineTableViewCell.self)
        // 셀이 선택 되었을 때 배경색 변하지 않게
        medicineCell.selectionStyle = .none
        
        medicineCell.medicineImageView.image = targetListForMedicine[indexPath.row].image
        medicineCell.medicineTextLabel.text = targetListForMedicine[indexPath.row].text
        return medicineCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 추후에 나머지 뷰 만들면 연결 예정
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
}
