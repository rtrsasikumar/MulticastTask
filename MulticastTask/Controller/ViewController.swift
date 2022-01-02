//
//  ViewController.swift
//  MulticastTask
//
//  Created by adhash on 02/01/22.
//

import UIKit


class ViewController: UIViewController, NetServiceBrowserDelegate, NetServiceDelegate {
    
    var browser = NetServiceBrowser()
    var service: NetService?
    var services = [NetService]()
    let domain = "local."
    let name = "_http._tcp"
    var detailArr = [[String: Any]]()
    
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        self.browser = NetServiceBrowser()
        self.browser.delegate = self
        self.browser.includesPeerToPeer = true
        self.browser.searchForServices(ofType: name, inDomain: domain)
        self.browser.schedule(in: RunLoop.main, forMode: RunLoop.Mode.default)
    }
    
    @IBAction func pusblishButtonAction(_ sender: Any) {
        //initialize the NetService object
        self.service = NetService(domain: domain, type: name, name: "netService", port: Int32(80))
        
        //assing NetService delegate to ViewController object
        self.service?.delegate = self
        
        //publish it
        self.service?.publish()
        
        let alert = UIAlertController(title: "MultiCast Task", message: "Published successful", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            @unknown default:
                print("default")
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func updateInterface () {
        for service in self.services {
            if service.port == -1 {
                print("service \(service.name) of type \(service.type)" +
                      " not yet resolved")
                service.delegate = self
                service.resolve(withTimeout: 0.0)
            } else {
                detailArr.removeAll()
                var ipAdd = ""
                if let address = service.addresses {
                    
                    for addressOfFirstDevice in address {
                        let theAddress = addressOfFirstDevice as Data
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if getnameinfo((theAddress as NSData).bytes.bindMemory(to: sockaddr.self, capacity: theAddress.count), socklen_t(theAddress.count),
                                       &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                            if let numAddress = String(validatingUTF8: hostname) {
                                if validateIpAddress(ipToValidate: numAddress) {
                                    ipAdd = numAddress
                                    
                                    let dictValue = [
                                        "ipAdd": ipAdd,
                                        "hostName": service.hostName as Any,
                                        "port": service.port
                                    ] as [String : Any]
                                    detailArr.append(dictValue)
                                    print(detailArr)
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
       
        print("error code:\(errorDict)")
    }
    
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        print("starting search..")
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("Stoped search")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("error in search")
        debugPrint(errorDict)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("adding a service")
        self.services.append(service)
        if !moreComing {
            self.service?.delegate = self
            self.service?.resolve(withTimeout: 5.0)
            self.service?.stop()
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

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.detailArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceDetailsTableViewCellId") as? DeviceDetailsTableViewCell {
            cell.ipAddressLbl?.text = "\(self.detailArr[indexPath.row]["ipAdd"] ?? "")"
            cell.hostNameLbl?.text = self.detailArr[indexPath.row]["hostName"] as? String ?? ""
            cell.portnumberLbl?.text = "\(self.detailArr[indexPath.row]["port"] ?? "")"
            return cell
        }
        
        return UITableViewCell()
    }
}
