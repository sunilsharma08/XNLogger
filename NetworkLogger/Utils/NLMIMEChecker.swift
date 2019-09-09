//
//  NLMIMEChecker.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 02/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

enum NLContentType {
    case text
    case json
    case image
    case pdf
    case audio
    case video
    case unknown(String?)
    
    func getName() -> String {
        switch self {
        case .text:
            return "Text"
        case .json:
            return "JSON"
        case .image:
            return "Image"
        case .pdf:
            return "PDF"
        case .audio:
            return "Audio"
        case .video:
            return "Video"
        case .unknown(let name):
            if let title = name {
                return title
            }
            return "Unknown"
        }
    }
}

fileprivate struct FileSignature {
    let offset: Int
    let signature: [UInt8]
    
    init(offset: Int = 0, signature: [UInt8]) {
        self.offset = offset
        self.signature = signature
    }
}

class NLMIMEChecker {
    
    private static let imagesSignature: [FileSignature] = [
        FileSignature(signature: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) /*PNG*/,
        FileSignature(signature: [0x49, 0x20, 0x49]) /*TIF*/,
        FileSignature(signature: [0x49, 0x49, 0x2A, 0x00]) /*TIF*/,
        FileSignature(signature: [0x4D, 0x4D, 0x00, 0x2A]) /*TIF*/,
        FileSignature(signature: [0x4D, 0x4D, 0x00, 0x2B]) /*TIF*/,
        FileSignature(signature: [0xFF, 0xD8, 0xFF, 0xE0]) /*JPEG, JPG*/,
        FileSignature(signature: [0xFF, 0xD8, 0xFF, 0xE2]) /*JPEG*/,
        FileSignature(signature: [0xFF, 0xD8, 0xFF, 0xE3]) /*JPEG*/,
        FileSignature(signature: [0xFF, 0xD8, 0xFF, 0xE1]) /*JPG*/,
        FileSignature(signature: [0xFF, 0xD8, 0xFF, 0xE8]) /*JPG*/,
        FileSignature(signature: [0x47, 0x49, 0x46, 0x38]) /*GIF*/,
        FileSignature(signature: [0x42, 0x4D]) /*BMP*/,
        FileSignature(signature: [0x00, 0x00, 0x01, 0x00])/*ICO*/,
        FileSignature(signature: [0x00, 0x00, 0x02, 0x00]) /*CUR*/,
        FileSignature(signature: [0x00, 0x00, 0x00, 0x0C, 0x6A, 0x50, 0x20, 0x20, 0x0D, 0x0A]) /*JP2*/,
        FileSignature(signature: [0x23, 0x3F, 0x52, 0x41, 0x44, 0x49, 0x41, 0x4E, 0x43, 0x45, 0x0A]) /*HDR*/
    ]
    
    private static let videoSignatures: [FileSignature] = [
        FileSignature(signature: [0x00, 0x00, 0x01, 0xBA]) /*MPG*/,
        FileSignature(signature: [0x00, 0x00, 0x01, 0xB3]) /*MPG*/,
        FileSignature(signature: [0x2E, 0x52, 0x45, 0x43]) /*REC*/,
        FileSignature(offset: 4, signature: [0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x56, 0x20]) /*FLV, M4V ISO Media, MPEG v4 system, or iTunes AVC-LC file*/,
        FileSignature(offset: 4, signature: [0x66, 0x74, 0x79, 0x70, 0x4D, 0x53, 0x4E, 0x56]) /*MP4 MPEG-4 video file*/,
        FileSignature(offset: 4, signature: [0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6F, 0x6D]) /*MP4 ISO Base Media file (MPEG-4) v1*/,
        FileSignature(offset: 4, signature: [0x66, 0x74, 0x79, 0x70, 0x6D, 0x70, 0x34, 0x32]) /*M4V MPEG-4 video|QuickTime file*/,
        FileSignature(offset: 4, signature: [0x66, 0x74, 0x79, 0x70, 0x71, 0x74, 0x20, 0x20]) /*MOV QuickTime movie file*/,
        FileSignature(offset: 4, signature: [0x6D, 0x6F, 0x6F, 0x76]) /*MOV QuickTime movie file*/,
        FileSignature(offset: 4, signature: [0x66, 0x74, 0x79, 0x70, 0x33, 0x67, 0x70]) /*3GG, 3GP, 3G2         3rd Generation Partnership Project 3GPP multimedia files*/
    ]
    
