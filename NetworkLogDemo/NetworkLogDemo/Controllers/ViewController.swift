//
//  ViewController.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 14/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import UIKit


enum RequestType {
    case url
    case urlRequest
}

class Model:Codable {
    var nname:String = "Hello"
}

class ViewController: UIViewController {
    
    var urlRequestTest:URLRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
//        register()
        
//        overloadingTest(vari: OneProto())
//        overloadingTest(vari: TwoProto())
//        let testInstance = TestClass()
//        let selector = #selector((TestClass.overloadingTest(with:)) as (TestClass) -> (URL) -> Void)
//        let selector2 = #selector((TestClass.overloadingTest(with:)) as (TestClass) -> (URLRequest) -> Void)
//        perform(selector)
//        perform(selector2)
//        URLProtocol.registerClass(CustomUrlProtocol.self)
//        URLProtocol.registerClass(CustomUrlProtocol.self)
//        URLProtocol.registerClass(CustomUrlProtocol.self)
//        let status = URLProtocol.registerClass(CustomUrlProtocol.self)
//        print("register status \(status)")
//        print(URLSessionConfiguration.default.protocolClasses)
        
        let classes = URLSessionConfiguration.default.protocolClasses
        for cls in classes ?? []{
            let className = cls.description()
            if className == "NFXProtocol" {
                print("Woh")
            }
            print(className)
        }
    }
    
    /**
     Print all environment variables key and value available.
     */
    func logEnvironmentVariables() {
        for (key, value) in ProcessInfo.processInfo.environment {
            print("\(key) => \(value)")
        }
    }
    
    func loadDataFromServer() {
        var urlRequest = URLRequest(url: URL(string: "https://gorest.co.in/public-api/users")!)
        urlRequest.addValue("Bearer ggolvSv4UpUH_a9Qk5x5KAC2YudbptpltVYZ", forHTTPHeaderField: "Authorization")
        let session = URLSession(configuration: .default)
        
//        let session = URLSession(configuration: .background(withIdentifier: "123"), delegate: self, delegateQueue: nil)
//        session.dataTask(with: urlRequest).resume()
        
        session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            do {
                let response = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                print("Response \n \(String(describing: response))")
            } catch {
                print(error.localizedDescription)
            }
            print(urlResponse ?? "")
        }.resume()
    }
    
    func swizzleDataTask() {
        let instance = URLSession(configuration: .default)
        let urlSessionClass:AnyClass = object_getClass(instance)!
        let selector = #selector((URLSession.dataTask(with:completionHandler:)) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        let fakeMethodSelector = #selector((URLSession.fakedataTask(with:completionHandler:)) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        
        let originalMethod = class_getInstanceMethod(urlSessionClass, selector)!
        let fakeMethod = class_getInstanceMethod(URLSession.self, fakeMethodSelector)!
        method_exchangeImplementations(originalMethod, fakeMethod)
        
        let selector2 = #selector((URLSession.dataTask(with:completionHandler:)) as (URLSession) -> (URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        let fakeMethodSelector2 = #selector((URLSession.fakedataTasks(with:completionHandler:)) as (URLSession) -> (URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        let originalMethod2 = class_getInstanceMethod(urlSessionClass, selector2)!
        let fakeMethod2 = class_getInstanceMethod(URLSession.self, fakeMethodSelector2)!
        method_exchangeImplementations(originalMethod2, fakeMethod2)
        // Print stack trace
        //print("Stack trace \(Thread.callStackSymbols)")
        
    }
    
    @IBAction func clickedOnUrlRequest(_ sender: Any) {
        performNetworkTask(requestType: .urlRequest)
//        register()
    }
    
    @IBAction func clickedOnNextButton(_ sender: Any) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as? SecondViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        performNetworkTask(requestType: .url)
        
    }
    
    func isSwizzled() -> Bool {
        let protocolClasses: [AnyClass] = URLSessionConfiguration.default.protocolClasses ?? []
        for protocolCls in protocolClasses {
            if protocolCls == CustomUrlProtocol.self {
                return true
            }
        }
        return false
    }
    
    func register() {
//        URLProtocol.registerClass(CustomUrlProtocol.self)
//        let instance = URLSessionConfiguration.default
//        let uRLSessionConfigurationClass: AnyClass = object_getClass(instance)!
//        let fakeProtocolSel = #selector(URLSessionConfiguration.fakeProcotolClasses)
//        let originalProtocolSel = #selector(getter: instance.protocolClasses)
//
//        print("Before \(isSwizzled())")
//        if instance.responds(to: originalProtocolSel) {
//            print("Original class")
//        } else {
//            print("Somethig is fishe")
//        }
//        if instance.responds(to: fakeProtocolSel) {
//            print("Fake class")
//        } else {
//            print("it's ok")
//        }
//
//        let method1: Method = class_getInstanceMethod(uRLSessionConfigurationClass, #selector(getter: uRLSessionConfigurationClass.protocolClasses))!
//        print("original method \(method1.debugDescription) hash = \(method1.hashValue)")
//        print(URLSessionConfiguration.default.protocolClasses!)
//        let method2: Method = class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.fakeProcotolClasses))!
//        print("fake method \(method2.debugDescription) hash = \(method2.hashValue)")
//
//        method_exchangeImplementations(method1, method2)
//        print(URLSessionConfiguration.default.protocolClasses!)
        print("After \(isSwizzled())")
//        swizzleDataTask()
    }

}

