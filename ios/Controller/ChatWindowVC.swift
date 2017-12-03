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

class ChatWindowVC: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var messages = [JSQMessage]();
    
    //pick images to send
    let picker = UIImagePickerController();

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self;
       
        self.senderId = "1";
        self.senderDisplayName = "rihanna";
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory();
        //let message = messages[indexPath.item];
        return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.blue);
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
        
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text));
        collectionView.reloadData();
        
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
            
            let img = JSQPhotoMediaItem(image: pic);
            self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: img));
            
        } else if let vidUrl = info[UIImagePickerControllerMediaURL] as? URL {
            
            let video = JSQVideoMediaItem(fileURL: vidUrl, isReadyToPlay: true);
            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: video));
        }
        
        self.dismiss(animated: true, completion: nil);
        collectionView.reloadData();
    }
    
    @IBAction func BackBtn2(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
    
 

}
