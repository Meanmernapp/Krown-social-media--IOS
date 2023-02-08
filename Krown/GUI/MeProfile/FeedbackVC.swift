//
//  FeedbackVC.swift
//  Krown
//
//  Created by Mac Mini 2020 on 17/05/22.
//  Copyright © 2022 KrownUnity. All rights reserved.
//

import UIKit

class FeedbackVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var categoryArr = Array<String>()
   
    @IBOutlet weak var feedbackReceivedView: UIView!
    @IBOutlet weak var imgCollection: UICollectionView!
    @IBOutlet weak var txtFeedback: UITextView!
    @IBOutlet weak var btnClip: UIButton!
    @IBOutlet weak var btnSelectCategory: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    var imgArr = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func setup(){
        feedbackReceivedView.isHidden = true
        
        btnSelectCategory.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        btnSelectCategory.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        btnSelectCategory.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        btnSubmit.layer.cornerRadius = 25
        btnSelectCategory.layer.cornerRadius = btnSelectCategory.frame.size.height/2
        txtFeedback.layer.cornerRadius = 15
        txtFeedback.layer.borderColor = UIColor.royalPurple.cgColor
        txtFeedback.layer.borderWidth = 1.0
        btnSubmit.isUserInteractionEnabled = false
        btnSubmit.backgroundColor = UIColor.darkWinterSky
        txtFeedback.isUserInteractionEnabled = false
        txtFeedback.layer.borderColor = UIColor.darkWinterSky.cgColor
        txtFeedback.text = "Please select category before writing your review."
     
       btnClip.isHidden = true
    }
    
    @IBAction func btnClip(_ sender: Any) {
        didPressAddProfileImageBtn()
    }
    
    @IBAction func bckAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
 
    @IBAction func btnSelectCategory(_ sender: Any) {
        presentModal()
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        send()
       // self.navigationController?.popViewController(animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtFeedback {
            let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
            return (newLength > 200) ? false : true
        }  else {
            let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
            return (newLength > 50) ? false : true
        }
    }
    
    private func presentModal() {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
        viewController.modalPresentationStyle = .pageSheet
        viewController.completionBlock = {[weak self] dataReturned in
            //Data is returned **Do anything with it **
            //print(dataReturned)
            self!.categoryArr = dataReturned
            let a = dataReturned.joined(separator: ",")
            self!.btnSelectCategory.setTitle(a, for: .normal)
            
            if dataReturned.count != 0 {
                self!.txtFeedback.isUserInteractionEnabled = true
                self!.txtFeedback.layer.borderColor = UIColor.royalPurple.cgColor
                self!.txtFeedback.text = ""
                self!.btnSubmit.isUserInteractionEnabled = true
                self!.btnSubmit.backgroundColor = UIColor.royalPurple
                self!.btnClip.isHidden = false
            }
        }
        /* if #available(iOS 15.0, *) {
         if let presentationController = viewController.presentationController as? UISheetPresentationController {
         presentationController.detents = [.medium(),.large()] /// change to [.medium(), .large()] for a half *and* full screen sheet
         ///
         presentationController.preferredCornerRadius = 50
         }
         } else {
         // Fallback on earlier versions
         }*/
        
        self.present(viewController, animated: true)
    }
    
    
    func didPressAddProfileImageBtn() {
        let sheet = UIAlertController(title: "Profile Image or Video", message: nil, preferredStyle: .actionSheet)

        let choosePhotoAction = UIAlertAction(title: "Pick photo", style: .default) { (_) in
            /**
             *  Choose photo from library
             */
            let imagePicker = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {

                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }

        let takePhotoAction = UIAlertAction(title: "Shoot Photo", style: .default) { (_) in
            /**
             *  Take photo from camera
             */

            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }

      /*  let gifVideoAction = UIAlertAction(title: "Record GIF Video", style: .default) { [self] (_) in
            /**
             *  Add 3 seconds gif video
             */
            let vc = AppStoryboard.loadTakeVideoVC()
            let navigation = UINavigationController(rootViewController: vc)
            navigation.isNavigationBarHidden = true
            present(navigation, animated: true, completion: nil)

        }*/

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        sheet.addAction(choosePhotoAction)
        sheet.addAction(takePhotoAction)
      // sheet.addAction(gifVideoAction)

        sheet.addAction(cancelAction)

        self.present(sheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        let originalImage = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage)
        
        // Find size of image to set scaling
        let originalImageHeight = originalImage.size.height
        let originalImageWidth = originalImage.size.width
        var scaledImageWidth = CGFloat()
        var scaledImageHeight = CGFloat()
        if originalImageHeight  >= 1000 && originalImageHeight >= originalImageWidth { // if the size of height is more than 1000 px and picture is higher than wide
            scaledImageHeight = CGFloat(1000)
            scaledImageWidth = originalImageWidth / (originalImageHeight / scaledImageHeight) // calculates the new width of the image based on the factors from the original to the scaled image
        } else if originalImageWidth >= 1000 && originalImageWidth >= originalImageHeight { // if the size of width is more than 1000 px and picture is wider than high
            scaledImageWidth = CGFloat(1000)
            scaledImageHeight = originalImageHeight / (originalImageWidth / scaledImageWidth) // calculates the new height of the image based on the factors from the original to the scaled image
        } else {                            // If both height or width is not over 1000
            scaledImageHeight = originalImageHeight
            scaledImageWidth = originalImageWidth
        }
        
        let imageSize = CGSize.init(width: scaledImageWidth, height: scaledImageHeight)
        let scaledImage = originalImage.af.imageScaled(to: imageSize)
        imgArr.append(scaledImage)
        imgCollection.reloadData()
       
        if imgArr.count == 3 {
            btnClip.isHidden = true
        }else{
            btnClip.isHidden = false
        }
       // send(image: scaledImage)
        dismiss(animated: true, completion: nil)
        
    }
    // Helper function inserted by Swift 4.2 migrator.
    private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }

    // Helper function inserted by Swift 4.2 migrator.
    private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
    
    func send() {
        let main = MainController() as MainController
        main.saveFeedback(imgArr, description: txtFeedback.text!, feedback_categories: categoryArr) { (dictionary) in
            //print(dictionary)
            self.feedbackReceivedView.isHidden = false
            let when = DispatchTime.now() + 2.5
            DispatchQueue.main.asyncAfter(deadline: when){
              // your code with delay
                self.navigationController?.popViewController(animated: true)
             
            }
        }
    }
 
}

