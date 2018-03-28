//
//  LaunchViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import JSONRPCKit
import SocketSwift
import UIKit

class LaunchViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var createWalletButton: UIButton!
    @IBOutlet var importWalletButton: UIButton!
    @IBOutlet var logoImageView: UIImageView!
    
    @IBAction func createNewWallet() {
        let mnemonicViewController = MnemonicViewController()
        let navigationController = AppNavigationController(rootViewController: mnemonicViewController)
        navigationController.accountCreationDelegate = self

        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func importWallet() {
        let verificationViewController = VerificationViewController(type: .recovery, mnemonic: "")
        let navigationController = AppNavigationController(rootViewController: verificationViewController)
        navigationController.accountCreationDelegate = self
        
        present(navigationController, animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: String(describing: LaunchViewController.self), bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        showButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Just for testing.
        testSocketConnection(address: "b1A6cCtwsNGPeCvMsbo2xWDjgX2p229WyEv")
    }
    
    func setupView() {
        UIApplication.shared.statusBarStyle = .default
        
        navigationController?.isNavigationBarHidden = true
        
        logoImageView.image = UIImage(named: "icon")
        
        createWalletButton.backgroundColor = Colors.primaryDark
        createWalletButton.setTitleColor(Colors.white, for: .normal)
        importWalletButton.backgroundColor = Colors.secondaryDark
        importWalletButton.setTitleColor(Colors.white, for: .normal)
        view.backgroundColor = Colors.lightBackground
        //view.gradientLayer.colors = [Colors.primaryDark.cgColor, Colors.secondaryDark.cgColor]
        //view.gradientLayer.gradient = GradientPoint.topBottom.draw()
    }
    
    func hideButtons() {
        activityIndicator.startAnimating()
        createWalletButton.isHidden = true
        importWalletButton.isHidden = true
    }
    
    func showButtons() {
        activityIndicator.stopAnimating()
        createWalletButton.isHidden = false
        importWalletButton.isHidden = false
    }
    
    func displayWallet() {
        let walletViewController = WalletViewController()
        
        navigationController?.pushViewController(walletViewController, animated: true)
    }
    
    /*
     * TODO : Remove this once testing is completed. This method verifies that our TCP connection to the BTCP socket server is valid.
     */
    func testSocketConnection(address: String) {
        let socket = try! Socket(.inet)
        let addr = try! socket.addresses(for: "electrum.btcprivate.org", port: 5222).first!
        try! socket.connect(address: addr)
        try! socket.startTls(TLS.Configuration(peer: "electrum.btcprivate.org"))

        // Get Balance
        let balance = write(message: String.init(format: "{\"method\": \"blockchain.address.get_balance\", \"params\": [\"\(address)\"], \"id\": 1}\n"), socket: socket)
            
        print("Balance:", balance)
        
        // Get Transaction List
        let transactions = write(message: String.init(format: "{\"method\": \"blockchain.address.get_history\", \"params\": [\"\(address)\"], \"id\": 2}\n"), socket: socket)

        print("Transactions:", transactions)
        
        // Get Transaction Hash
        let transactionHash = write(message: "{\"method\": \"blockchain.transaction.get\", \"params\": [\"6be1a69777992aa8d78e37175ed3cc888d035d967a21e0aff3553e47aa5be2a8\"], \"id\": 3}\n", socket: socket)
        
        print(transactionHash)
        
        socket.close()
    }
    
    func write(message: String, socket: Socket) -> String {
        try! socket.write(message.bytes)
        
        var buffer = [UInt8](repeating: 0, count: 1024)
        let _ = try! socket.read(&buffer, size: 1024)
        
        guard let response = buffer.string else {
            return ""
        }
        
        return response
    }
}

extension Dictionary {
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func dict2json() -> String {
        return json
    }
}

extension LaunchViewController: AccountCreationDelegate {
    func createAccount(mnemonic: String) {
        hideButtons()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.displayWallet()
        }
    }
}

private extension String {
    var bytes: [Byte] {
        return [Byte](self.utf8)
    }
}

private extension Array where Element == Byte {
    var string: String? {
        return String(bytes: self, encoding: .utf8)
    }
}

