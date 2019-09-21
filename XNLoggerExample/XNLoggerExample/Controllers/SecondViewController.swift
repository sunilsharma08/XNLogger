//
//  SecondViewController.swift
//  XNLoggerExample
//
//  Created by Sunil Sharma on 19/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import UIKit
import XNLogger

class SecondViewController: UIViewController {

    var customLogger: CustomLogger? = CustomLogger()
    var controller: NetworkExamplesViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("beforeee adding")
        print(CFGetRetainCount(customLogger))
        
        if let logger = customLogger {
//            weak var weakLogger = customLogger
            XNLogger.shared.addLogHandlers([logger])
        }
        
        print("after adding")
        print(CFGetRetainCount(customLogger))
        controller?.logger = customLogger
        print("after assign")
        print(CFGetRetainCount(customLogger))
//        if let logger = customLogger {
//            NetworkLogger.shared.removeHandlers([logger])
//        }
//        customLogger = nil
//        customLogger = nil
        
        

    }
    

    deinit {
        print("Second View Controller")
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
