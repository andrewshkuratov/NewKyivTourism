//
//  RegistrationPageController.swift
//  NewKyivTourism
//
//  Created by Andrew on 05.06.2021.
//

import Foundation
import SKCountryPicker
import SwiftyJSON

class RegistrationPageController: UIViewController {
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var surname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var sex: UISegmentedControl!

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var birthday: UIDatePicker!
    
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var countryName: UIButton!
    
    @IBOutlet weak var loginError: UILabel!
    @IBOutlet weak var nameError: UILabel!
    @IBOutlet weak var surnameError: UILabel!
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var passwordError: UILabel!
    @IBOutlet weak var countryError: UILabel!
    
    @IBOutlet weak var registerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewController()
    }
    
    func setupViewController() {
        registerButton.roundView()
        setupCountryButton()
        setupDate()
        keyboardEffects()
        signForTextFieldDelegate()
    }
    
    func setupCountryButton() {
        guard let country = CountryManager.shared.currentCountry else {
            self.countryName.setTitle(NSLocalizedString("Pick Country", comment: ""), for: .normal)
            self.countryImage.isHidden = true
            return
        }
        
        countryName.setTitle(country.countryName, for: .normal)
        countryImage.image = country.flag
        countryName.clipsToBounds = true
    }
    
    func setupDate() {
        let date = Date()
        birthday.maximumDate = date
    }
    
    @IBAction func register(_ sender: Any) {
        loginError.isHidden = true
        nameError.isHidden = true
        surnameError.isHidden = true
        emailError.isHidden = true
        passwordError.isHidden = true
        countryError.isHidden = true
        
        guard let userName = name.text, !userName.isEmpty, isValidInput(Input: userName) else {
            if name.text!.isEmpty {
                showError(message: NSLocalizedString("Name must not be empty", comment: ""), label: nameError)
            } else if isValidInput(Input: name.text!) {
                showError(message: NSLocalizedString("Invalid user name", comment: ""), label: nameError)
            }
            return
        }
        
        guard let userSurname = surname.text, !userSurname.isEmpty, isValidInput(Input: userSurname) else {
            if surname.text!.isEmpty {
                showError(message: NSLocalizedString("Surname must not be empty", comment: ""), label: surnameError)
            } else if isValidInput(Input: surname.text!) {
                showError(message: NSLocalizedString("Invalid user surname", comment: ""), label: surnameError)
            }
            return
        }
        
        guard let userLogin = login.text, !userLogin.isEmpty, isValidInput(Input: userLogin) else {
            if login.text!.isEmpty {
                showError(message: NSLocalizedString("Login must not be empty", comment: ""), label: loginError)
            } else if isValidInput(Input: login.text!) {
                showError(message: NSLocalizedString("Invalid user login", comment: ""), label: loginError)
            }
            return
        }
        
        guard let userEmail = email.text, !userEmail.isEmpty, isValidEmail(userEmail) else {
            if email.text!.isEmpty {
                showError(message: NSLocalizedString("Email must not be empty", comment: ""), label: emailError)
            } else if isValidEmail(email.text!) {
                showError(message: NSLocalizedString("Invalid user email", comment: ""), label: emailError)
            }
            return
        }
        
        let userSex = getUserSex()
        let userCountry = getCountryName()
        
        guard userCountry != NSLocalizedString("Pick Country", comment: "") else {
            if userCountry == NSLocalizedString("Pick Country", comment: "") {
                showError(message: NSLocalizedString("Pick country", comment: ""), label: countryError)
            }
            return
        }
        
        guard let userPassword = password.text, userPassword.count >= 8 else {
            if password.text!.isEmpty {
                showError(message: NSLocalizedString("Password must not be empty", comment: ""), label: passwordError)
            } else if password.text!.count < 8 {
                showError(message: NSLocalizedString("Invalid password", comment: ""), label: passwordError)
            }
            return
        }
        
        let bday = getBirthday()
        
        let info: ProfileModel = ProfileModel(name: userName,
                                  surname: userSurname,
                                  email: userEmail,
                                  login: userLogin,
                                  country: userCountry,
                                  sex: userSex,
                                  date: bday,
                                  password: userPassword)
        
        let data = try? JSONEncoder().encode(info)
        Network.CreateAccount(data: data!, userEmail: userEmail, userPassword: userPassword) { message in
            if let message = message {
                self.invokeAlert(message: message)
            } else {
                self.performSegue(withIdentifier: "signup", sender: self)
            }
        }
    }
    
    private func showError(message: String, label: UILabel) {
        label.isHidden = false
        label.text = message
    }
    
    private func isValidInput(Input:String) -> Bool {
        let RegEx = "\\w{7,18}"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: Input)
    }
    
    private func getUserSex() -> String {
        switch sex.selectedSegmentIndex {
            case 0:
                return "Чоловіча"
            case 1:
                return "Жіноча"
            default:
                return "Чоловіча"
        }
    }
    
    func getBirthday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.string(from: birthday.date)
    }
    
    @IBAction func countryCodeButtonClicked(_ sender: UIButton) {
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
            guard let self = self else { return }

            self.countryImage.image = country.flag
            self.countryName.setTitle(country.countryName, for: .normal)
        }
        countryController.detailColor = countryController.view.backgroundColor!
    }
}

extension RegistrationPageController {
    func keyboardEffects() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(sender:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(sender:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc
    func keyboardWillShow(sender: NSNotification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            if !login.isEditing && !name.isEditing {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                self.view.frame.origin.y = -keyboardHeight
            }
        }
    }

    @objc
    func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func getCountryName() -> String {
        return (countryName.titleLabel?.text)!
    }
}

extension RegistrationPageController: UITextFieldDelegate {
    func signForTextFieldDelegate() {
        login.delegate = self
        name.delegate = self
        surname.delegate = self
        email.delegate = self
        password.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
