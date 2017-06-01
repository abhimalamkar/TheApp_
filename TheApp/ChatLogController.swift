//
//  ChatLogController.swift
//  TheApp
//
//  Created by Abhijeet Malamkar on 2/19/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate ,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var cellId = "cellId"
    
    var user:User? {
        didSet{
            navigationItem.title = user?.name
            
            observemessages()
        }
    }
    
    var messages = [Message]()
    
    let containerView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        
        setupKeyboardObserver()
        
    }
    
    func observemessages(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else {
             return
        }
        
        let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            //print(snapshot)
            
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String:AnyObject] else {
                    return
                }
               
                self.messages.append(Message(dictionary: dictionary))
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    //scroll to last index
                    let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
            
            }, withCancel: nil)
            
            
        }, withCancel: nil)
    }

    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()
    
    func handleUploadTapGesture(){
        
        //inputContainerView.showCameraOptionsAnimated()
        
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
        handleVideoSelectedForUrl(url: videoUrl)
            
        } else {
           
            handleImageSelectedForInfo(info: info as [String : AnyObject])
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedForUrl(url : URL){
        
        let filename = NSUUID().uuidString + ".mov"
       let uploadTask = FIRStorage.storage().reference().child("message-videos").child(filename).putFile(url, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print("failed to upload the video file : ", error as Any)
                return
            }
        
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                
                if let thumbnailImage = self.thumbnailImageForFileUrl(url: url) {
                    
                    self.uploadToFireBaseStorageIseingImage(image: thumbnailImage, completion: { (imageUrl) in
                        let properties:[String : AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject,"imageHeight": thumbnailImage.size.height as AnyObject,"videoUrl": videoUrl as AnyObject]
                        self.sendMessageWithProperties(properties: properties)
                    })
                    
                }
            }
        })
        uploadTask.observe(.progress) { (snapshot) in
           if let fractionCompleted = snapshot.progress?.fractionCompleted {
                 self.navigationItem.title = String(fractionCompleted * 100)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }

    }
    
    private func thumbnailImageForFileUrl(url:URL) -> UIImage? {
        let asset = AVAsset(url: url)
       let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            
           let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let error {
           print(error)
        }
        
        return nil
    }
    
    private func handleImageSelectedForInfo(info: [String:AnyObject]){
    
        var selectedImageFromPicker:UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] {
            selectedImageFromPicker = editedImage as? UIImage
        }
        else if let orignalImage = info[UIImagePickerControllerOriginalImage] {
            selectedImageFromPicker = orignalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            //profileImageView.setImage(selectedImage, for: .normal)
            uploadToFireBaseStorageIseingImage(image: selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl,image : selectedImage)
            })
        }
    }
    
    func uploadToFireBaseStorageIseingImage(image:UIImage , completion: @escaping (_ imageUrl: String) -> ()){
        
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("message_image").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
           ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("Message Image Failed to upload",error as Any)
                return
            }
            
            if let imageUrl = metadata?.downloadURL()?.absoluteString {
                completion(imageUrl)
            }
            
           })
        }
        
    }
    
    
    override var inputAccessoryView:UIView? {
        return self.inputContainerView
    }
    
    override var canBecomeFirstResponder: Bool{
         return true
    }
    
    func setupKeyboardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(hendleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    func hendleKeyboardDidShow(){
        if messages.count > 0 {
            let indexPath = NSIndexPath(item: messages.count - 1, section: 0)
            //collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
            collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        inputAccessoryView?.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimatedFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            // h1 / w1 = h2 / w2
            // solve for h1
            // h1 = h2 / w2 * w1
            
            height = CGFloat(imageHeight / imageWidth * Float(view.frame.width / 2))
            
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimatedFrameForText(text:String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = messages[indexPath.item]
        cell.message = message
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        //modify width
        if let text = message.text {
          cell.textView.isHidden = false
          cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: text).width + 24
        } else if message.imageUrl != nil {
          cell.textView.isHidden = true
          cell.bubbleWidthAnchor?.constant = view.frame.width / 2
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
    
        return cell
    }
    
    
    private func setupCell(cell:ChatMessageCell,message: Message){
        
        if let profileImageUrl = self.user?.profile_image_url {
            cell.profileImageView.loadImageUsingCacheUrlString(urlString: profileImageUrl)
        }
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            //out going blue
            cell.bubbleView.backgroundColor = cell.blueColor
            cell.textView.textColor = .white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.profileImageView.isHidden = true
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheUrlString(urlString: messageImageUrl)
             cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        } else {
            cell.messageImageView.isHidden = true
        }
 
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    
    func handleSend(){
        
        if !(inputContainerView.inputTextField.text?.isEmpty)! {
        let properties:[String : Any] = ["text": inputContainerView.inputTextField.text!]
            sendMessageWithProperties(properties: properties as [String : AnyObject])
            return
        }
        
        inputContainerView.inputTextField.shake()
        
    }
    
    private func sendMessageWithProperties(properties :[String: AnyObject]) {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user?.id
        let fromId = FIRAuth.auth()?.currentUser?.uid
        let timestamp = NSDate().timeIntervalSince1970
        
        var values = ["toId": toId as Any, "fromId": fromId as Any, "timestamp": timestamp] as [String : Any]
        
        //apend 
        properties.forEach({values[$0] = $1})
        
        //childRef.updateChildValues(values)
        childRef.updateChildValues(values) { (error, ref) in
            
            if error != nil {
                print(error as Any)
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId!).child(toId!)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId:1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId!).child(fromId!)
            recipientUserMessagesRef.updateChildValues([messageId:1])
        }
    }
    
    private func sendMessageWithImageUrl(imageUrl:String,image:UIImage){
        let properties:[String : AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject,"imageHeight": image.size.height as AnyObject]
        sendMessageWithProperties(properties: properties)
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView:UIView?
    var startingImageView:UIImageView?
    
    //zoom in logic
    func performZoomInForStartingImageView(startingImageView: UIImageView){
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .purple
        zoomingImageView.contentMode = .scaleAspectFill
        zoomingImageView.image = startingImageView.image
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.isUserInteractionEnabled = true
        
        if let keyWindow = UIApplication.shared.keyWindow {
           
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor(white: 0.2, alpha: 0.3)
            blackBackgroundView?.alpha = 0
            
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                //calculating height
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
        }
    }
    
    func handleZoomOut(tapGesture:UITapGestureRecognizer){
        if let zoomOutImaageView = tapGesture.view {
           
            zoomOutImaageView.layer.cornerRadius = 16
            zoomOutImaageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
               
                zoomOutImaageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }, completion: { (compelted) in
                
                // do somthing
                zoomOutImaageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
            
         }
    }

}
