//
//  AuthorizationPageController.swift
//  NewKyivTourism
//
//  Created by Andrew on 05.06.2021.
//

import Foundation
import SwiftyJSON
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn

class AuthorizationPageController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var googleRegistrationButton: GIDSignInButton!
    
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var passwordError: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMenu(menuBarButton)
        setupButtons()
        
        email.delegate = self
        password.delegate = self
        
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().restorePreviousSignIn()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(forName: .AccessTokenDidChange, object: nil, queue: OperationQueue.main) { (notification) in
            // Print out access token
            self.createSpinnerView {
                Network.FacebookAuth { (message) in
                    if let message = message {
                        self.invokeAlert(message: message)
                    } else {
                        self.performSegue(withIdentifier: "goToMain", sender: self)
                    }
                }
            }
        }
    }
}

extension AuthorizationPageController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AuthorizationPageController {
    @objc func keyboardWillShow(sender: NSNotification) {
        if !email.isEditing {
            if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                self.view.frame.origin.y = -keyboardHeight
            }
        }
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0
    }
    
    func setupButtons() {
        button.roundCorner()
        button1.roundCorner()
        let fbButton = FBLoginButton()
        stackView.addArrangedSubview(fbButton)
        fbButton.permissions = ["public_profile", "email"]
    }
    
    @IBAction func goToMain(_ sender: Any) {
        emailError.isHidden = false
        password.isHidden = false
        guard let mail = email.text, !mail.isEmpty, isValidEmail(mail) else {
            if email.text!.isEmpty {
                showEmailError(message: NSLocalizedString("Input your email", comment: ""))
            } else if isValidEmail(email.text!) {
                showEmailError(message: NSLocalizedString("Invalid email", comment: ""))
            }
            return
        }
        
        guard let pass = password.text, !pass.isEmpty, pass.count >= 8 else {
            if password.text!.isEmpty {
                showPasswordError(message: NSLocalizedString("Input your password", comment: ""))
            } else if password.text!.count < 8 {
                showPasswordError(message: NSLocalizedString("Invalid password", comment: ""))
            }
            return
        }
        
        let logIn: LoginModel = LoginModel(username: mail, password: pass)
        let data = try! JSONEncoder().encode(logIn)
        
        self.createSpinnerView {
            Network.Authorize(data: data) { message in
                if let message = message {
                    self.invokeAlert(message: message)
                } else {
                    self.performSegue(withIdentifier: "goToMain", sender: self)
                }
            }
        }
    }
    
    private func showEmailError(message: String) {
        emailError.isHidden = false
        emailError.text = message
    }
    
    private func showPasswordError(message: String) {
        passwordError.isHidden = false
        passwordError.text = message
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
