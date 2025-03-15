//
//  RebornHistoryDetailViewController.swift
//  UMC-Reborn
//
//  Created by yeonsu on 2023/02/08.
//

import Foundation
import Alamofire
import CoreData

class RebornHistoryDetailViewController: UIViewController {
    
    var rebornIdx: Int = 0
    var rebornTaskIndex: Int = 0
    var timeLimit: String = ""
    
    var viewModel: RebornHistoryDetailViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var storeCategory: UILabel!
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDetail: UILabel!
    @IBOutlet weak var changeCode: UILabel!
    @IBOutlet weak var productAlert: UILabel!
    @IBOutlet weak var storeAddr: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var rebornContentView: UIView!
    
    var apiData: RebornHistoryDetailResponse!
    var rebornData: RebornCompleteresultModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.rebornContentView.layer.shadowColor = UIColor.gray.cgColor
        self.rebornContentView.layer.shadowOpacity = 0.1 //alpha값
        self.rebornContentView.layer.shadowRadius = 10 //반경
        self.rebornContentView.layer.shadowOffset = CGSize(width: 0, height: 10) //위치조정
        self.rebornContentView.layer.masksToBounds = false
        self.rebornContentView.layer.cornerRadius = 8;
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        viewModel = RebornHistoryDetailViewModel(container: appDelegate.persistentContainer)
        
        self.contentView.layer.cornerRadius = 10
        self.productImg.layer.cornerRadius = 10
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = "리본 히스토리"
        
        timerStart()
        
        getRebornHistoryDetail { result in
            switch result {
            case .success(let response):
                print("성공일까?")
                
                // 값 불러오기
                print("response is \(response)")
                guard let response = response as? RebornHistoryDetailModel else {
                    break
                }
                
                self.apiData = response.result
                
                
                let url = URL(string: self.apiData.storeImage)
                self.storeName.text = self.apiData.storeName
                self.status.text = self.apiData.status
                self.changeCode.text = "\(self.apiData.productExchangeCode)"
                self.productName.text = self.apiData.productName
                self.productAlert.text = self.apiData.productGuide
                self.productDetail.text = self.apiData.productComment
                self.productImg.load(url: url!)
                self.storeAddr.text = self.apiData.storeAddress
                self.storeCategory.text = self.apiData.category
                self.date.text = self.apiData.createdAt
                
            default:
                break
            }
        }
    }
    
    private func bindViewModel() {
        viewModel.$timeSecond
            .receive(on: DispatchQueue.main)
            .map { seconds -> String in
                let minutes = String(format: "%02d", seconds / 60)
                let sec = String(format: "%02d", seconds % 60)
                return "\(minutes):\(sec)"
            }
            .assign(to: \.text, on: timeLabel)
            .store(in: &cancellables)
    }

    @IBAction func FinishRebornTapped(_ sender: Any) {
        let exchangeCode = Int(changeCode.text ?? "") ?? 0
        let parameterDatas = RebornCompleteModel(rebornTaskIdx: rebornTaskIndex, productExchangeCode: exchangeCode)
        APIHandlerCompletePost.instance.SendingPostReborn(parameters: parameterDatas) { result in self.rebornData = result }

        
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController else { return }
        nextVC.modalPresentationStyle = .overCurrentContext
        self.present(nextVC, animated: true, completion: nil)
    }
    
    func getRebornHistoryDetail(completion: @escaping (NetworkResult<Any>) -> Void) {
        var RebornHistoryDetailUrl = "http://www.rebornapp.shop/reborns/history/detail/\(rebornTaskIndex)"
        print("rebornHistoryDetail의 taskIdx는 \(rebornTaskIndex)")


        let url: String! = RebornHistoryDetailUrl
        let header: HTTPHeaders = [
            "Content-type": "application/json"
            //                "jwt"
        ]
        
        let dataRequest = AF.request(
            url, method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: header
        )
        
        dataRequest.responseData { response in
            dump(response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                //                     dump(statusCode)
                // 여기 부분 수정 value
                guard let value = response.value else { return }
                //                     dump(value)
                let networkResult = self.judgeStatus(by: statusCode, value, RebornHistoryDetailModel.self)
                completion(networkResult)
                print("여기까지")
                
            case .failure:
                completion(.networkFail)
                print("여기서")
            }
        }
    }
    
    private func judgeStatus<T:Codable> (by statusCode: Int, _ data: Data, _ type: T.Type) -> NetworkResult<Any> {
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(type.self, from: data)
        else { print("decode fail")
            
            return .pathErr }

        switch statusCode {
        case 200 ..< 300: return .success(decodedData as Any)
        case 400 ..< 500: return .pathErr
        case 500: return .serverErr
        default: return .networkFail
        }
    }
}
