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
    var fileLogHandler: XNFileLogHandler?
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
        print(#function)
        let logHandlerFactory = NLLogHandlerFactory()
        fileLogHandler = logHandlerFactory.create(.file) as? NLFileLogHandler
        XNLogger.shared.addLogHandler(fileLogHandler!)
        XNLogger.shared.clearLogs()
        XNLogger.shared.startLogging()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        print(#function)
        server?.stop()
        XNLogger.shared.stopLogging()
        XNLogger.shared.removeHandler(fileLogHandler!)
        fileLogHandler = nil
    }
    
    func getUrlsSessionAndTestExpectations() -> (urls: [URL], sessions:[URLSession], expectations: [XCTestExpectation]) {
        
        // Create an expectation for a background download task.
        var expectations: [XCTestExpectation] = []
        
        // Create a URL for a web page to be downloaded.
        var url: [URL] = []
        var sessions: [URLSession] = []
        for api in apisToTest {
            url.append(api.url!)
            
            switch api {
            case .defaultSession:
                sessions.append(URLSession(configuration: .default))
                expectations.append(XCTestExpectation(description: "Perform data task with Default URLSession configuration"))
            case .sharedSession:
                sessions.append(URLSession.shared)
                expectations.append(XCTestExpectation(description: "Perform data task with Shared URLSession configuration"))
            case .ephemeralSession:
                sessions.append(URLSession(configuration: .ephemeral))
                expectations.append(XCTestExpectation(description: "Perform data task with Ephemeral URLSession configuration"))
            default:
                XCTFail("API to be tested should not have other then above metioned category. Check API list variable.")
                break
            }
        }
        
        return (url, sessions, expectations)
    }
    
    /**
     Test data task method
     `func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask`
     
     with URLSession conconfiguration - shared, default, ephemeral
     */
    func testDataTaskUrlCompletionHandler() {
        
        let preTestData = getUrlsSessionAndTestExpectations()
        // Create an expectation for a background download task.
        let expectations: [XCTestExpectation] = preTestData.expectations
        
        // Create a URL for a web page to be downloaded.
        let url: [URL] = preTestData.urls
        let sessions: [URLSession] = preTestData.sessions
        
        for (index, session) in sessions.enumerated() {
            
            debugPrint("Start job at index \(index) for url = \(url[index])")
            
            let dataTask = session.dataTask(with: url[index]) { (data, response, error) in
                
                // Make sure we downloaded some data.
                XCTAssertNotNil(data, "No data was downloaded for url \(url[index])")
                let subString = TestUtils.getStringFromObject(DummyResponse.get(forAPI: self.apisToTest[index]))!
                debugPrint("Received \(index) response for \(subString)")
                
                /// Wait to complete write operation as we write to log file asynchronous
                sleep(5)
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
    
    /**
     Test data task method
     `func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask`
     
     with URLSession conconfiguration - shared, default, ephemeral
     */
    func testDataTaskURLRequestCompletionHandler() {
        
        let preTestData = getUrlsSessionAndTestExpectations()
        // Create an expectation for a background download task.
        let expectations: [XCTestExpectation] = preTestData.expectations
        
        // Create a URL for a web page to be downloaded.
        let url: [URL] = preTestData.urls
        let sessions: [URLSession] = preTestData.sessions
        
        for (index, session) in sessions.enumerated() {
            
            debugPrint("Start job at index \(index) for url = \(url[index])")
            
            let dataTask = session.dataTask(with: URLRequest(url: url[index])) { (data, response, error) in
                
                // Make sure we downloaded some data.
                XCTAssertNotNil(data, "No data was downloaded for url \(url[index])")
                let subString = TestUtils.getStringFromObject(DummyResponse.get(forAPI: self.apisToTest[index]))!
                debugPrint("Received \(index) response for \(subString)")
                
                /// Wait to complete write operation as we write to log file asynchronous
                sleep(5)
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
    
    func testDataTaskUrlWithoutCompletionHandler() {
        
        let preTestData = getUrlsSessionAndTestExpectations()
        
        // Create a URL for a web page to be downloaded.
        let url: [URL] = preTestData.urls
        let sessions: [URLSession] = preTestData.sessions
        
        for (index, session) in sessions.enumerated() {
            
            debugPrint("Start job at index \(index) for url = \(url[index])")
            session.dataTask(with: url[index]).resume()
            sleep(3)
            let status = TestUtils.isLogged(atPath: self.fileLogHandler!.currentPath,
                                            subString: url[index].absoluteString,
                                            numberOfTimes: 1)
            XCTAssert(status, "Failed to log data for url \(url[index])")
            
            //Negative test
            let status2 = TestUtils.isLogged(atPath: self.fileLogHandler!.currentPath,
                                            subString: "url[index].absoluteString",
                                            numberOfTimes: 1)
            XCTAssert(!status2, "Failed to log data for url \(url[index])")
            }
    }
    
    func testDownloadTaskUrlCompletionHandler() {
        let preTestData = getUrlsSessionAndTestExpectations()
        // Create an expectation for a background download task.
        let expectations: [XCTestExpectation] = preTestData.expectations
        
        // Create a URL for a web page to be downloaded.
        let url: [URL] = preTestData.urls
        let sessions: [URLSession] = preTestData.sessions
        
        for (index, session) in sessions.enumerated() {
            
            debugPrint("Start job at index \(index) for url = \(url[index])")
            
            let dataTask = session.downloadTask(with: url[index]) { (data, response, error) in
                
                // Make sure we downloaded some data.
                XCTAssertNotNil(data, "No data was downloaded for url \(url[index])")
                let subString = TestUtils.getStringFromObject(DummyResponse.get(forAPI: self.apisToTest[index]))!
                debugPrint("Received \(index) response for \(subString)")
                
                /// Wait to complete write operation as we write to log file asynchronous
                sleep(5)
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
    
    /**
    Need to update
    func testBackground() {
        let preTestData = getUrlsSessionAndTestExpectations()
        // Create an expectation for a background download task.
        let expectations: [XCTestExpectation] = [XCTestExpectation(description: "Perform data task with Background URLSession configuration")]
        
        // Create a URL for a web page to be downloaded.
        let url: [URL] = preTestData.urls
        let sessions: [URLSession] = [URLSession(configuration: .background(withIdentifier: "test.background"))]
        
        for (index, session) in sessions.enumerated() {
            
            debugPrint("Start job at index \(index) for url = \(url[index])")
            
            let dataTask = session.dataTask(with: url[index]) { (data, response, error) in
                
                // Make sure we downloaded some data.
                XCTAssertNotNil(data, "No data was downloaded for url \(url[index])")
                let subString = TestUtils.getStringFromObject(DummyResponse.get(forAPI: self.apisToTest[index]))!
                debugPrint("Received \(index) response for \(subString)")
                
                /// Wait to complete write operation as we write to log file asynchronous
                sleep(5)
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
 **/
    
}
