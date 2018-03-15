//
//  SendAmountViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-10.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class SendAmountViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var indicatorView: UIView!
    @IBOutlet var indicatorTitle: UILabel!
    @IBOutlet var keyboardHolderView: UIView!
    @IBOutlet var keyboardPad1: UIButton!
    @IBOutlet var keyboardPad2: UIButton!
    @IBOutlet var keyboardPad3: UIButton!
    @IBOutlet var keyboardPad4: UIButton!
    @IBOutlet var keyboardPad5: UIButton!
    @IBOutlet var keyboardPad6: UIButton!
    @IBOutlet var keyboardPad7: UIButton!
    @IBOutlet var keyboardPad8: UIButton!
    @IBOutlet var keyboardPad9: UIButton!
    @IBOutlet var keyboardPadDot: UIButton!
    @IBOutlet var keyboardPad0: UIButton!
    @IBOutlet var keyboardPadBackspace: UIButton!
    @IBOutlet var sendAddressLabel: UILabel!
    
    var keyboardPads: [UIButton]!
    var receiver: String = ""
    var sendingAmount: String = ""
    
    @IBAction func sendPayment() {
        guard let amount = amountLabel.text, !amount.isEmpty, amount != "0" else {
            return
        }
    }
    
    @IBAction func keyboardTapped(sender: UIButton) {
        let keyboardPad = keyboardPads[sender.tag]
        if keyboardPad == keyboardPadBackspace {
            if sendingAmount.count > 1 {
                sendingAmount.remove(at: sendingAmount.index(before: sendingAmount.endIndex))
            } else {
                sendingAmount = ""
            }
        } else if keyboardPad == keyboardPadDot {
            if sendingAmount.count == 0 {
                sendingAmount += "0."
            } else if sendingAmount.range(of:".") == nil {
                sendingAmount += "."
            }
        } else {
            if sendingAmount.count == 0 && sender.tag == 0 {
                sendingAmount = ""
            } else {
                sendingAmount += String(sender.tag)
            }
        }
        
        amountLabel.text = sendingAmount.count > 0 ? sendingAmount : "0"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(reciever: String) {
        super.init(nibName: String(describing: SendAmountViewController.self), bundle: nil)
        
        self.receiver = reciever
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        navigationItem.title = "My Wallet"
        
        let image = UIImage(named:"close")
        let rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        indicatorView.isHidden = true
    
        activityIndicator.tintColor = Colors.darkGray
        indicatorTitle.textColor = Colors.darkGray
        sendAddressLabel.textColor = Colors.darkGray
        amountLabel.textColor = Colors.primaryDark
        currencyLabel.textColor = Colors.darkGrayTransparent
        keyboardHolderView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.primaryDark
        
        sendAddressLabel.text = "To: \(receiver)"

        keyboardPads = [keyboardPad0, keyboardPad1, keyboardPad2, keyboardPad3, keyboardPad4, keyboardPad5, keyboardPad6, keyboardPad7, keyboardPad8, keyboardPad9, keyboardPadDot, keyboardPadBackspace]
        
        for (index, keyboardPad) in keyboardPads.enumerated() {
            keyboardPad.tintColor = Colors.primaryDark
            keyboardPad.setTitleColor(Colors.primaryDark, for: .normal)
            keyboardPad.backgroundColor = Colors.lightBackground
            keyboardPad.tag = index
        }
    }
    
    @objc func dismissView() {
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }
}


