//
//  NetworkHelper.swift
//  EnigmaTV
//
//  Created by Blazej Zyglarski on 12.04.2018.
//  Copyright © 2018 Blazej Zyglarski. All rights reserved.
//

import UIKit

struct Platform {
    static let isSimulator: Bool = {
        #if arch(i386) || arch(x86_64)
            return true
        #endif
        return false
    }()
}

class NetworkHelper: NSObject {

    class func getNetworkIPAddresses() -> [String] {
    
        if Platform.isSimulator {
            return self.getNetworkIPAddressesStupid()
        }
        
        
        var list = [String]()
        var myAddr = NetworkHelper.getIPAddress()
        print("Address found")
        print(myAddr)
        
        var comp = myAddr?.components(separatedBy: ".")
        if let comp = comp{
            if comp.count>3{
                for lastcomp in 1 ... 254{
                    let s = "\(comp[0]).\(comp[1]).\(comp[2]).\(lastcomp)"
                    //let s = "10.0.0.\(lastcomp)"
                    list.append(s)
                }
            }
        }
        return list
        
    }
    class func getNetworkIPAddressesStupid() -> [String] {
        var list = [String]()
        for lastcomp in 1 ... 254{
            let s = "10.0.0.\(lastcomp)"
            //let s = "10.0.0.\(lastcomp)"
            list.append(s)
        }
        
        return list
        
    }
    
    class func getNetworkIPAddressesStupid2() -> [String] {
        var list = ["10.0.0.29"]
        
        
        return list
        
    }
    
    class func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    if let name: String = String(cString: (interface?.ifa_name)!) , (name == "en0" || name == "en1"  ){
                        print("found \(name)");
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}