private extension URLSession {
    @objc func fakedataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
//        print("Stack trace1 \(Thread.callStackSymbols)")
        print("Injected method 1")
//        let originalSession = self.fakedataTask(with: request, completionHandler: completionHandler)
        
        let originalSession = self.fakedataTask(with: request) { (data, response, error) in
            do {
                let response = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                print("Intercepted response \(response ?? [:])")
            } catch {
                print(error.localizedDescription)
            }
            completionHandler(data,response,error)
        }
        return originalSession
    }
    
    @objc func fakedataTasks(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
//        print("Stack trace url \(Thread.callStackSymbols)")
        print("Injected method url")
        
        let originalSession = self.fakedataTasks(with: url) { (data, response, error) in
            do {
                let response = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                print("Intercepted response url\(response ?? [:])")
            } catch {
                print(error.localizedDescription)
            }
            
            completionHandler(data,response,error)
        }
        return originalSession
    }
}

extension ViewController: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("Response -> \(String(describing: response.mimeType))")
    }
}

extension URLSessionConfiguration {
    
    @objc func fakeProcotolClasses() -> [AnyClass]? {
//        print(Thread.callStackSymbols)
        guard let fakeProcotolClasses = self.fakeProcotolClasses() else {
            return []
        }
        var originalProtocolClasses = fakeProcotolClasses.filter {
            return $0 != CustomUrlProtocol.self
        }
        originalProtocolClasses.insert(CustomUrlProtocol.self, at: 0)
        return originalProtocolClasses
    }
    
}


extension ViewController {
    
    func performNetworkTask(requestType: RequestType) {
        switch requestType {
        case .url:
            loadDataUsingUrl()
            
        case .urlRequest:
            loadDataUsingUrlRequest()
        }
    }
    
    func loadDataUsingUrl() {
        print("============\(#function)============")
        let session = URLSession.shared
        session.dataTask(with: URL(string: "https://gorest.co.in/public-api/users")!) { (data, urlResponse, error) in
//            print("Response \(#function) \n \(String(describing: urlResponse.debugDescription))")
            do {
                let response = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                print("Response JSON\(#function) \n \(String(describing: response))")
            } catch {
                print(error.localizedDescription)
            }
            }.resume()
    }
    
    func loadDataUsingUrlRequest() {
        print("============\(#function)============")
        var urlRequest = URLRequest(url: URL(string: "https://gorest.co.in:443/public-api/users?param=vvalue")!)
        urlRequest.addValue("Bearer ggolvSv4UpUH_a9Qk5x5KAC2YudbptpltVYZ", forHTTPHeaderField: "Authorization")
        self.urlRequestTest = urlRequest
        guard let mutableRequest = (urlRequest as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
                return
        }
        
        URLProtocol.setProperty("Heeelo", forKey: "hello", in: mutableRequest)
        self.urlRequestTest = mutableRequest as URLRequest
//        URLSession.shared.dataTask(with: urlRequest).resume()
//        URLSession.shared.dataTask(with: URL(string: "https://gorest.co.in:443/public-api/users?param=vvalue")!).resume()
//        print("Value = \(URLProtocol.property(forKey: "hello", in: self.urlRequestTest!))")
        let session = URLSession(configuration: .default)
        session.dataTask(with: mutableRequest as URLRequest) { (data, urlResponse, error) in
//            print("Response \(#function) \n \(String(describing: urlResponse))")
            do {
                let response = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                print("Response JSON \(#function) \n \(String(describing: response))")
            } catch {
                print(error.localizedDescription)
            }
            }.resume()
        
//        let session = URLSession(configuration: .background(withIdentifier: "123"), delegate: self, delegateQueue: nil)
//            session.dataTask(with: urlRequest).resume()
        
    }
    
}

class CustomURLSession: URLSession {
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        print("Stack trace original \(Thread.callStackSymbols)")
        return super.dataTask(with: request, completionHandler: completionHandler)
    }
    
    override func fakedataTasks(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        print("Stack trace original url \(Thread.callStackSymbols)")
        return super.dataTask(with: url, completionHandler: completionHandler)
    }
    
}
