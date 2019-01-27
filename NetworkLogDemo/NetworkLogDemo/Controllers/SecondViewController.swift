//
//  SecondViewController.swift
//  NetworkLogDemo
//
//  Created by Sunil Sharma on 19/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func clickedOnBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickedOnLoadData(_ sender: Any) {
        getDataFromServer()
    }
    
    func getDataFromServer() {
        let request = URLRequest(url: URL(string: "https://gorest.co.in/public-api/users")!)
        
        let session = URLSession.shared
        session.dataTask(with: URL(string: "https://gorest.co.in/public-api/users")!) { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as! [String: Any]
                print("SVC response data \n \(json)")
            } catch {
                print("SVC Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    

}
