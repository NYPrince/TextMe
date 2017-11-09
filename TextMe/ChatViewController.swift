//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting the delegate datasource here and text field :
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextfield.delegate = self
            
        configureTableView()
        retreiveMessages()
        
        messageTableView.separatorStyle = .none
        
        // Set yourself as the delegate of the  here:

        
        
        //TODO: Set the tapGesture here:
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapgesture)

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName:"MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as!CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == FIRAuth.auth()?.currentUser?.email as! String{
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBody.backgroundColor = UIColor.flatSkyBlue()
        }
        else{
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBody.backgroundColor = UIColor.flatGray()
        }
        
        return cell
    }
    
    //TODO: Declare numberOfRowsInSection here:
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageArray.count
    }
    
    //TODO: Declare tableViewTapped here:
    
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    
    //TODO: Declare configureTableView here:
    
    func configureTableView(){
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    //TODO: Declare textFieldDidEndEditing here:
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
        self.heightConstraint.constant = 50
        self.view.layoutIfNeeded()
        }
    }
    
    ///////////////////////////////////////////
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        // Send the message to Firebase and save it in our database
        let messageDB = FIRDatabase.database().reference().child("Messages")
        let messageDictionary = [ "Sender": FIRAuth.auth()?.currentUser?.email, "MessageBody": messageTextfield.text]
        
        messageDB.childByAutoId().setValue(messageDictionary){
            (error, ref) in
            if error != nil{
                print(error)
            }
            else{
                print("Message saved successfully")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                
                self.messageTextfield.text = ""
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retreiveMessages() {
        let messegeDB = FIRDatabase.database().reference().child("Messages")
        messegeDB.observe(.childAdded, with: {(snapshot)in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
        })
    }
        

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do{
         try FIRAuth.auth()?.signOut()
        }
        catch{
            print("There was an error signing out")
        }
        
       guard (navigationController?.popToRootViewController(animated: true)) != nil
        else {
            print("No View Controller to Pop Off")
            return
        }
    }
    


}