    private static let pdfSignatures: [FileSignature] = [
        FileSignature(signature: [0x25, 0x50, 0x44, 0x46]) /*PDF*/
    ]
    
    private static let jsonSignatures: [FileSignature] = [
        FileSignature(signature: [0x7B]),
        FileSignature(signature: [0x5B])
    ]
    
    private static let audioSignature: [FileSignature] = [
        FileSignature(offset: 4, signature: [0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x41, 0x20]) /*M4A Apple Lossless Audio Codec file*/,
        FileSignature(signature: [0xFF, 0xF1]) /*AAC MPEG-4 Advanced Audio Coding (AAC) Low Complexity (LC) audio file*/,
        FileSignature(signature: [0xFF, 0xF9]) /*AAC MPEG-2 Advanced Audio Coding (AAC) Low Complexity (LC) audio file*/,
        FileSignature(signature: [0x46, 0x4F, 0x52, 0x4D, 0x00]) /*AIFF Audio Interchange File*/,
        FileSignature(signature: [0x63, 0x61, 0x66, 0x66]) /*CAF Apple Core Audio File*/,
        FileSignature(signature: [0x49, 0x44, 0x33]) /*MP3 MPEG-1 Audio Layer 3 (MP3) audio file*/,
        FileSignature(signature: [0x2E, 0x73, 0x6E, 0x64]) /*AU NeXT/Sun Microsystems µ-Law audio file*/,
        FileSignature(offset: 8, signature: [0x57, 0x41, 0x56, 0x45, 0x66, 0x6D, 0x74, 0x20])
    ]
    
    static let maxDataNeed: Int = 16
    
    
    func getMimeType(from dataBytes: [UInt8]) -> NLContentType {
        // Check for JSON
        if (compareSignatures(NLMIMEChecker.jsonSignatures, with: dataBytes)) {
            return .json
        }
        // Check for PDF
        else if (compareSignatures(NLMIMEChecker.pdfSignatures, with: dataBytes)) {
            return .pdf
        }
        // Check for Images
        else if compareSignatures(NLMIMEChecker.imagesSignature, with: dataBytes) {
            return .image
        }
        // Check for Videos
        else if compareSignatures(NLMIMEChecker.videoSignatures, with: dataBytes) {
            return .video
        }
        // Check for Audio
        else if compareSignatures(NLMIMEChecker.audioSignature, with: dataBytes) {
            return .audio
        } else {
            return .unknown(nil)
        }
    }
    
    private func compareSignatures(_ signatures:[FileSignature], with dataBytes: [UInt8]) -> Bool {
        for signature in signatures {
            if match(fileSignature: signature, with: dataBytes) {
                return true
            }
        }
        return false
    }
    
    private func match(fileSignature: FileSignature, with dataBytes: [UInt8]) -> Bool {
        if (fileSignature.offset + fileSignature.signature.endIndex) <= dataBytes.endIndex {
            
            var startIndex: Int = fileSignature.signature.startIndex
            var endIndex: Int = fileSignature.signature.endIndex - 1
            
            while (startIndex <= endIndex) {
                if fileSignature.signature[startIndex] != dataBytes[startIndex+fileSignature.offset] ||
                    fileSignature.signature[endIndex] != dataBytes[endIndex+fileSignature.offset] {
                    return false
                }
                startIndex += 1
                endIndex -= 1
            }
            return true
        }
        return false
    }
    
    func getMimeType(from mimeString: String?) -> NLContentType {
        guard let mimeType = mimeString, mimeType.isEmpty == false
            else { return .unknown(nil) }
        let typeList: [String] = mimeType.components(separatedBy: "/")
        if typeList.count < 2 {
            return .unknown(nil)
        }
        let type: String = typeList[0].lowercased()
        let subType: String = typeList[1].lowercased()
        if type.isEmpty == true || subType.isEmpty == true {
            return .unknown(nil)
        }
        
        switch type {
        case "application":
            return getApplicationType(subType)
        case "text":
            return .text
        case "image":
            return .image
        case "audio":
            return .audio
        case "video":
            return .video
        default:
            return .unknown("\(type)/\(subType)")
        }
    }
    
    private func getApplicationType(_ subTypeString: String) -> NLContentType {
        switch subTypeString {
        case "pdf":
            return .pdf
        case "json":
            return .json
        default:
            return .unknown("application/\(subTypeString)")
        }
    }
}
