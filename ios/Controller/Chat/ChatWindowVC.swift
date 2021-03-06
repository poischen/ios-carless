//
//  ChatWindowVC.swift
//  ios
//
//  Created by Jelena Pranjic on 03.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import SDWebImage
import Firebase
import Photos
import Kingfisher

class ChatWindowVC: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    private var messages = [JSQMessage]()
    
    let picker = UIImagePickerController()
    let storageAPI = StorageAPI.shared
    
    var receiverID: String = ""
    var receiverName: String = ""
    var receiverImage: UIImage?
    var senderImage: UIImage?
    var selectedUser: String?
    let receiverImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    static let CHATWITHUSER_VIEWCONTROLLER_IDENTIFIER = "ChatWithUser"
    static let CHATWITHUSER_NAVCONTROLLER_IDENTIFIER = "NavControllerChatWindow"
    static let CHAT_STORYBOARD_IDENTIFIER = "ChatStoryboard"
    
    var cameFromOffer: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = receiverImage
        if (image == nil) {
            storageAPI.getUserProfileImageUrl(uID: selectedUser!, completion: { (profileImgUrlString) in
                let profileImgUrl = URL(string: profileImgUrlString)
                self.receiverImageView.kf.setImage(with: profileImgUrl)
                
                self.receiverImage = self.receiverImageView.image
                self.setNavBarTitle()
            })
        } else {
            receiverImageView.image = receiverImage
            self.setNavBarTitle()
        }
        
        storageAPI.getUserProfileImageUrl(uID: storageAPI.userID()!) { (profileImgUrlString) in
            let profileImgUrl = URL(string: profileImgUrlString)
            let tempImageView = UIImageView()
            tempImageView.kf.setImage(with: profileImgUrl)
            
            self.senderImage = tempImageView.image
        }
        
        if cameFromOffer{
            let cancelButton = UIBarButtonItem(
                title: "Cancel",
                style: .plain,
                target: self,
                action: #selector(cancelButton(sender:))
            )
            self.navigationItem.leftBarButtonItem = cancelButton
        }
        
        picker.delegate = self
        
        self.senderId = StorageAPI.shared.userID()
        self.senderDisplayName = "default"
        
        self.collectionView.backgroundColor = Theme.palette.lightgrey
        
        self.inputToolbar.contentView.rightBarButtonItem.setTitleColor(Theme.palette.purple, for: .normal)
        self.inputToolbar.barTintColor = Theme.palette.inputFieldGrey
        
        observeUserMessages()
        observeUserMediaMessages()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelButton(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //COLLECTION VIEW FUNCTIONS
    //gives incoming message bubbles gray & incoming ones blue
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: Theme.palette.purple)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: Theme.palette.orange)
        }
        
    }
    
    //message icon picture
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId {
            if let senderImg = self.senderImage {
                return JSQMessagesAvatarImageFactory.avatarImage(with: senderImg, diameter: 30)
            }
        } else {
            if let receiverImg = self.receiverImage {
                return JSQMessagesAvatarImageFactory.avatarImage(with: receiverImg, diameter: 30)
            }
        }
        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "ProfilePic"), diameter: 30)
    }

    //displays messages
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    //plays videos
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let msg = messages[indexPath.item]
        
        if msg.isMediaMessage {
        if let mediaItem = msg.media as? JSQVideoMediaItem {
            let player = AVPlayer(url: mediaItem.fileURL)
            let playerController = AVPlayerViewController()
            playerController.player = player
            
            self.present(playerController, animated: true, completion: nil)
          }
            
           if let picItem = msg.media as? JSQPhotoMediaItem {
                print("you clicked an image")
                let storyboard = UIStoryboard(name: "ChatStoryboard", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "openImage") as! OpenPictureViewController
               //vc.imageView = picItem as? UIImageView
                self.present(vc, animated: true, completion: nil)
                
            }
        }
    }

    
    //how many messages are in one section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    //pressing send button
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        MessageHandler.shared.handleSend(senderID: senderId, receiverID: self.selectedUser!, text: text)
        
        //remove text from textfield
        finishSendingMessage()
    }
    
    //appends message in Chat Window
    func addMessage(senderID: String, receiverID: String, text: String) {
       messages.append(JSQMessage(senderId: senderID, displayName: "empty", text: text))
        collectionView.reloadData()
    }
    
    //appends picture or video in Chat Window
    func addMediaMessage(senderID: String, receiverID: String, url: String){
        if let mediaURL = URL(string: url){
            
            do {
                
                let data = try Data(contentsOf: mediaURL);
                
                if let _ = UIImage(data: data){
                    
                    let _ = SDWebImageDownloader.shared().downloadImage(with: mediaURL, options: [], progress: nil, completed: { (image, data, error, finished) in
                        
                        DispatchQueue.main.async {
                            let photo = JSQPhotoMediaItem(image: image);
                            
                            if senderID == self.senderId {
                                photo?.appliesMediaViewMaskAsOutgoing = true;
                            } else {
                                photo?.appliesMediaViewMaskAsOutgoing = false;
                            }
                            
                            self.messages.append(JSQMessage(senderId: senderID, displayName: "empty", media: photo));
                            self.collectionView.reloadData();
                        }
                    })
                } else {
                    let video = JSQVideoMediaItem(fileURL: mediaURL, isReadyToPlay: true);
                    if senderID == self.senderId {
                        video?.appliesMediaViewMaskAsOutgoing = true;
                    } else {
                        video?.appliesMediaViewMaskAsOutgoing = false;
                    }
                    messages.append(JSQMessage(senderId: senderID, displayName: "empty", media: video));
                    self.collectionView.reloadData();
                    
                }
            } catch {
                
            }
        }

    }
    
    //Sending media button, pressing the pin
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Media Messages", message: "Please select Media", preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let photos = UIAlertAction(title: "Photos", style: .default, handler: { (alert: UIAlertAction) in self.chooseMedia(type: kUTTypeImage)
        })
        
        let videos = UIAlertAction(title: "Videos", style: .default, handler: { (alert: UIAlertAction) in self.chooseMedia(type: kUTTypeMovie)
        })
        
        alert.addAction(photos)
        alert.addAction(videos)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    //FUNCTIONS FOR PICKER VIEW
    
    private func chooseMedia(type: CFString){
        picker.mediaTypes = [type as String]
        present(picker, animated: true, completion: nil)
    }
    
    // saves video or picture to firebase after choosing it
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
      
        if let pic = info[UIImagePickerControllerOriginalImage] as? UIImage {
            MessageHandler.shared.uploadImageToFirebase(senderID: senderId, receiverID: receiverID, image: pic)
            
        }
        else if let vidUrl = info[UIImagePickerControllerMediaURL] as? URL {
            MessageHandler.shared.uploadVideoToFirebase(senderID: senderId, receiverID: receiverID, vidUrl: vidUrl)
           
        }
        
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
//END FUNCTIONS PICKER VIEW
    
    /* observes text messages in firebase and appends them in the chat */
    func observeUserMessages() {
        guard  let uid = Auth.auth().currentUser?.uid else {
            return
        }
        //observes "user-messages" node, snapshot are the ids of the messages
        let ref = StorageAPI.shared.userMessagesRef.child(uid)
        ref.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            let messageID = snapshot.key
            //observing the "messages" node
            let messageRef = StorageAPI.shared.messagesRef.child(messageID)
            
            //gets entire values from "messages"
            messageRef.observeSingleEvent(of: .value, with: {snapshot in
                if let data = snapshot.value as? NSDictionary {
                    if let senderID = data[DBConstants.SENDER_ID] as? String, let receiverID = data[DBConstants.RECEIVER_ID] as? String, let text = data[DBConstants.TEXT] as? String {
                        if let user = self.selectedUser {
                        if (receiverID == user) || (senderID == user) {
                            self.addMessage(senderID: senderID, receiverID: receiverID, text: text)
                            self.finishReceivingMessage()
                       }
                        }
                    }
                } else {
                    print("Error! Could not decode message data!")
                }
            })
        }
    }
    
    func setNavBarTitle(){
        self.tabBarController?.tabBar.isHidden = true
        
        let navBarImgAndNameView = UIView()
        
        //writes name and picture of the receiver in NavBar
        let title = UILabel()
        title.text = "  " + receiverName
        title.sizeToFit()
        title.center = navBarImgAndNameView.center
        title.textAlignment = NSTextAlignment.center
        navBarImgAndNameView.addSubview(title)
        
        receiverImageView.contentMode = .scaleAspectFit
        let imageAspect = receiverImageView.image!.size.width/receiverImageView.image!.size.height
        receiverImageView.frame = CGRect(x: title.frame.origin.x-title.frame.size.height*imageAspect, y: title.frame.origin.y, width: title.frame.size.height*imageAspect, height: title.frame.size.height)
        receiverImageView.maskCircleContentImage()
        navBarImgAndNameView.addSubview(receiverImageView)
        
        self.navigationItem.titleView = navBarImgAndNameView
        navBarImgAndNameView.sizeToFit()
    }
    
     /* observes media messages in firebase and appends them in the chat */
    func observeUserMediaMessages() {
        guard  let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = StorageAPI.shared.userMessagesRef.child(uid)
        ref.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            let messageID = snapshot.key
            let messageRef = StorageAPI.shared.messagesRef.child(messageID)
            
            messageRef.observeSingleEvent(of: .value, with: {snapshot in
                if let data = snapshot.value as? NSDictionary {
                    if let senderID = data[DBConstants.SENDER_ID] as? String, let receiverID = data[DBConstants.RECEIVER_ID] as? String, let url = data[DBConstants.URL] as? String {
                        if let user = self.selectedUser {
                            if (receiverID == user) || (senderID == user) {
                                self.addMediaMessage(senderID: senderID, receiverID: receiverID, url: url)
                                self.finishReceivingMessage()
                            }
                        }
                    }
                } else {
                    print("Error! Could not decode message data!")
                }
            })
        }
    }
   
}