/*
extension FeedbackVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (!textView.text.isEmpty) {
            btnSubmit.isUserInteractionEnabled = true
            btnSubmit.backgroundColor = UIColor.royalPurple
        } else {
            btnSubmit.isUserInteractionEnabled = false
            btnSubmit.backgroundColor = UIColor.lightPurple
        }
        return true
    }
}
*/
extension FeedbackVC : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return imgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FeedbackImgCell
        
            cell.img.image = imgArr[indexPath.row]
       
                cell.btnClose.tag = indexPath.row
                cell.btnClose.addTarget(self, action: #selector(btnClose(_:)), for: .touchUpInside)
            
            return cell
        
    }
   /* func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        /*let yourWidth = collectionView.bounds.width/3.0
        let yourHeight = yourWidth

        return CGSize(width: yourWidth, height: yourHeight)*/
        
        
        
    }*/
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let totalCellWidth = 80 * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)

        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)

    }
   /* func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }*/

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    @objc func btnClose(_ sender: UIButton) {
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.imgCollection)
        let indexPath = self.imgCollection.indexPathForItem(at: buttonPosition)
        let index = imgArr.firstIndex(of: self.imgArr[indexPath!.row])
        imgArr.remove(at: index!)
        imgCollection.reloadData()
        //print(imgArr)
        if imgArr.count == 3 {
            btnClip.isHidden = true
        }else {
            btnClip.isHidden = false
        }
       
    }
}
