//
//  EditStoreViewController.swift
//  UMC-Reborn
//
//  Created by jaegu park on 2023/01/14.
//
import Foundation
import UIKit
import Alamofire
import DropDown

class EditStoreViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, SampleProtocol4 {
    
    var editStore = UserDefaults.standard.integer(forKey: "userIdx")
    
    var storeCategory : String = ""
    
    var storecategory = [" 카페·디저트", " 반찬", " 패션", " 편의·생활", " 기타"]
    
    var imageUrl: ImageresultModel!
    var rebornData: StoreEditresultModel!
    
    func addressSend(data: String) {
        storeaddressTextfield.text = data
        storeaddressTextfield.sizeToFit()
    }
    
    var defaultImage : String = ""
    
    let dropdown = DropDown()
    
    @IBOutlet weak var storenameTextfield: UITextField!
    @IBOutlet weak var storecategoryTextfield: UITextField!
    @IBOutlet weak var storeaddressTextfield: UITextField!
    @IBOutlet weak var storeTextView: UITextView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var StoreImageView: UIImageView!
    
    let serverURL = "http://www.rebornapp.shop/s3"
    
    let imagePickerController = UIImagePickerController()
    let alertController = UIAlertController(title: "가게 대표 사진 설정", message: "", preferredStyle: .actionSheet)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        
        StoreImageView.layer.cornerRadius = 10
        StoreImageView.clipsToBounds = true
        
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
        
        initUI()
        setDropdown()
        
        enrollAlertEvent()
        self.imagePickerController.delegate = self
        addGestureRecognizer()
        
