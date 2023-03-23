//
//  SecondMainViewController.swift
//  UMC-Reborn
//
//  Created by jaegu park on 2023/01/26.
//

import UIKit

class SecondMainViewController: UIViewController {
    
    var secondMain = UserDefaults.standard.integer(forKey: "userIdx")
    
    var storesecondText: Int = 0
    
    var rebornGoingDatas: [RebornStatusListModel] = []
    var rebornData: RebornCancelresultModel!

    @IBOutlet weak var StoreSecondtableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        StoreSecondtableView.delegate = self
        StoreSecondtableView.dataSource = self
        StoreSecondtableView.rowHeight = UITableView.automaticDimension
        StoreSecondtableView.estimatedRowHeight = UITableView.automaticDimension
        StoreSecondtableView.contentInset = .zero
        StoreSecondtableView.contentInsetAdjustmentBehavior = .never
        StoreSecondtableView.layer.masksToBounds = true // any value you want
        StoreSecondtableView.layer.shadowOpacity = 0.1// any value you want
        StoreSecondtableView.layer.shadowRadius = 10 // any value you want
        StoreSecondtableView.layer.shadowOffset = .init(width: 5, height: 10)
        
        rebornGoingResult()
        
        NotificationCenter.default.addObserver(
                  self,
                  selector: #selector(self.didDismissDetailNotification(_:)),
                  name: NSNotification.Name("DismissDetailView3"),
                  object: nil
                  )
        
        NotificationCenter.default.addObserver(
                  self,
                  selector: #selector(self.didDismissDetailNotification(_:)),
                  name: NSNotification.Name("DismissDetailView9"),
                  object: nil
                  )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.rebornGoingResult()
        }
    }
    
    @objc func didDismissDetailNotification(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.rebornGoingResult()
        }
    }
    
    func rebornGoingResult() {
        
        let url = APIConstants.baseURL + "/reborns/store/page/\(String(secondMain))/status?status=ACTIVE"
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
                    let decodedData = try JSONDecoder().decode(RebornStatusList.self, from: safeData)
                    self.rebornGoingDatas = decodedData.result
                    print(rebornGoingDatas)
                    DispatchQueue.main.async {
                        self.StoreSecondtableView.reloadData()
                        print("count: \(self.rebornGoingDatas.count)")
                        
                    }
                } catch {
                    print("Error")
                }
            }
        }.resume()
    }
}
