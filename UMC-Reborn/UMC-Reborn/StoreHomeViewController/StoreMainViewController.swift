//
//  StoreMainViewController.swift
//  UMC-Reborn
//
//  Created by jaegu park on 2023/01/13.
//

import UIKit

class StoreMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableArray = [[""], [""], [""]]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 171
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Main_TableViewCell") else {
            fatalError("셀이 존재하지 않습니다")
        }
        cell.textLabel?.text = self.tableArray[indexPath.section][indexPath.row]
        
        return cell
    }

    @IBOutlet weak var storemainView: UIView!
    @IBOutlet weak var storemainLabel: UILabel!
    @IBOutlet weak var StoreMainTableView: UITableView!
    @IBOutlet weak var wholeButton: UIButton!
    @IBOutlet weak var goingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storemainView.clipsToBounds = true
        storemainView.layer.cornerRadius = 20
        storemainView.layer.masksToBounds = false
        storemainView.layer.shadowOffset = CGSize(width: 3, height: 8)
        storemainView.layer.shadowRadius = 20
        storemainView.layer.shadowOpacity = 0.1
        
        wholeButton.setTitleColor(UIColor(red: 64/255, green: 49/255, blue: 35/255, alpha: 1), for: .selected)
        
        let attributedString = NSMutableAttributedString(string: storemainLabel.text!, attributes: [
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: UIColor(white: 0.0, alpha: 1.0),
            .kern: -0.01
        ])
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: (storemainLabel.text! as NSString).range(of: "다시 태어나게"))
        
        self.storemainLabel.attributedText = attributedString
        
        StoreMainTableView.delegate = self
        StoreMainTableView.dataSource = self
        StoreMainTableView.rowHeight = UITableView.automaticDimension
        StoreMainTableView.estimatedRowHeight = UITableView.automaticDimension
        StoreMainTableView.contentInset = .zero
        StoreMainTableView.contentInsetAdjustmentBehavior = .never
    }
}
