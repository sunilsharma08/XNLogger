//
//  Groundwork.swift
//  XNLoggerExample
//
//  Created by Sunil Sharma on 04/06/20.
//  Copyright © 2020 Sunil Sharma. All rights reserved.
//

import Foundation

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self)
            else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func urlEncoded() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}

extension Data {
    mutating func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

let localURL = "http://192.168.1.4:3000/sortfilter"

/**
 Multipart form data
 
 //        let url = "http://server/upload"
 //        let img = UIImage(named: "water.png") ?? UIImage()
 //        let data: Data = img.pngData() ?? Data()
 ////
 //        uploadData(data, toURL: "https://httpbin.org/post", withFileKey: "profileImage", completion: nil)
         
 //        uploadImageToServerFromApp(nameOfApi: "https://gorest.co.in/public-api/users?_format=json&access-token=Vy0X23HhPDdgNDNxVocmqv3NIkDTGdK93GfV", uploadedImage: UIImage(named: "water.png") ?? UIImage())
 
 
 func generateBoundaryString() -> String {
         return "Boundary-\(UUID().uuidString)"
     }
     
     func dataUploadBodyWithParameters(_ parameters: [String: Any]?, filename: String, mimetype: String, dataKey: String, data: Data, boundary: String) -> Data {
         var body = Data()
         // Encode parameters first
         if parameters != nil {
             for (key, value) in parameters! {
                 body.appendString("--\(boundary)\r\n")
                 body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                 body.appendString("\(value)\r\n")
             }
         }
         
         body.appendString("--\(boundary)\r\n")
         body.appendString("Content-Disposition: form-data; name=\"\(dataKey)\"; filename=\"\(filename)\"\r\n")
         body.appendString("Content-Type: \(mimetype)\r\n\r\n")
         body.append(data)
         body.appendString("\r\n")
         body.appendString("--\(boundary)--\r\n")
         
         return body
     }
     
     func uploadData(_ data: Data, toURL urlString: String, withFileKey fileKey: String, completion: ((_ success: Bool, _ result: Any?) -> Void)?) {
         
         if let url = URL(string: urlString) {
             // build request
             let boundary = generateBoundaryString()
             var request = URLRequest(url: url)
             request.httpMethod = "POST"
 //            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
 //            request.setValue("application/json", forHTTPHeaderField: "Accept")
             
             // Build body
             let body = dataUploadBodyWithParameters(nil, filename: "water.png", mimetype: "image/png", dataKey: fileKey, data: data, boundary: boundary)
             request.httpBody = body
             
             URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                 if data != nil && error == nil {
                     do {
                         let result = try JSONSerialization.jsonObject(with: data!, options: [])
                         DispatchQueue.main.async(execute: { completion?(true, result) })
                     } catch {
                         DispatchQueue.main.async(execute: { completion?(false, nil) })
                     }
                 } else { DispatchQueue.main.async(execute: { completion?(false, nil) }) }
             }).resume()
             
         } else {
             DispatchQueue.main.async(execute: { completion?(false, nil) })
         }
     }
 */

/**
Check upload by data
let uploadData = try? JSONEncoder().encode(uploadDict)
 guard let data = uploadData
     else {
         print("Unable to create upload data")
         return
 }
let uploadTask = session.uploadTask(with: uploadURLRequest, from: uploadData)
uploadTask.resume()
 */