        storeResult()
        
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func initUI() {
        DropDown.appearance().textColor = UIColor.black // 아이템 텍스트 색상
        DropDown.appearance().selectedTextColor = UIColor(red: 255/255, green: 77/255, blue: 21/255, alpha: 1) // 선택된 아이템 텍스트 색상
        DropDown.appearance().backgroundColor = UIColor.white // 아이템 팝업 배경 색상
        DropDown.appearance().selectionBackgroundColor = UIColor.white // 선택한 아이템 배경 색상
        DropDown.appearance().setupCornerRadius(10)
            dropdown.dismissMode = .automatic // 팝업을 닫을 모드 설정
        DropDown.appearance().textFont = UIFont(name: "AppleSDGothicNeo-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
    }
    
    func setDropdown() {
        // dataSource로 ItemList를 연결
        dropdown.dataSource = storecategory
        dropdown.cellHeight = 45
        // anchorView를 통해 UI와 연결
        dropdown.anchorView = self.storecategoryTextfield
        
        // View를 갖리지 않고 View아래에 Item 팝업이 붙도록 설정
        dropdown.bottomOffset = CGPoint(x: 0, y: storecategoryTextfield.bounds.height)
        
        // Item 선택 시 처리
        dropdown.selectionAction = { [weak self] (index, item) in
            //선택한 Item을 TextField에 넣어준다.
            self!.storecategoryTextfield.text = " \(item)"
        }
        
        // 취소 시 처리
        dropdown.cancelAction = { [weak self] in
        }
    }
    
    @IBAction func showPicker(_ sender: Any) {
        dropdown.show()
    }
    
    @IBAction func addressButton(_ sender: Any) {
        guard let svc2 = self.storyboard?.instantiateViewController(identifier: "StoreAddressViewController") as? StoreAddressViewController else {
            return
        }
        svc2.delegate = self
        
        self.present(svc2, animated: true)
    }
    
    func storeResult() {
        
        let url = APIConstants.baseURL + "/store/\(String(editStore))"
        let encodedStr = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: encodedStr) else { print("err"); return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { [self] data, response, error in
            if error != nil {
                print("err")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~=
            response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            
            if let safeData = data {
                print(String(decoding: safeData, as: UTF8.self))
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedData = try decoder.decode(StoreList.self, from: safeData)
                    let storeDatas = decodedData.result
                    print(storeDatas)
                    DispatchQueue.main.async {
                        let url = URL(string: storeDatas.userImage ?? "")
                        self.StoreImageView.load(url: url!)
                        self.storenameTextfield.text = "\(storeDatas.storeName)"
                        if (storeDatas.category == "CAFE") {
                            self.storecategoryTextfield.text = "카페·디저트"
                        } else if (storeDatas.category == "FASHION") {
                            self.storecategoryTextfield.text = "패션"
                        } else if (storeDatas.category == "SIDEDISH") {
                            self.storecategoryTextfield.text = "반찬"
                        } else if (storeDatas.category == "LIFE") {
                            self.storecategoryTextfield.text = "편의·생활"
                        } else {
                            self.storecategoryTextfield.text = "기타"
                        }
                        self.storeCategory = storeDatas.category
                        self.storeaddressTextfield.text = "\(storeDatas.storeAddress)"
                        self.storeTextView.text = "\(storeDatas.storeDescription)"
                        self.storeTextView.textColor = UIColor.black
                        self.defaultImage = storeDatas.userImage ?? ""
                    }
                } catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
            }
        }.resume()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("DismissDetailView8"), object: nil, userInfo: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let parameterDatas = StoreEditModel(storeName: storenameTextfield.text ?? "", storeAddress: storeaddressTextfield.text ?? "", storeDescription: storeTextView.text, category: storeCategory, storeImage: defaultImage)
        APIHandlerStorePost.instance.SendingPostReborn(storeId: editStore, parameters: parameterDatas) { result in self.rebornData = result }
        self.navigationController?.popViewController(animated: true)
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
    
    func enrollAlertEvent() {
        let photoLibraryAlertAction = UIAlertAction(title: "앨범에서 사진 선택", style: .default) {
            (action) in
            self.openAlbum() // 아래에서 설명 예정.
        }
        
        let cameraAlertAction = UIAlertAction(title: "사진 촬영", style: .default) {
            (action) in
            self.openCamera() // 아래에서 설명 예정.
        }
        
        let cancelAlertAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        self.alertController.addAction(photoLibraryAlertAction)
        self.alertController.addAction(cameraAlertAction)
        self.alertController.addAction(cancelAlertAction)
        guard let alertControllerPopoverPresentationController = alertController.popoverPresentationController
        else {return}
        prepareForPopoverPresentation(alertControllerPopoverPresentationController)
    }
    
    func addGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedUIImageView(_gesture:)))
        self.StoreImageView.addGestureRecognizer(tapGestureRecognizer)
        self.StoreImageView.isUserInteractionEnabled = true
    }
    
    @objc func tappedUIImageView(_gesture: UITapGestureRecognizer) {
        self.present(alertController, animated: true, completion: nil)
    }
    
    class DiaryPost {
        static let instance = DiaryPost()
        
        func uploadDiary(file: UIImage, url: String, handler: @escaping (_ result: ImageresultModel)->(Void)) {
            let headers: HTTPHeaders = [
                                "Content-type": "multipart/form-data"
                            ]
            AF.upload(multipartFormData: { (multipart) in
                if let imageData = file.jpegData(compressionQuality: 0.8) {
                    multipart.append(imageData, withName: "file", fileName: "photo.jpg", mimeType: "image/jpeg")
                }
            }, to: url ,method: .post ,headers: headers).response { responce in
                switch responce.result {
                case .success(let data):
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed)
                        print(json)
                        
                        let jsonresult = try JSONDecoder().decode(ImageresultModel.self, from: data!)
                        handler(jsonresult)
                        print(jsonresult)
                    } catch {
                        print(error.localizedDescription)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension EditStoreViewController: UIPopoverPresentationControllerDelegate {
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        if let popoverPresentationController = self.alertController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
    }
}

extension EditStoreViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openAlbum() {
        self.imagePickerController.sourceType = .photoLibrary
        present(self.imagePickerController, animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            StoreImageView?.image = image
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                DiaryPost.instance.uploadDiary(file: self.StoreImageView.image!, url: self.serverURL) { result in self.imageUrl = result }
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                self.defaultImage = self.imageUrl.result
            }
        } else {
            print("error detected in didFinishPickinMEdiaWithInfo method")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func openCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            self.imagePickerController.sourceType = .camera
            present(self.imagePickerController, animated: false, completion: nil)
        } else {
            print("Camera is not available as for now")
        }
    }
}


