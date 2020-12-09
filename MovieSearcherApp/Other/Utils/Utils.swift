//
//  Utils.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 09.12.2020.
//

import UIKit
import MobileCoreServices
import SystemConfiguration

fileprivate class Reachability {

    class func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        /* Only Working for WIFI
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired

        return isReachable && !needsConnection
        */

        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret

    }
}

struct Utils {
    
    static private let defFilename = "file"
    
    static var internetConnectionOK: Bool {
        Reachability.isConnectedToNetwork()
    }
    
    static func UIImageToDataIO(image: UIImage, compressionRatio: CGFloat, orientation: Int = 1) -> Data? {
        return autoreleasepool(invoking: { () -> Data in
            let data = NSMutableData()
            let options: NSDictionary = [
                kCGImagePropertyOrientation: orientation,
                kCGImagePropertyHasAlpha: true,
                kCGImageDestinationLossyCompressionQuality: compressionRatio
            ]
            
            let imageDestinationRef = CGImageDestinationCreateWithData(data as CFMutableData, kUTTypeJPEG, 1, nil)!
            CGImageDestinationAddImage(imageDestinationRef, image.cgImage!, options)
            CGImageDestinationFinalize(imageDestinationRef)
            return data as Data
        })
    }
    
    static func UIImageToDataJPEG2(image: UIImage, compressionRatio: CGFloat) -> Data? {
        return autoreleasepool(invoking: { () -> Data? in
            return image.jpegData(compressionQuality: compressionRatio)
        })
    }
    
    @discardableResult
    static func saveImage(image: UIImage, to file: String? = nil) -> URL? {
        let file = file ?? defFilename
        guard let data = UIImageToDataJPEG2(image: image, compressionRatio: 1) else {
            return nil
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        do {
            try data.write(to: directory.appendingPathComponent(file))
            return directory
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    @discardableResult
    static func saveData(_ data: Data, to file: String? = nil) -> URL {
        let file = file ?? defFilename
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(file)
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            print(error.localizedDescription)
        }
        return url
    }
    
    static func getData(from file: String? = nil) -> Data? {
        let file = file ?? defFilename
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(file)
        var data: Data?
        do {
            try data = Data(contentsOf: url)
        } catch {
            print(error.localizedDescription)
        }
        return data
    }
    
    static func getData(_ url: URL) -> Data? {
        var data: Data?
        do {
            try data = Data(contentsOf: url)
        } catch {
            print(error.localizedDescription)
        }
        return data
    }
    
    static func getString<T: CustomStringConvertible>(from value: T) -> String {
        "\(value)"
    }
}
