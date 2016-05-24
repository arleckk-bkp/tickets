//
//  CustomCell.swift
//  tickets
//
//  Created by Oscar Reynaldo Flores Jimenez on 20/05/16.
//  Copyright © 2016 edcatelecomunicaciones.mx. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    
    @IBOutlet weak var orden: UILabel!
    @IBOutlet weak var estado: UIImageView!
    @IBOutlet weak var lblEstado: UILabel!
    @IBOutlet weak var prioridad: UIImageView!
    @IBOutlet weak var lblPrioridad: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
