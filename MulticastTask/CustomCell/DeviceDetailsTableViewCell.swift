//
//  DeviceDetailsTableViewCell.swift
//  MulticastTask
//
//  Created by adhash on 02/01/22.
//

import UIKit

class DeviceDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var hostNameLbl: UILabel!
    @IBOutlet weak var portnumberLbl: UILabel!
    @IBOutlet weak var ipAddressLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setUpValues(values:MulticastModel?) {
        ipAddressLbl?.text = values?.ipAdd
        hostNameLbl?.text = values?.hostName
        portnumberLbl?.text = "\(values?.port ?? 0)"
    }
}
