//
//  EditProfilePageController.swift
//  NewKyivTourism
//
//  Created by Andrew on 06.06.2021.
//

import Foundation
import UIKit
import SKCountryPicker

class EditProfilePageController: UIViewController {
    var userImage: UIImage?
    
    var userInfo: ProfileModel? = nil
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var userLastNameField: UITextField!
    @IBOutlet weak var userLoginField: UITextField!
    
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var countryNameField: UIButton!
    
    @IBOutlet weak var userBirthdayPicker: UIDatePicker!
    
    @IBOutlet weak var aboutField: UITextField!
    
    var imagePicker: ImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFields()
        
        let date = Date()
        userBirthdayPicker.maximumDate = date
        
        countryNameField.clipsToBounds = true
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
}

extension EditProfilePageController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y = -keyboardHeight
        }
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    
    func setupFields() {
        userImageView.roundView()
        
        self.userLoginField.text = self.userInfo?.login
        self.userNameField.text = self.userInfo?.name
        self.userLastNameField.text = self.userInfo?.surname
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        if let birthday = self.userInfo?.date {
            if let date = dateFormatter.date(from: birthday) {
                self.userBirthdayPicker.date = date
            }
        }
        self.aboutField.text = self.userInfo?.about
        
        if let image = userInfo!.avatar {
            if let url = URL(string: Constants.Network.baseURL + "/public" + image) {
                userImageView.af.setImage(withURL: url)
            } else {
                userImageView.image = Constants.Images.userImage
            }
        } else {
            userImageView.image = Constants.Images.userImage
        }
        
        if let country = self.userInfo?.country {
            if let locationCountry = CountryManager.shared.country(withName: country) {
                countryImage.image = locationCountry.flag
                countryNameField.setTitle(locationCountry.countryName, for: .normal)
            } else {
                self.countryNameField.setTitle(NSLocalizedString("Pick Country", comment: ""), for: .normal)
                self.countryImage.isHidden = true
            }
        } else {
            self.countryNameField.setTitle(NSLocalizedString("Pick Country", comment: ""), for: .normal)
            self.countryImage.isHidden = true
        }
    }
    
    func sendInfo() {
        guard let userName = userNameField.text, !userName.isEmpty else {
            registrationAlert(NSLocalizedString("Invalid user name", comment: ""))
            return
        }
        
        guard let userSurname = userLastNameField.text, !userSurname.isEmpty else {
            registrationAlert(NSLocalizedString("Invalid user surname", comment: ""))
            return
        }
        
        guard let userLogin = userLoginField.text, !userLogin.isEmpty else {
            registrationAlert(NSLocalizedString("Invalid user login", comment: ""))
            return
        }
        
        let userCountry = getCountryName()
        guard userCountry != "Pick Country" else {
            registrationAlert(NSLocalizedString("Choose Country", comment: ""))
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let bday = dateFormatter.string(from: userBirthdayPicker.date)
        print(#line, bday)
        
        let about = aboutField.text
        
        let info: ProfileModel = ProfileModel(name: userName,
                                              surname: userSurname,
                                              login: userLogin,
                                              country: userCountry,
                                              date: bday,
                                              about: about!)
        
        let data = try? JSONEncoder().encode(info)
        Network.UpdateProfile(data!)
    }
    
    @IBAction func cancelEditing(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func endEditing(_ sender: Any) {
        sendInfo()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editUserImage(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func countryCodeButtonClicked(_ sender: UIButton) {
        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
            guard let self = self else { return }
            if self.countryImage.isHidden {
                self.countryImage.isHidden = false
            }
            self.countryImage.image = country.flag
            self.countryNameField.setTitle(country.countryName, for: .normal)
        }
        countryController.detailColor = countryController.view.backgroundColor!
    }
}

extension EditProfilePageController: ImagePickerDelegate {
    func didSelect(image: UIImage) {
        self.userImageView.image = image
        self.userImage = image
        Network.UpdateAvatar(image, self.userInfo?.login ?? "")
    }
    
    func getCountryName() -> String {
        return (countryNameField.titleLabel?.text)!
    }
}
