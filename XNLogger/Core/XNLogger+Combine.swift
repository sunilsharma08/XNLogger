//
//  XNLogger+Combine.swift
//  XNLogger
//
//  Created by Sunil Sharma.
//  Copyright © 2024 Sunil Sharma. All rights reserved.
//

#if canImport(Combine)
import Combine

extension XNLogger {

    /// A Combine publisher that emits log events as they occur.
    /// Emits `.request` and `.response` variants of `XNLogEvent`.
    ///
    /// Usage:
    /// ```swift
    /// XNLogger.shared.logPublisher
    ///     .sink { event in
    ///         switch event {
    ///         case .request(let data):
    ///             print("Request: \(data.urlRequest.url)")
    ///         case .response(let data):
    ///             print("Response: \(data.response)")
    ///         }
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    public var logPublisher: AnyPublisher<XNLogEvent, Never> {
        let subject: PassthroughSubject<XNLogEvent, Never> = getOrCreateLogSubject {
            let newSubject = PassthroughSubject<XNLogEvent, Never>()
            // Install the send closure so XNLogger.sendToSubject() can forward
            // events without importing Combine itself.
            self._combineSendClosure = { [weak newSubject] event in
                newSubject?.send(event)
            }
            return newSubject
        }
        return subject.eraseToAnyPublisher()
    }
}
#endif
