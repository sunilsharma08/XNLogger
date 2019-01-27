//
//  NetworkLoggerTests.swift
//  NetworkLoggerTests
//
//  Created by Sunil Sharma on 14/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import XCTest
@testable import NetworkLogDemo

class NetworkLoggerTests: XCTestCase {

    override func setUp() {
//        URLProtocol.registerClass(CustomUrlProtocol.self)
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let session = URLSession.shared.dataTask(with: URL(string: "www.google.com")!) { (data, response, error) in
            
        }.resume()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
