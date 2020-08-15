//
//  XNMIMEChecker.swift
//  XNLogger
//
//  Created by Sunil Sharma on 02/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

enum XNContentType {
    case text
    case json
    case image
    case pdf
    case audio
    case video
    case urlencoded
    case multipart
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
        case .urlencoded:
            return "x-www-form-urlencoded"
        case .multipart:
            return "Multipart form data"
        case .unknown(let name):
            if let title = name {
                return title
            }
            return "Unknown"
        }
    }
}

struct XNFileMeta {
    // Offset for signature read
    let offset: Int
    let signature: [UInt8]
    var ext: String?
    let mimeType: String?
    let contentType: XNContentType
    
    init(offset: Int = 0, signature: [UInt8] = [], ext: String?, mime: String?, contentType: XNContentType) {
        self.offset = offset
        self.signature = signature
        self.ext = ext
        self.mimeType = mime
        self.contentType = contentType
    }
}

class XNMIMEChecker {
    
    private static let imagesSignature: [XNFileMeta] = [
        /*PNG*/
        XNFileMeta(signature: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
                      ext: "png", mime: "image/png", contentType: .image),
        /*TIF*/
        XNFileMeta(signature: [0x49, 0x20, 0x49],
                      ext: "tif", mime: "image/tiff", contentType: .image),
        /*TIF*/
        XNFileMeta(signature: [0x49, 0x49, 0x2A, 0x00],
                      ext: "tif", mime: "image/tiff", contentType: .image),
        /*TIF*/
        XNFileMeta(signature: [0x4D, 0x4D, 0x00, 0x2A],
                      ext: "tiff", mime: "image/tiff", contentType: .image),
        /*TIF*/
        XNFileMeta(signature: [0x4D, 0x4D, 0x00, 0x2B],
                      ext: "tiff", mime: "image/tiff", contentType: .image),
        /*JPEG, JPG*/
        XNFileMeta(signature: [0xFF, 0xD8, 0xFF, 0xE0],
                      ext: "jpeg", mime: "image/jpeg", contentType: .image),
        /*JPEG*/
        XNFileMeta(signature: [0xFF, 0xD8, 0xFF, 0xE2],
                      ext: "jpeg", mime: "image/jpeg", contentType: .image),
        /*JPEG*/
        XNFileMeta(signature: [0xFF, 0xD8, 0xFF, 0xE3],
                      ext: "jpeg", mime: "image/jpeg", contentType: .image),
        /*JPG*/
        XNFileMeta(signature: [0xFF, 0xD8, 0xFF, 0xE1],
                      ext: "jpg", mime: "image/jpeg", contentType: .image),
        /*JPG*/
        XNFileMeta(signature: [0xFF, 0xD8, 0xFF, 0xE8],
                      ext: "jpg", mime: "image/jpeg", contentType: .image),
        /*GIF*/
        XNFileMeta(signature: [0x47, 0x49, 0x46, 0x38],
                      ext: "gif", mime: "image/gif", contentType: .image),
        /*BMP*/
        XNFileMeta(signature: [0x42, 0x4D],
                      ext: "bmp", mime: "image/bmp", contentType: .image),
        /*ICO*/
        XNFileMeta(signature: [0x00, 0x00, 0x01, 0x00],
                      ext: "ico", mime: "image/vnd.microsoft.icon", contentType: .image),
        /*CUR*/
        XNFileMeta(signature: [0x00, 0x00, 0x02, 0x00],
                      ext: "cur", mime: "image/x-icon", contentType: .image),
        /*JP2*/
        XNFileMeta(signature: [0x00, 0x00, 0x00, 0x0C, 0x6A, 0x50, 0x20, 0x20, 0x0D, 0x0A],
                      ext: "jp2", mime: "image/jp2", contentType: .image),
        /*HDR*/
        XNFileMeta(signature: [0x23, 0x3F, 0x52, 0x41, 0x44, 0x49, 0x41, 0x4E, 0x43, 0x45, 0x0A],
                      ext: "hdr", mime: "image/vnd.radiance", contentType: .image),
        /*WEBP*/
        XNFileMeta(signature: [0x52, 0x49, 0x46, 0x46],
                   ext: "webp", mime: "image/webp", contentType: .image)
    ]
    
