//
//  MultiCastViewModel.swift
//  MulticastTask
//
//  Created by adhash on 04/01/22.
//

import Foundation

class MultiCastViewModel {
    
    var castModel = [MulticastModel]()
    
    // MARK:- Fetch IP Address for the NetService Data
    func getIpAddress(sender:NetService) {
        
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        if let address = sender.addresses {
            for data in address {
                data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Void in
                    let sockaddrPtr = pointer.bindMemory(to: sockaddr.self)
                    guard let unsafePtr = sockaddrPtr.baseAddress else { return }
                    guard getnameinfo(unsafePtr, socklen_t(data.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                        return
                    }
                }
                let ipAddress = String(cString:hostname)
                if  self.validateIpAddress(ipToValidate: ipAddress) {
                    if ipAddress != "127.0.0.1"{
                        
                       let Model =  MulticastModel.init(ipAdd: ipAddress, hostName: sender.name, port: sender.port)
                        
                        self.castModel.append(Model)
                    }
                }
            }
        }
        
    }
    
    // MARK:- Validate the IP Address
    func validateIpAddress(ipToValidate: String) -> Bool {
        
        var sin = sockaddr_in()
        var sin6 = sockaddr_in6()
        
        if ipToValidate.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            // IPv6 peer.
            return false
        }
        else if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            // IPv4 peer.
            return true
        }
        
        return false;
    }
}
