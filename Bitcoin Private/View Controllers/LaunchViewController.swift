//
//  LaunchViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-03-09.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import Socket
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
        testSocketConnection()
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
    func testSocketConnection() {
        do {
            let socket = try Socket.create(family: .inet6, type: .stream, proto: .tcp)
            socket.readBufferSize = 1024*10
            try socket.connect(to: "electrum.btcprivate.org", port: 5222)
            
            print("Socket is connected ", socket.isConnected)
            
            print("Checking remote connection closed", socket.remoteConnectionClosed)
            
            let dic:[String:Any] = [
                "jsonrpc": "2.0",
                "id": 1,
                "method": "blockchain.address.subscribe",
                "params": [
                    "b1PKjricB6ncbATakGCDwu69kxM4R3dUGH4",
                ]
            ]
            
            let data = try JSONSerialization.data(withJSONObject: dic)
            let jsonString = String(data: data, encoding: .utf8)
            
            try socket.write(from: jsonString!)

            print("Wrote to socket:  '\(jsonString ?? "")'")
            
            var readData = Data()
            let bytesRead = try socket.read(into: &readData)
            
            print("Checking remote connection closed", socket.remoteConnectionClosed)
            
            if bytesRead > 0 {
                guard let response = NSString(data: readData, encoding: String.Encoding.utf8.rawValue) else {
                    print("Error decoding response...")
                    return
                }
                print("the response is", response)
            } else {
                print("No response from the server")
            }
            
            print("Checking remote connection closed", socket.remoteConnectionClosed)
            
            socket.close()
            
            print("Socket is connected", socket.isConnected)
        }
        catch let error {
            guard error is Socket.Error else {
                print("Unexpected error...")
                return
            }
        }
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
