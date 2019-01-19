#  Delegates
### URLSessionDelegate
- optional public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?)
- optional public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
- optional public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession)

### URLSessionTaskDelegate

 - optional public func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void)

 - optional public func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask)

 - optional public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void)

 - optional public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)

 - optional public func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void)

 - optional public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)

 - optional public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics)

 - optional public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)

### URLSessionDataDelegate

 - optional public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)

 - optional public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask)

 - optional public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask)

 - optional public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)

 - optional public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void)

### URLSessionDownloadDelegate

 - public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)

 - optional public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)

 - optional public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64)

### URLSessionStreamDelegate

 - optional public func urlSession(_ session: URLSession, readClosedFor streamTask: URLSessionStreamTask)

 - optional public func urlSession(_ session: URLSession, writeClosedFor streamTask: URLSessionStreamTask)

 - optional public func urlSession(_ session: URLSession, betterRouteDiscoveredFor streamTask: URLSessionStreamTask)

 - optional public func urlSession(_ session: URLSession, streamTask: URLSessionStreamTask, didBecome inputStream: InputStream, outputStream: OutputStream)
 
 
#  Methods

## Methods which depends on delegate methods
- open func dataTask(with request: URLRequest) -> URLSessionDataTask
- open func dataTask(with url: URL) -> URLSessionDataTask

- open func uploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionUploadTask
- open func uploadTask(with request: URLRequest, from bodyData: Data) -> URLSessionUploadTask
- open func uploadTask(withStreamedRequest request: URLRequest) -> URLSessionUploadTask

- open func downloadTask(with request: URLRequest) -> URLSessionDownloadTask
- open func downloadTask(with url: URL) -> URLSessionDownloadTask
- open func downloadTask(withResumeData resumeData: Data) -> URLSessionDownloadTask

- @available(iOS 9.0, *)
   open func streamTask(withHostName hostname: String, port: Int) -> URLSessionStreamTask
- @available(iOS 9.0, *)
   open func streamTask(with service: NetService) -> URLSessionStreamTask
   
## Methods with completionHandler
### Data task convenience method. The delegate, if any, will still be called for authentication challenges.
   - open func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
   - open func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
   
### Upload task convenience method.
   - open func uploadTask(with request: URLRequest, fromFile fileURL: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask
   - open func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask
   
### Downlaod task convenience method
  When a download successfully completes, the NSURL will point to a file that must be read or
  copied during the invocation of the completion routine.  The file will be removed automatically.
  
   - open func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask
   - open func downloadTask(with url: URL, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask
   - open func downloadTask(withResumeData resumeData: Data, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask

