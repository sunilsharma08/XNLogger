//
//  NLURLProtocol.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 02/04/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

open class NLURLProtocol: URLProtocol {
    
    open override class func canInit(with request: URLRequest) -> Bool{
        print("\(#function) \(request.url!.absoluteString)")
        return false
    }
    
}
