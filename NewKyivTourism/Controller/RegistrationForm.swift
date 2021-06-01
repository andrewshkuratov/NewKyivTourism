//
//  RegistrationForm.swift
//  NewKyivTourism
//
//  Created by Andrew on 31.05.2021.
//

import Foundation
import SwiftyJSON
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn

class RegistrationForm: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var googleRegistrationButton: GIDSignInButton!
    
    @IBOutlet weak var emailError: UITextField!
    @IBOutlet weak var passwordError: UITextField!
    
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

extension RegistrationForm: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension RegistrationForm {
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
        guard let mail = email.text, !mail.isEmpty, isValidEmail(mail) else {
            emailError.isHidden = false
            emailError.text = NSLocalizedString("Input your email", comment: "")
            return
        }
        
        guard let pass = password.text, !pass.isEmpty else {
            passwordError.isHidden = false
            passwordError.text = NSLocalizedString("Input your password", comment: "")
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
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
