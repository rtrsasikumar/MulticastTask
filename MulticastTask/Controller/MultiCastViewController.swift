//
//  ViewController.swift
//  MulticastTask
//
//  Created by adhash on 02/01/22.
//

import UIKit


class MultiCastViewController: UIViewController, NetServiceBrowserDelegate {
    
    // object for NetServiceBrowser
    var browser = NetServiceBrowser()
    
    // object for NetService
    var service: NetService?
    
    // services array for NetService
    var services = [NetService]()
    
    // domain
    let domain = "local."
    
    let name = "_http._tcp"
    
    
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = MultiCastViewModel()
    
    
    @IBOutlet weak var noDataView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        InterfaceSetUp()
    }
    
    // MARK:- SetUp for Scan and Publish Buttons
    func InterfaceSetUp() {
        
        scanBtn.backgroundColor = .clear
        scanBtn.layer.cornerRadius = 5
        scanBtn.layer.borderWidth = 1
        scanBtn.layer.borderColor = UIColor.init(red: 0.0/255.0, green: 117.0/255.0, blue: 227.0/255.0, alpha: 1).cgColor
        
        publishBtn.layer.cornerRadius = 5
        publishBtn.layer.borderWidth = 1
        publishBtn.layer.borderColor = UIColor.clear.cgColor
        
        viewModel.castModel.removeAll()
        services.removeAll()
        
        noDataView.isHidden = false
        tableView.isHidden = true
    }
    
    // MARK:- Scan Function
    @IBAction func startScan(_ sender: Any) {
        
        // Remving local values and NetService values before scanning
        viewModel.castModel.removeAll()
        services.removeAll()
        
        browser = NetServiceBrowser()
        browser.includesPeerToPeer = true
        browser.delegate = self
        
        browser.stop()
        
        //listening for services...
        browser.schedule(in: RunLoop.current, forMode: .default)
        browser.searchForServices(ofType: self.name, inDomain: self.domain)
        RunLoop.current.run()
    }
    
    // MARK:- Publish Function
    @IBAction func pusblishButtonAction(_ sender: Any) {
        //initialize the NetService object
        self.service = NetService(domain: domain, type: name, name: UIDevice.current.name, port: Int32(80))
        
        //accessing NetService delegate to ViewController object
        self.service?.delegate = self
        
        //publish it
        self.service?.publish()
        
    }
}
  
// MARK:- NetServiceDelegate

extension MultiCastViewController : NetServiceDelegate {
    
    func netServiceDidPublish(_ sender: NetService) {
        
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
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        
        print("error code:\(errorDict)")
    }
    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        debugPrint(errorDict)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        viewModel.castModel.removeAll()
        self.services.append(service)
        if !moreComing {
            for service in self.services {
                service.delegate = self
                service.resolve(withTimeout: 1.0)
            }
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        
        let idxs = self.services.enumerated().filter{ $0.element == service }.map{ $0.offset }
        if self.services.count > 0 {
            self.services.remove(at:idxs[0])
        }
        if viewModel.castModel.count > 0 {
            viewModel.castModel.remove(at: idxs[0])
            
        }
        noDataView.isHidden = true
        tableView.isHidden = false
        
        if viewModel.castModel.count == 0 {
            noDataView.isHidden = false
            tableView.isHidden = true
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        
        self.viewModel.getIpAddress(sender: sender)
        
        noDataView.isHidden = true
        tableView.isHidden = false
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK:- UITableViewDelegate

extension MultiCastViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.castModel.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceDetailsTableViewCellId") as? DeviceDetailsTableViewCell {
            if viewModel.castModel.count > 0 {
                cell.setUpValues(values: viewModel.castModel[indexPath.row])
            }
            return cell
        }
        return UITableViewCell()
    }
}
