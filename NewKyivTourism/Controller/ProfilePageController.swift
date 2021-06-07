//
//  ProfilePageController.swift
//  NewKyivTourism
//
//  Created by Andrew on 06.06.2021.
//

import Foundation
import Alamofire
import AlamofireImage
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class ProfilePageController: UIViewController {
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var achievements: UICollectionView!
    @IBOutlet weak var route: UILabel!
    @IBOutlet weak var seeMore: UIButton!
    
    @IBOutlet weak var editProfile: UIButton!
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var achievementsView: UIView!
    
    @IBOutlet weak var countryStackView: UIStackView!
    @IBOutlet weak var birthdayStackView: UIStackView!
    @IBOutlet weak var aboutStackView: UIStackView!
    
    var name: String = ""
    var userInfo: ProfileModel? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        achievements.dataSource = self
        achievements.delegate = self
        self.setMenu(menuBarButton)
        setupButtons()
        isolateView(view: aboutView, userView, achievementsView)
        NotificationCenter.default.addObserver(forName: .AccessTokenDidChange, object: nil, queue: OperationQueue.main) { (notification) in
            // Print out access token
            print("FB Access Token: \(String(describing: AccessToken.current?.tokenString))")
            self.logout()
        }
    }
}

extension ProfilePageController {
    func setInfo() {
        guard let userInfo = userInfo else {
            return
        }
        name = (userInfo.name ?? "") + " " + (userInfo.surname ?? "")
        userName.text = name
        if let image = userInfo.avatar {
            removeImageCache(avatar: "/public" + image)

            if let url = URL(string: Constants.Network.baseURL + "/public" + image) {
                userImage.af.setImage(withURL: url)
            } else {
                userImage.image = Constants.Images.userImage
            }
        } else {
            userImage.image = Constants.Images.userImage
        }
        userImage.roundView()
        self.achievements.reloadData()
        
        countryLabel.text = userInfo.country
        countryStackView.isHidden = (userInfo.country ?? "").isEmpty
        
        birthdayLabel.text = userInfo.date
        birthdayStackView.isHidden = (userInfo.date ?? "").isEmpty
        
        aboutLabel.text = userInfo.about
        aboutStackView.isHidden = (userInfo.about ?? "").isEmpty
        
        aboutView.isHidden = (userInfo.country ?? "").isEmpty && (userInfo.date ?? "").isEmpty && (userInfo.about ?? "").isEmpty
    }
    
    func removeImageCache(avatar: String) {
        let urlRequest = URLRequest(url: URL(string: Constants.Network.baseURL + avatar)!)
        let imageDownloader = ImageDownloader.default
        if let imageCache = imageDownloader.imageCache as? AutoPurgingImageCache,
            let urlCache = imageDownloader.session.sessionConfiguration.urlCache {
            _ = imageCache.removeImages(matching: urlRequest)
            urlCache.removeCachedResponse(for: urlRequest)
        }
    }
    
    func setupButtons() {
        seeMore.roundCorner(15)
        
        editProfile.addBorder(.label, 2)
        editProfile.roundCorner(15)
        
        addLogoutButton()
    }
    
    func loadData() {
        createSpinnerView {
            Network.sendRequest(endpoint: .profile, data: nil, type: ProfileModel.self) { result in
                switch result {
                case .success(let response):
                    self.view.isHidden = false
                    self.userInfo = response
                    self.setInfo()
                    break
                case .failure(let error):
                    self.view.isHidden = true
                    self.loadAlert(error.localizedDescription) {
                        
                    }
                    break
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editProfileSegue" {
            let nextViewController = segue.destination as! EditProfilePageController
            nextViewController.userInfo = self.userInfo
        }
    }
    
    @objc
    func logout() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Constants.UserDefaults.isLoggedIn)
        defaults.removeObject(forKey: Constants.UserDefaults.accessToken)
        defaults.removeObject(forKey: Constants.UserDefaults.tokenType)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(identifier: "MainPage") as! MainPage
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @objc
    func googleLogout() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Constants.UserDefaults.accessToken)
        defaults.removeObject(forKey: Constants.UserDefaults.tokenType)
        GIDSignIn.sharedInstance().signOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(identifier: "MainPage") as! MainPage
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func addLogoutButton() {
        if UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoggedIn) {
            let button = UIButton()
            button.setTitle(NSLocalizedString("Logout", comment: ""), for: .normal)
            button.backgroundColor = .systemRed
            button.roundCorner(15)
            button.addTarget(self, action: #selector(logout), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        else if AccessToken.current?.isExpired != nil {
            let fbButton = FBLoginButton()
            fbButton.roundCorner(15)
            stackView.addArrangedSubview(fbButton)
        }
        else if let signIn = GIDSignIn.sharedInstance(), signIn.hasPreviousSignIn() {
            let button = UIButton()
            button.setTitle(NSLocalizedString("Logout", comment: ""), for: .normal)
            button.backgroundColor = .systemRed
            button.roundCorner(15)
            button.addTarget(self, action: #selector(googleLogout), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
    
    func isolateView(view: UIView...) {
        view.forEach { (item) in
            item.addBorder(.label, 2)
            item.roundCorner(12)
        }
    }
}

extension ProfilePageController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = achievements.dequeueReusableCell(withReuseIdentifier: "achievementCell", for: indexPath) as! AchievmentsCell
        if let d = userInfo?.distance {
            let dist = String(format: "%.2f", d)
            cell.achieve.text = "\(dist) " + NSLocalizedString("km", comment: "")
        } else {
            cell.achieve.text = "0 " + NSLocalizedString("km", comment: "")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return UICollectionViewFlowLayout.automaticSize
    }
    
    func getSocialImage(_ image: String) -> UIImage? {
        if (image != "") {
            let imgURLString = image + "&redirect=true&width=500&height=500"
            let imgURL = URL(string: imgURLString)
            let imageData = try! Data(contentsOf: imgURL!)
            let image = UIImage(data: imageData)
            return image
        }
        return nil
    }
}
