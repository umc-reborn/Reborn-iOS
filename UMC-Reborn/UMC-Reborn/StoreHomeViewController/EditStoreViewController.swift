//
//  EditStoreViewController.swift
//  UMC-Reborn
//
//  Created by jaegu park on 2023/01/14.
//

import UIKit

class EditStoreViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var storecategory = [" 카페·디저트", " 반찬", " 패션", " 편의·생활", " 기타"]
    let picker = UIPickerView()
    
    @IBOutlet weak var storenameTextfield: UITextField!
    @IBOutlet weak var storecategoryTextfield: UITextField!
    @IBOutlet weak var storeaddressTextfield: UITextField!
    @IBOutlet weak var storeTextView: UITextView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var StoreImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StoreImageView.layer.cornerRadius = 10
        StoreImageView.clipsToBounds = true

        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)]
        
        storenameTextfield.layer.cornerRadius = 5
        storenameTextfield.layer.borderWidth = 1
        storenameTextfield.layer.borderColor = UIColor.gray.cgColor
        storecategoryTextfield.layer.cornerRadius = 5
        storecategoryTextfield.layer.borderWidth = 1
        storecategoryTextfield.layer.borderColor = UIColor.gray.cgColor
        storeaddressTextfield.layer.cornerRadius = 5
        storeaddressTextfield.layer.borderWidth = 1
        storeaddressTextfield.layer.borderColor = UIColor.gray.cgColor
        storeTextView.layer.cornerRadius = 5
        storeTextView.layer.borderWidth = 1
        storeTextView.layer.borderColor = UIColor.gray.cgColor
        
        placeholderSetting()
        textViewDidBeginEditing(storeTextView)
        textViewDidEndEditing(storeTextView)
        storenameTextfield.delegate = self
        storecategoryTextfield.delegate = self
        storeaddressTextfield.delegate = self
        textFieldDidBeginEditing(storenameTextfield)
        textFieldDidEndEditing(storenameTextfield)
        textFieldDidBeginEditing(storecategoryTextfield)
        textFieldDidEndEditing(storecategoryTextfield)
        textFieldDidBeginEditing(storeaddressTextfield)
        textFieldDidEndEditing(storeaddressTextfield)
        
        configPickerView()
        configToolbar()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
           // textField.borderStyle = .line
        textField.layer.borderColor = UIColor(red: 255/255, green: 77/255, blue: 21/255, alpha: 1).cgColor//your color
            textField.layer.borderWidth = 1.0
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
            textField.layer.borderColor = UIColor.gray.cgColor
            textField.layer.borderWidth = 1.0
    }
    
    func placeholderSetting() {
        storeTextView.delegate = self // txtvReview가 유저가 선언한 outlet
        storeTextView.text = " 사장님의 가게를 소개해 주세요!"
        storeTextView.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15.0)
        storeTextView.textColor = UIColor.systemGray
    }
        // TextView Place Holder
    @objc func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.systemGray {
            textView.text = nil
            textView.textColor = UIColor.black
            textView.layer.borderColor = UIColor.init(red: 255/255, green: 77/255, blue: 21/255, alpha: 1).cgColor
        }
    }
        // TextView Place Holder
    @objc func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = " 사장님의 가게를 소개해 주세요!"
            textView.textColor = UIColor.systemGray
        }
        textView.layer.borderColor = UIColor.gray.cgColor
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = storeTextView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        countLabel.text = "\(changedText.count)/50"
        return changedText.count < 50
    }
}

extension EditStoreViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func configPickerView() {
        picker.delegate = self
        picker.dataSource = self
        storecategoryTextfield.inputView = picker
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        storecategory.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return storecategory[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.storecategoryTextfield.text = self.storecategory[row]
    }
    
    func configToolbar() {
        // toolbar를 만들어준다.
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.white
        toolBar.sizeToFit()
        
        // 만들어줄 버튼
        // flexibleSpace는 취소~완료 간의 거리를 만들어준다.
        let doneBT = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(self.donePicker))
        doneBT.tintColor = UIColor(red: 255/255, green: 77/255, blue: 21/255, alpha: 1)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelBT = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(self.cancelPicker))
        cancelBT.tintColor = UIColor(red: 255/255, green: 77/255, blue: 21/255, alpha: 1)
        
        // 만든 아이템들을 세팅해주고
        toolBar.setItems([cancelBT,flexibleSpace,doneBT], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        // 악세사리로 추가한다.
        storecategoryTextfield.inputAccessoryView = toolBar
    }
    
    @objc func donePicker() {
        let row = self.picker.selectedRow(inComponent: 0)
        self.picker.selectRow(row, inComponent: 0, animated: false)
        self.storecategoryTextfield.text = self.storecategory[row]
        self.storecategoryTextfield.resignFirstResponder()
    }

    // "취소" 클릭 시 textfield의 텍스트 값을 nil로 처리 후 입력창 내리기
    @objc func cancelPicker() {
        self.storecategoryTextfield.text = nil
        self.storecategoryTextfield.resignFirstResponder()
    }
}