    private static let videoSignatures: [XNFileMeta] = [
        /*MPG*/
        XNFileMeta(signature: [0x00, 0x00, 0x01, 0xBA],
                      ext: "mpeg", mime: "video/mpeg", contentType: .video),
        /*MPG*/
        XNFileMeta(signature: [0x00, 0x00, 0x01, 0xB3],
                      ext: "mpeg", mime: "video/mpeg", contentType: .video),
        /*FLV, M4V ISO Media, MPEG v4 system, or iTunes AVC-LC file*/
        XNFileMeta(offset: 4, signature: [0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x56, 0x20],
                      ext: "m4v", mime: "video/x-m4v", contentType: .video),
        /*M4V MPEG-4 video|QuickTime file*/
        XNFileMeta(offset: 4, signature: [0x66, 0x74, 0x79, 0x70, 0x6D, 0x70, 0x34, 0x32],
                      ext: "m4v", mime: "video/x-m4v", contentType: .video),
        /*MP4 MPEG-4 video file*/
        XNFileMeta(offset: 4, signature: [0x66, 0x74, 0x79, 0x70, 0x4D, 0x53, 0x4E, 0x56],
                      ext: "mp4", mime: "video/mp4", contentType: .video),
        /*MP4 ISO Base Media file (MPEG-4) v1*/
        XNFileMeta(offset: 4, signature: [0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6F, 0x6D],
                      ext: "mp4", mime: "video/mp4", contentType: .video),
        /*MOV QuickTime movie file*/
        XNFileMeta(offset: 4, signature: [0x66, 0x74, 0x79, 0x70, 0x71, 0x74, 0x20, 0x20],
                      ext: "mov", mime: "video/quicktime", contentType: .video),
        /*MOV QuickTime movie file*/
        XNFileMeta(offset: 4, signature: [0x6D, 0x6F, 0x6F, 0x76],
                      ext: "mov", mime: "video/quicktime", contentType: .video),
        /*3GG, 3GP, 3G2 3rd Generation Partnership Project 3GPP multimedia files*/
        XNFileMeta(offset: 4, signature: [0x66, 0x74, 0x79, 0x70, 0x33, 0x67, 0x70],
                      ext: "3gp", mime: "video/3gpp", contentType: .video),
        /*FLV*/
        XNFileMeta(signature: [0x46, 0x4c, 0x56],
                      ext: "flv", mime: "video/x-flv", contentType: .video),
        /*AVI*/
        XNFileMeta(signature: [0x52, 0x49, 0x46, 0x46], ext: "avi", mime: "video/avi", contentType: .video),
        /*WMV*/
        XNFileMeta(signature: [0x30, 0x26, 0xB2, 0x75, 0x8E, 0x66, 0xCF, 0x11],
                      ext: "wmv", mime: "video/x-ms-wmv", contentType: .video),
        /*REC*/
        XNFileMeta(signature: [0x2E, 0x52, 0x45, 0x43],
                      ext: "rec", mime: "application/vnd.rn-recording", contentType: .video)
    ]
    
    private static let pdfSignatures: [XNFileMeta] = [
        /*PDF*/
        XNFileMeta(signature: [0x25, 0x50, 0x44, 0x46],
                      ext: "pdf", mime: "application/pdf", contentType: .pdf)
    ]
    
    private static let textSignatures: [XNFileMeta] = [
        /*JSON*/
        XNFileMeta(signature: [0x7B],
                      ext: "json", mime: "application/json", contentType: .text),
        /*JSON*/
        XNFileMeta(signature: [0x5B],
                      ext: "json", mime: "application/json", contentType: .text),
        /*XML*/
        XNFileMeta(signature: [0x3c, 0x3f, 0x78, 0x6d, 0x6c, 0x20],
                     ext: "xml", mime: "text/xml", contentType: .text)
    ]
    
