//
//  CommentController.swift
//  NewKyivTourism
//
//  Created by Andrew on 02.06.2021.
//

import Foundation

class CommentController: UIViewController {
    @IBOutlet weak var commentsTable: UITableView!
    @IBOutlet weak var commentField: UITextField!
    
    var path = ""
    var locId = 0
    var comments: Array<CommentModel> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        getComment()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        commentsTable.addGestureRecognizer(tap)
    }
}

extension CommentController {
    func setupTable() {
        commentsTable.delegate = self
        commentsTable.dataSource = self
        if path == Constants.Path.location {
            
        }
        commentsTable.register(UINib(nibName: Constants.Cells.commentCell, bundle: nil), forCellReuseIdentifier: Constants.Cells.commentCell)
    }
    
    func getComment() {
        createSpinnerView {
            Network.GetComments(self.path, self.locId) { result in
                switch result {
                case .success(let comments):
                    self.comments = comments
                    self.commentsTable.reloadData()
                    break
                case .failure(let error):
                    self.invokeAlert(message: error.localizedDescription)
                    break
                }
            }
        }
    }
    
    @IBAction func sendComment(_ sender: Any) {
        userIsLoggedInCheck { (isLogged) in
            if isLogged {
                let text = self.commentField.text!
                if text.isEmpty {
                    self.loadAlert(NSLocalizedString("Empty field", comment: ""), completion: {})
                } else {
                    Network.PostComment(self.path, self.locId, text) {
                        self.dismissKeyboard()
                        self.getComment()
                        self.commentField.text = ""
                        self.commentsTable.reloadData()
                    }
                }
            } else {
                self.invokeAlert(message: "You are not logged in")
            }
        }
    }
    
    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    func keyboardWillShow(sender: NSNotification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y = -keyboardHeight
        }
    }

    @objc
    func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0
    }
}

extension CommentController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.commentCell) as! CommentCell
        let item = comments[indexPath.row]
        cell.comment.text = item.comment
        cell.createdAt.text = convertDate(item.createdAt)
        cell.userName.text = item.user?.login
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismissKeyboard()
    }
    
    func convertDate(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let d = dateFormatter.date(from: date)!
        return  d.timeAgoDisplay()
    }
}
