//
//  NetworkInterceptorTests.swift
//  NetworkLoggerTests
//
//  Created by Sunil Sharma on 06/02/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import XCTest
import Swifter
@testable import NetworkLogger

class NetworkInterceptorTests: XCTestCase {

    var server: HttpServer? = HttpServer()
    
    override func setUp() {
        setupNetworkLogger()
        server![API.localInfo.path] = { request in
            return HttpResponse.ok(.json(DummyResponse.get(forAPI: .localInfo)))
        }
        try! server?.start()
    }
    
    func setupNetworkLogger() {
        let logHandlerFactory = NLLogHandlerFactory()
        NetworkLogger.shared.addLogHandler(logHandlerFactory.create(.console([])))
        NetworkLogger.shared.startLogging()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        server?.stop()
        NetworkLogger.shared.stopLogging()
    }

    /**
     Test data task method
     `func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask`
     
     with URLSession conconfiguration - shared, default, ephemeral
     */
    func testDataTaskUrlCompletionHandler() {
        
        // Create an expectation for a background download task.
        let expectations = [
            XCTestExpectation(description: "\(#function) - Perform data task with shared URLSession configuration"),
            XCTestExpectation(description: "\(#function) - Perform data task with default URLSession configuration"),
            XCTestExpectation(description: "\(#function) - Perform data task with ephemeral URLSession configuration")]
        
        // Create a URL for a web page to be downloaded.
        let url: URL! = API.localInfo.url
        
        let sessions = [URLSession.shared, URLSession(configuration: .default), URLSession(configuration: .ephemeral)]
        
        for (index, session) in sessions.enumerated() {
            
            let dataTask = session.dataTask(with: url) { (data, _, _) in
                
                print("Stack trace1 \n\(Thread.callStackSymbols)")
                // Make sure we downloaded some data.
                XCTAssertNotNil(data, "No data was downloaded.")
                
                print(JSONUtils.shared.getJsonStringFrom(jsonData: data ?? Data()))
                
                // Fulfill the expectation to indicate that the background task has finished successfully.
                expectations[index].fulfill()
                
            }
            
            // Start the data task.
            dataTask.resume()
        }
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: expectations, timeout: 10.0)
    }

}