    private static let audioSignature: [XNFileMeta] = [
        /*M4A Apple Lossless Audio Codec file*/
        XNFileMeta(offset: 4, signature: [0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x41, 0x20],
                      ext: "m4a", mime: "audio/x-m4a", contentType: .audio),
        /*AAC MPEG-4 Advanced Audio Coding (AAC) Low Complexity (LC) audio file*/
        XNFileMeta(signature: [0xFF, 0xF1],
                      ext: "acc", mime: "audio/aac", contentType: .audio),
        /*AAC MPEG-2 Advanced Audio Coding (AAC) Low Complexity (LC) audio file*/
        XNFileMeta(signature: [0xFF, 0xF9],
                      ext: "acc", mime: "audio/aac", contentType: .audio),
        /*AIFF Audio Interchange File*/
        XNFileMeta(signature: [0x46, 0x4F, 0x52, 0x4D, 0x00],
                      ext: "aiff", mime: "audio/aiff", contentType: .audio),
        /*CAF Apple Core Audio File*/
        XNFileMeta(signature: [0x63, 0x61, 0x66, 0x66],
                      ext: "caf", mime: "audio/x-caf", contentType: .audio) ,
        /*MP3 MPEG-1 Audio Layer 3 (MP3) audio file*/
        XNFileMeta(signature: [0x49, 0x44, 0x33],
                      ext: "mp3", mime: "audio/mp3", contentType: .audio),
        /*AU NeXT/Sun Microsystems µ-Law audio file*/
        XNFileMeta(signature: [0x2E, 0x73, 0x6E, 0x64],
                      ext: "au", mime: "audio/basic", contentType: .audio),
        /*WAV*/
        XNFileMeta(offset: 8, signature: [0x57, 0x41, 0x56, 0x45, 0x66, 0x6D, 0x74, 0x20],
                      ext: "wav", mime: "audio/wav", contentType: .audio)
    ]
    
    private static let extMimeMap: [String: String] = [
        /**Images*/
        "image/png": "png",
        "image/tiff": "tiff",
        "image/jpeg": "jpeg",
        "image/gif": "gif",
        "image/bmp": "bmp",
        "image/vnd.microsoft.icon": "ico",
        "image/x-icon": "ico",
        "image/jp2": "jp2",
        "image/vnd.radiance": "hdr",
        "image/webp": "webp",
        "image/apng": "png",
        "image/svg+xml": "svg",
        "image/vnd.wap.wbmp": "wbmp",
        /**Text*/
        "text/html": "html",
        "text/css": "css",
        "text/xml": "xml",
        "text/mathml": "mml",
        "text/plain": "txt",
        "text/vnd.sun.j2me.app-descriptor": "jad",
        "text/vnd.wap.wml": "wml",
        "text/x-component": "htc",
        "text/csv": "csv",
        "text/calendar": "ics",
        "text/javascript": "js",
        "text/vcard": "vcard",
        "text/vnd.rim.location.xloc": "xloc",
        "text/vtt": "vtt",
        "text/cache-manifest": "appcache",
        /**JSON*/
        "application/json": "json",
        /**PDF*/
        "application/pdf": "pdf",
        /**Video*/
        "video/mpeg": "mpeg",
        "video/x-m4v": "m4v",
        "video/mp4": "mp4",
        "video/quicktime": "mov",
        "video/3gpp": "3gp",
        "video/x-flv": "flv",
        "video/avi": "avi",
        "video/x-ms-wmv": "wmv",
        "application/vnd.rn-recording": "rec",
        "video/x-msvideo": "avi",
        "video/ogg": "ogg",
        "video/ogv": "ogv",
        "video/mp2t": "ts",
        "video/webm": "webm",
        "video/3gpp2": "3g2",
        /**Audio*/
        "audio/x-m4a": "m4a",
        "audio/aac": "aac",
        "audio/aiff": "aiff",
        "audio/x-caf": "caf",
        "audio/mpeg": "mp3",
        "audio/basic": "au",
        "audio/wav": "wav",
        "audio/x-wav": "wav",
        "audio/midi": "midi",
        "audio/oga": "oga",
        "audio/ogg": "ogg",
        "audio/x-realaudio": "ra",
        "audio/mp4": "m4a",
        "audio/webm": "weba",
        "audio/3gpp": "3gp",
        "audio/3gpp2": "3g2",
        /**Miscellaneous*/
        "application/rtf": "rtf",
        "application/xml": "xml"
    ]
    
