//
//  ViewController.swift
//  MemeMe
//
//  Created by Arch Studios on 4/12/19.
//  Copyright © 2019 AS. All rights reserved.
//

import UIKit


class MemeEditorViewController: UIViewController {
    
    //MARK:- Properties
    var isTopTextFirstEdit = true
    var isBottomTextFirstEdit = true
    
    //MARK:- Outlets
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Textfield's txet attributes
        // I gave the strokeWidth a negative number because i had prpblems with setting the foregroundColor to white and I found the solution here (https://knowledge.udacity.com/questions/6373)
        let memeTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.strokeColor: UIColor.black, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40) as Any, NSAttributedString.Key.strokeWidth: -1.0]
        
        // Setup the top textfeild
        setupTextField(topTextField, text: "TOP", backgroundColor: UIColor.clear, defaultTextAttributes: memeTextAttributes, textAlignment: .center)
        
        // Setup the bottom textfeild
        setupTextField(bottomTextField, text: "BOTTOM", backgroundColor: UIColor.clear, defaultTextAttributes: memeTextAttributes, textAlignment: .center)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Only enable the camera if the device has one
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // only show the share button after choosing an image
        if imageView.image == nil {
            shareButton.isEnabled = false
        } else {
            shareButton.isEnabled = true
        }
        
        // subscribing
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // unsubscribing
        unsbscribeFromKeyboardNotifications()
    }
   
    
    //MARK:- Actions
    // Pick an image from the album
    @IBAction func pickAnImageFromAnAlbum(_ sender: Any) {
        presentPickerViewController(source: UIImagePickerController.SourceType.photoLibrary)
    }
    
    // Take an image from camera
    @IBAction func takeAnImageFromCamera(_ sender: Any) {
        presentPickerViewController(source: UIImagePickerController.SourceType.camera)
    }
    
    // Share an Image
    @IBAction func sahreAnImage(_ sender: Any) {
        // generating a memed image
        let meme = generatedMemedImage()
        
        // define an instance of the ActivityViewController
        let controller = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
        
        controller.completionWithItemsHandler? = {(_, completed, _, _) in
            if completed {
            self.save()
            controller.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
   // MARK:- Keyboard Functions
    @objc func keyboardWillShow(_ notification:Notification) {
        // Shifting the view only when editting the bottom textfield
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsbscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    //MARK:- Custom Functions
    // Setup the textField text
    func setupTextField(_ textField: UITextField, text: String, backgroundColor: UIColor, defaultTextAttributes: [NSAttributedString.Key : Any], textAlignment: NSTextAlignment) {
        textField.text = text
        textField.backgroundColor = backgroundColor
        textField.defaultTextAttributes = defaultTextAttributes
        textField.textAlignment = textAlignment
    }
    
    func presentPickerViewController(source: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = source
        present(controller, animated: true, completion: nil )
    }

    // Generating a screenshot of the memed image
    func generatedMemedImage() -> UIImage {
        // Generate the image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    // Saving the memed image
    func save() {
        
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: generatedMemedImage())
    }
}



// MARK:- UIImagePickerControllerDelegate Functions
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


// MARK:- UITextFieldDelegate Functions
extension MemeEditorViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case topTextField:
            // Only remove topText default text only
            if isTopTextFirstEdit {
                topTextField.text = ""
                isTopTextFirstEdit = false
            }
            
        case bottomTextField:
            // Only remove bottomText default text only
            if isBottomTextFirstEdit {
                bottomTextField.text = ""
                isBottomTextFirstEdit = false
            }
            
        default:
            break
        }
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case topTextField:
            topTextField.resignFirstResponder()
        case bottomTextField:
            bottomTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }
}
