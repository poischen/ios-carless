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

class ChatWindowVC: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    private var messages = [JSQMessage]()
    
    let picker = UIImagePickerController()
    
    var receiverID: String = ""
    var receiverName: String = ""
    var receiverImage: UIImage?
    var selectedUser: String?
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        let navBarView = UIView()
        
        let title = UILabel()
        title.text = receiverName
        title.sizeToFit()
        title.center = navBarView.center
        title.textAlignment = NSTextAlignment.center
        navBarView.addSubview(title)
        
        if let image = receiverImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            let imageAspect = imageView.image!.size.width/imageView.image!.size.height
            imageView.frame = CGRect(x: title.frame.origin.x-title.frame.size.height*imageAspect, y: title.frame.origin.y, width: title.frame.size.height*imageAspect, height: title.frame.size.height)
            navBarView.addSubview(imageView)
        }

        self.navigationItem.titleView = navBarView
        navBarView.sizeToFit()
        
        picker.delegate = self
        
        self.senderId = StorageAPI.shared.userID()
        self.senderDisplayName = "default"
        
        observeUserMessages()
        observeUserMediaMessages()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //COLLECTION VIEW FUNCTIONS
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.blue)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.gray)
        }
        
    }
    
    //profile icon
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "ProfilePic"), diameter: 30)
    }

    //display messages
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    //play videos
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let msg = messages[indexPath.item]
        
        if msg.isMediaMessage {
        if let mediaItem = msg.media as? JSQVideoMediaItem {
            let player = AVPlayer(url: mediaItem.fileURL)
            let playerController = AVPlayerViewController()
            playerController.player = player
            
            self.present(playerController, animated: true, completion: nil)
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
        
      /* MessageHandler.shared.handleSend(senderID: senderId, receiverID: self.selectedUser!, senderName: senderDisplayName, text: text)*/
        
        MessageHandler.shared.handleSend(senderID: senderId, receiverID: self.selectedUser!, text: text)
        
        //remove text from textfield
        finishSendingMessage()
    }
    
    func addMessage(senderID: String, receiverID: String, text: String) {
       messages.append(JSQMessage(senderId: senderID, displayName: "empty", text: text))
        collectionView.reloadData()
    }
    
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
    
    //Sending media button
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
      
        if let pic = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            //let img = JSQPhotoMediaItem(image: pic)
           // messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: img))
            MessageHandler.shared.uploadImageToFirebase(senderID: senderId, receiverID: receiverID, image: pic)
            
        }
        else if let vidUrl = info[UIImagePickerControllerMediaURL] as? URL {
            //let video = JSQVideoMediaItem(fileURL: vidUrl, isReadyToPlay: true)
              //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: video))
            MessageHandler.shared.uploadVideoToFirebase(senderID: senderId, receiverID: receiverID, vidUrl: vidUrl)
           
        }
        
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }

    
    //END FUNCTIONS PICKER VIEW
    
    func observeUserMessages() {
        //logged in user's ID
        guard  let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = StorageAPI.shared.userMessagesRef.child(uid)
        ref.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            let messageID = snapshot.key
            let messageRef = StorageAPI.shared.messagesRef.child(messageID)
            
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
    
    func observeUserMediaMessages() {
        //logged in user's ID
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
