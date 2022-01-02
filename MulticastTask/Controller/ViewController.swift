//
//  ViewController.swift
//  MulticastTask
//
//  Created by adhash on 02/01/22.
//

import UIKit


class ViewController: UIViewController, NetServiceBrowserDelegate, NetServiceDelegate {
    
    var browser = NetServiceBrowser()
    var service: NetService!
    var services = [NetService]()
    let domain = "local."
    let name = "_http._tcp"
    
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var publishBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.browser.delegate = self
        InterfaceSetUp()
    }
    
    func InterfaceSetUp() {
        scanBtn.backgroundColor = .clear
        scanBtn.layer.cornerRadius = 5
        scanBtn.layer.borderWidth = 1
        scanBtn.layer.borderColor = UIColor.init(red: 0.0/255.0, green: 117.0/255.0, blue: 227.0/255.0, alpha: 1).cgColor
        
        publishBtn.layer.cornerRadius = 5
        publishBtn.layer.borderWidth = 1
        publishBtn.layer.borderColor = UIColor.clear.cgColor

    }
    
    @IBAction func startScan(_ sender: Any) {
        //        //self.services.removeAll()
        //        self.browser.searchForServices(ofType: name, inDomain: domain)
        self.browser = NetServiceBrowser()
        self.browser.delegate = self
        self.browser.includesPeerToPeer = true
        self.browser.searchForServices(ofType: name, inDomain: domain)
        self.browser.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
    }
    
    @IBAction func pusblishButtonAction(_ sender: Any) {
        //initialize the NetService object
        self.service = NetService(domain: domain, type: name, name: "netServiceTest", port: Int32(80))
        
        //assing NetService delegate to ViewController object
        self.service.delegate = self
        
        //publish it
        self.service.publish()
        
    }
    
    
    
    func updateInterface () {
        for service in self.services {
            if service.port == -1 {
                print("service \(service.name) of type \(service.type)" +
                      " not yet resolved")
                service.delegate = self
                service.resolve(withTimeout:10)
            } else {
                print("service \(service.name) of type \(service.type)," +
                      "port \(service.port), addresses \(service.addresses)")
            }
        }
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        //        print("uh oh, could not publish netService. domain:\(services.domain) type:\(services.type) name:\(services.name) port:\(services.port)")
        print("error code:\(errorDict)")
    }
    
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        browser.delegate = self
        print("starting search..")
        self.updateInterface()
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("Stoped search")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("error in search")
        debugPrint(errorDict)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("found service")
        print("adding a service")
        self.services.append(service)
        if !moreComing {
            self.updateInterface()
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if let ix = self.services.index(of:service) {
            self.services.remove(at:ix)
            print("removing a service")
            if !moreComing {
                self.updateInterface()
            }
        }
        
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("did resolve address")
        print(sender.hostName!, sender.port)
        self.updateInterface()
    }
}

