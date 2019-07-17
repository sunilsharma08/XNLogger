//
//  NLAuthenticationChallengeSender.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 04/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

internal class NLAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {
    
    typealias NLAuthenticationChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    
    fileprivate var handler: NLAuthenticationChallengeHandler
    
    init(handler: @escaping NLAuthenticationChallengeHandler) {
        self.handler = handler
        super.init()
    }
    
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        print(#function)
        handler(URLSession.AuthChallengeDisposition.useCredential, credential)
    }
    
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        print(#function)
        handler(URLSession.AuthChallengeDisposition.useCredential, nil)
    }
    
    func cancel(_ challenge: URLAuthenticationChallenge) {
        print(#function)
        handler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }
    
    func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
        print(#function)
        handler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
    }
    
    func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
        print(#function)
        handler(URLSession.AuthChallengeDisposition.rejectProtectionSpace, nil)
    }
    
}


