    static let maxDataNeed: Int = 16
    
    func getFileMeta(from dataBytes: [UInt8]) -> XNFileMeta {
        // Check for JSON
        if let fileMeta = compareSignatures(XNMIMEChecker.textSignatures, with: dataBytes) {
            return fileMeta
        }
        // Check for PDF
        else if let fileMeta = compareSignatures(XNMIMEChecker.pdfSignatures, with: dataBytes) {
            return fileMeta
        }
        // Check for Images
        else if let fileMeta = compareSignatures(XNMIMEChecker.imagesSignature, with: dataBytes) {
            return fileMeta
        }
        // Check for Videos
        else if let fileMeta = compareSignatures(XNMIMEChecker.videoSignatures, with: dataBytes) {
            return fileMeta
        }
        // Check for Audio
        else if let fileMeta = compareSignatures(XNMIMEChecker.audioSignature, with: dataBytes) {
            return fileMeta
        } else {
            return XNFileMeta(ext: nil, mime: nil, contentType: .unknown(nil))
        }
    }
    
    private func compareSignatures(_ signatures:[XNFileMeta], with dataBytes: [UInt8]) -> XNFileMeta? {
        for signature in signatures {
            if match(fileSignature: signature, with: dataBytes) {
                return signature
            }
        }
        return nil
    }
    
    private func match(fileSignature: XNFileMeta, with dataBytes: [UInt8]) -> Bool {
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
    
    func getFileMeta(from mimeString: String?) -> XNFileMeta {
        let unknownMeta = XNFileMeta(ext: nil, mime: nil, contentType: .unknown(nil))
        
        guard let mimeType = mimeString, mimeType.isEmpty == false
            else { return unknownMeta }
        
        let typeList: [String] = mimeType.components(separatedBy: "/")
        if typeList.count < 2 {
            return unknownMeta
        }
        let type: String = typeList[0].lowercased()
        let subType: String = typeList[1].lowercased()
        if type.isEmpty == true || subType.isEmpty == true {
            return unknownMeta
        }
        
        switch type {
        case "application":
            return getFileMeta(type: getApplicationType(subType), mime: mimeType)
        case "text":
            return getFileMeta(type: .text, mime: mimeType)
        case "image":
            return getFileMeta(type: .image, mime: mimeType)
        case "audio":
            return getFileMeta(type: .audio, mime: mimeType)
        case "video":
            return getFileMeta(type: .video, mime: mimeType)
        case "multipart":
            return getFileMeta(type: .multipart, mime: mimeType)
        default:
            return getFileMeta(type: .unknown(mimeType), mime: mimeType)
        }
    }
    
    func getFileMeta(type: XNContentType, mime: String) -> XNFileMeta {
        let ext = XNMIMEChecker.extMimeMap[mime]
        return XNFileMeta(ext: ext, mime: mime, contentType: type)
    }
    
    private func getApplicationType(_ subTypeString: String) -> XNContentType {
        switch subTypeString {
        case "pdf":
            return .pdf
        case "json":
            return .json
        case "xml":
            return .text
        case "x-www-form-urlencoded":
            return .urlencoded
        default:
            return .unknown("application/\(subTypeString)")
        }
    }
}
