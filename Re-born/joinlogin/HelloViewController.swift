//
//  HelloViewController.swift
//  UMC-Reborn
//
//  Created by 김예린 on 2023/01/28.
//

import UIKit

class HelloViewController: UIViewController {
    
    @IBOutlet weak var startRebornButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mybrown = UIColor(named: "mybrown")
        let myorange = UIColor(named: "myorange")
        
        // back button custom
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
        
        self.navigationController?.navigationBar.backgroundColor = myorange
        
        startRebornButton.backgroundColor = .mybrown
        startRebornButton.layer.cornerRadius = 4.0
        startRebornButton.layer.borderWidth = 1.0
        startRebornButton.layer.borderColor = mybrown?.cgColor // 테두리 컬러
    }
    
    @IBAction func startRebornButton(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "JoinLogin", bundle: nil)
        guard let nextVC = storyboard.instantiateViewController(identifier: "tVersionViewController") as? tVersionViewController else { return }
        
        self.navigationController?.pushViewController(nextVC, animated: true)
        
    }
}
