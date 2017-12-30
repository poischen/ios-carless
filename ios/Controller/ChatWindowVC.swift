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

class ChatWindowVC: JSQMessagesViewController, MessageReceivedDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var receiverId: String = ""
    
    private var users = [User]();
    
    private var messages = [JSQMessage]();
    
    //pick images to send
    let picker = UIImagePickerController();

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self;
        MessageHandler._shared.delegate = self;
       
        self.senderId = StorageAPI.shared.userID();
        self.senderDisplayName = StorageAPI.shared.userName;
        
        MessageHandler._shared.observeMessages();
        MessageHandler._shared.observeMediaMessages();
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory();
        let message = messages[indexPath.item];
        
        if message.senderId == self.senderId {
           return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.blue);
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.green);
        }
       
    }
    
    //profile icon
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "ProfilePic"), diameter: 30);
    }
    
    //display messages
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData {
        return messages[indexPath.item];
    }
    
    //play videos
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let msg = messages[indexPath.item];
        
        if let mediaItem = msg.media as? JSQVideoMediaItem {
            let player = AVPlayer(url: mediaItem.fileURL);
            let playerController = AVPlayerViewController();
            playerController.player = player;
            
            self.present(playerController, animated: true, completion: nil);
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //pressing send button
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        // TODO  wrong for now
        MessageHandler._shared.sendMessage(senderID: senderId, senderName: senderDisplayName, text: text, receiverID: self.receiverId);
        
        //remove text from textfield
        finishSendingMessage();
    }
    
    
    //Sending media button
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Media Messages", message: "Please select Media", preferredStyle: .actionSheet);
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        
        let photos = UIAlertAction(title: "Photos", style: .default, handler: { (alert: UIAlertAction) in self.chooseMedia(type: kUTTypeImage);
        })
        
        let videos = UIAlertAction(title: "Videos", style: .default, handler: { (alert: UIAlertAction) in self.chooseMedia(type: kUTTypeMovie);
        })
        
        alert.addAction(photos);
        alert.addAction(videos);
        alert.addAction(cancel);
        present(alert, animated: true, completion: nil);
    }
    
    //FUNCTIONS FOR PICKER VIEW
    
    private func chooseMedia(type: CFString){
        picker.mediaTypes = [type as String]
        present(picker, animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pic = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let data = UIImageJPEGRepresentation(pic, 0.01);
            
            MessageHandler._shared.sendMedia(image: data, video: nil, senderID: senderId, senderName: senderDisplayName);
            
        } else if let vidUrl = info[UIImagePickerControllerMediaURL] as? URL {
            
            MessageHandler._shared.sendMedia(image: nil, video: vidUrl, senderID: senderId, senderName: senderDisplayName);
        
        }
        
        self.dismiss(animated: true, completion: nil);
        collectionView.reloadData();
    }
    
    func messageReceived(senderID: String, text: String) {
        messages.append(JSQMessage(senderId: senderID, displayName: "empty", text: text));
        collectionView.reloadData();
    }
    
    func mediaReceived(senderID: String, senderName: String, url: String) {
        
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
                            
                            self.messages.append(JSQMessage(senderId: senderID, displayName: senderName, media: photo));
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
                    messages.append(JSQMessage(senderId: senderID, displayName: senderName, media: video));
                    self.collectionView.reloadData();
                }
            } catch {
                
            }
        }
        
    }
    
    @IBAction func BackBtn2(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
    
 

}
