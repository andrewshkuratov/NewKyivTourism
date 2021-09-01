//
//  FeedBack.swift
//  KyivTourismApp
//
//  Created by Andrew on 29.12.2020.
//

import Foundation
import SwiftUI
import FBSDKCoreKit
import FBSDKLoginKit

class FeedBackViewController: UIViewController {
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var theContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMenu(menuBarButton)
        addSwiftUIView()
    }
    
    func addSwiftUIView() {
        let childView = UIHostingController(rootView: FeedbackView())
        addChild(childView)
        childView.view.frame = theContainer.bounds
        theContainer.addConstrained(subview: childView.view)
        childView.didMove(toParent: self)
    }
}


struct FeedbackView: View {
    @State var question: String = ""
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Зворотній зв'язок")
                        .font(.largeTitle)
                        .fontWeight(.medium)
                    Text("Комунальне підприємство виконавчого органу Київської міської ради (Київської міської державної адміністрації) «Київський міський туристично-інформаційний центр»")
                    Text("(місто Київ, вул. Бойчука, 21, контактний телефон +38-044-599-94-93)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.blue)
                        Text("15-51 – гаряча лінія")
                            .foregroundColor(.blue)
                    }
                    HStack {
                        Image(systemName: "mail.fill")
                            .foregroundColor(.blue)
                        Text("kpkmtic@ukr.net")
                            .foregroundColor(.blue)
                    }
                    HStack {
                        Image(systemName: "mail.fill")
                            .foregroundColor(.blue)
                        Text("kpkmtic2019@gmail.com")
                            .foregroundColor(.blue)
                    }
                    Text("Якщо виникли питання, можете залишити нам повідомлення, заповнивши форму.")
                        .padding(.bottom)
                    Text("Ваше запитання")
                        .padding(.top)
                    TextField("Input your question here", text: $question)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Відправити") {
                        let userDefaults = UserDefaults.standard

                        if userDefaults.bool(forKey: Constants.UserDefaults.isLoggedIn) {
                            if question.isEmpty {
                                showingAlert = true
                            } else {
                                Network.Feedback(question)
                                question = ""
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                            }
                        }
                        else if ((AccessToken.current?.isExpired) != nil) {
                            if question.isEmpty {
                                showingAlert = true
                            } else {
                                Network.Feedback(question)
                                question = ""
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                            }
                        }
                        else {
                            showingAlert = true
                        }
                        print(question)
                    }.alert(isPresented: $showingAlert) {
                        var title = ""
                        var message = ""
                        if !UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoggedIn) &&
                            ((AccessToken.current?.isExpired) == nil) {
                            title = NSLocalizedString("You are not entered yout account", comment: "")
                            message = NSLocalizedString("LogIn to your account to send feedback", comment: "")
                        } else {
                            title = NSLocalizedString("Empty field", comment: "")
                            message = NSLocalizedString("Please, enter your message", comment: "")
                        }
                        return Alert(title: Text(title),
                                     message: Text(message),
                                     dismissButton: .cancel())
                    }
                        .frame(width: UIScreen.main.bounds.width - 30,
                               height: 50,
                               alignment: .center)
                        .background(Color(Constants.Color.contentsTypeColor))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }.padding(.all)
    }
}
