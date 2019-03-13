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
    var fileLogHandler: NLFileLogHandler?
    let apisToTest: [API] = [.defaultSession, .sharedSession, .ephemeralSession]
    
    
    override func setUp() {
        setupNetworkLogger()
        for api in apisToTest {
            server![api.path] = { request in
                return HttpResponse.ok(.json(DummyResponse.get(forAPI: api)))
            }
        }
        try! server?.start()
    }
    
    func setupNetworkLogger() {
        let logHandlerFactory = NLLogHandlerFactory()
        fileLogHandler = logHandlerFactory.create(.file) as? NLFileLogHandler
        NetworkLogger.shared.addLogHandler(fileLogHandler!)
        NetworkLogger.shared.clearLogs()
        NetworkLogger.shared.startLogging()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        server?.stop()
//        NetworkLogger.shared.stopLogging()
//        fileLogHandler = nil
    }
    
    /**
     Test data task method
     `func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask`
     
     with URLSession conconfiguration - shared, default, ephemeral
     */
    func testDataTaskUrlCompletionHandler() {
        
        // Create an expectation for a background download task.
        let expectations = [
            XCTestExpectation(description: "\(#function) - Perform data task with default URLSession configuration"),
            XCTestExpectation(description: "\(#function) - Perform data task with shared URLSession configuration"),
            XCTestExpectation(description: "\(#function) - Perform data task with ephemeral URLSession configuration")]
        
        // Create a URL for a web page to be downloaded.
        var url: [URL] = []
        var sessions: [URLSession] = []
        for api in apisToTest {
            url.append(api.url!)
            
            switch api {
            case .defaultSession:
                sessions.append(URLSession(configuration: .default))
            case .sharedSession:
                sessions.append(URLSession.shared)
            case .ephemeralSession:
                sessions.append(URLSession(configuration: .ephemeral))
            default:
                debugPrint("API to be tested should not have other then above metioned category. Check API list variable.")
                break
            }
//            expectations.append(XCTestExpectation(description: "\(#function) - Perform data task with \(api.url!) URLSession configuration"))
        }
        
        for (index, session) in sessions.enumerated() {
            
            debugPrint("start job at index \(index) for url = \(url[index])")
            let dataTask = session.dataTask(with: url[index]) { (data, response, error) in
                
                // Make sure we downloaded some data.
                XCTAssertNotNil(data, "No data was downloaded.")
                let subString = TestUtils.getStringFromObject(DummyResponse.get(forAPI: self.apisToTest[index]))!
                debugPrint("Received \(index) response for \(subString)")
                let status = TestUtils.isLogged(atPath: self.fileLogHandler!.currentPath,
                                   subString: subString,
                                   numberOfTimes: 1)
                XCTAssert(status, "Failed to log data for url \(url[index])")
                
                // Fulfill the expectation to indicate that the background task has finished successfully.
                expectations[index].fulfill()
                
            }
            
            // Start the data task.
            dataTask.resume()
        }
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: expectations, timeout: 20.0)
    }
    
}
