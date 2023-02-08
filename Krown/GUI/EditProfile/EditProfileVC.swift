//
//  EditProfileVC.swift
//  Krown
//
//  Created by KrownUnity on 01/09/16.
//  Copyright © 2016 KrownUnity. All rights reserved.
//

// TODO: https://stackoverflow.com/questions/15665181/uicollectionview-cell-selection-and-cell-reuse/23533588

import UIKit
import Alamofire
import Koloda

class EditProfileVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var profileInfo: PersonObject!
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    fileprivate var shortPressGesture: UIPanGestureRecognizer!

    @IBOutlet weak var occupationTitleLbl: UILabel!
    @IBOutlet weak var educationTitleLbl: UILabel!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var occupationLbl: UILabel!
    @IBOutlet weak var educationLbl: UILabel!
    @IBOutlet weak var statusTextField: UITextView!
    @IBOutlet weak var profileImageCollectionView: UICollectionView!
    var numberOfCards = 0

    @IBAction func addImageBtn(_ sender: Any) {
        didPressAddProfileImageBtn()
    }

    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        // Update the server on back from editProfile

        if (profileInfo) != nil {
        let main = MainController()
        main.uploadEditedProfile(editedProfileObject: profileInfo)
            UserDefaults.standard.set(profileInfo.imageArray, forKey: WebKeyhandler.User.profilePic)
    }
        NotificationCenter.default.post(name: .refreshMenuVC, object: nil)
    }
    @IBAction func swipeExample(_ sender: Any) {
        if profileInfo == nil {return}

        numberOfCards = 1
        // This just clears the current card index and reloads the view so the button can be clicked more than once
        kolodaView.resetCurrentCardIndex()
        kolodaView.isHidden = false

    }

    @IBAction func unwindToVC1(segue: UIStoryboardSegue) {

        if let sourceViewController = segue.source as? takeVideoVC {
            profileInfo.imageArray.append(sourceViewController.PassedURL)
            profileImageCollectionView.reloadData()
        }

    }

    override func viewDidLoad() {

        // Setup moving images
        super.viewDidLoad()
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        profileImageCollectionView.addGestureRecognizer(longPressGesture)
        shortPressGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleShortGesture(gesture:)))
        profileImageCollectionView.addGestureRecognizer(shortPressGesture)
        profileImageCollectionView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        // Setup dismissing keyboard
        self.hideKeyboardWhenTappedAround()

        // Setup of kolodaView
        kolodaView.dataSource = self
        kolodaView.delegate = self
        setupKolodaView()

        // Setup of status text field
        statusTextField.text = "Status"
        statusTextField.textColor = UIColor.lightGray
        statusTextField.layer.cornerRadius = 5

        // Get user from server
        setUserInfo()

    }

    override func viewDidAppear(_ animated: Bool) {
        // Has to be set after the view did appears

        if self.educationLbl.text == "" {
            educationTitleLbl.text = ""
        } else {
            educationTitleLbl.text = "Education"
        }

        if self.occupationLbl.text == "" {
            occupationTitleLbl.text = ""
        } else {
            occupationTitleLbl.text = "Occupation"

        }
    }

    func setUserInfo() {
        // Setup getting the images from the server
        let main = MainController()
        let ownUserID = UserDefaults.standard.object(forKey: WebKeyhandler.User.userID) as! String
        main.distributeMatch(ownUserID) { (profile) in
            self.profileInfo = profile
            self.profileImageCollectionView.reloadData()
            
            // Set occupation
            if profile.position != "" && profile.employment != "" {
                self.occupationLbl.text = profile.position + " - " + profile.employment

            } else if profile.position == "" && profile.employment != "" {
                self.occupationLbl.text = profile.employment

            } else if profile.position != "" && profile.employment == "" {
                self.occupationLbl.text = profile.position
            } else {
                // if no occupation at all
                self.occupationLbl.text = ""
            }

            // Set education
            if profile.school != "" && profile.concentration != "" {
                self.educationLbl.text = profile.concentration + " - " + profile.school

            } else if profile.school != "" && profile.concentration == "" {
                self.educationLbl.text = profile.school

            } else if profile.school == "" && profile.concentration != "" {
                self.educationLbl.text = profile.concentration

            } else {
                // If no education at all
                self.educationLbl.text = ""
            }
            // Set up status field
            if profile.status != ""{
                self.statusTextField.text = profile.status
                self.statusTextField.textColor = UIColor.black
            }
        }
    }

    func setupKolodaView() {

        self.view.addSubview(kolodaView)
        kolodaView.isHidden = true

    }

    @objc func remove(sender: UIButton) {
        let cell = sender.superview as! EditProfileCollectionViewCell
        let indexPath = profileImageCollectionView.indexPath(for: cell)
        let mainController = MainController()
        mainController.deleteProfileImage(profileImageUrl: profileInfo.imageArray[indexPath!.row])
        self.profileInfo.imageArray.remove(at: indexPath!.row)

        self.profileImageCollectionView.performBatchUpdates({

            self.profileImageCollectionView.deleteItems(at: [indexPath!])
        }) { (_) in
            self.profileImageCollectionView.reloadItems(at: self.profileImageCollectionView.indexPathsForVisibleItems)
        }

    }

    func textViewDidBeginEditing(_ textView: UITextView) {
    if statusTextField.textColor == UIColor.lightGray {
            statusTextField.text = ""
            statusTextField.textColor = UIColor.black
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        profileInfo.status = statusTextField.text!
    }

    func textViewDidEndEditing(_ textView: UITextView) {
    if statusTextField.text.isEmpty {
    statusTextField.text = "Status"
    statusTextField.textColor = UIColor.lightGray
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if profileInfo != nil { // When the data has not been loaded // TODO: Bug happening here when the count is changed. Refer to https://fangpenlin.com/posts/2016/04/29/uicollectionview-invalid-number-of-items-crash-issue/#comment-3258706017
            /// if (profileInfo.imageArray.count >= 6){
            // return profileInfo.imageArray.count
        // } else {
            return profileInfo.imageArray.count+1
        // }
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if indexPath.row+1 > profileInfo.imageArray.count && indexPath.row <= 6 { // If the user has less than 6 images show add button // TODO:  bug: if moving around more than 7 cells leads to crash will be solved if solving numberOfItems in section.

            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addProfileCell", for: indexPath)

        } else {

        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "editProfileCell", for: indexPath)
        if let view = cell as? EditProfileCollectionViewCell {

            // Set profile images
            let imageUrl = URL(string: profileInfo.imageArray[indexPath.row])!

            // For handling GIF like video and other picture types
            if imageUrl.pathExtension.lowercased() == WebKeyhandler.imageHandling.mp4 {

                view.looperImage = PlayerLooper(videoURL: imageUrl, loopCount: -1)

            } else {

                let placeholderImage = UIImage(named: "man.jpg")!
                
                //Add authentication header
                var imageUrlRequest = URLRequest(url: imageUrl)
                var headers: HTTPHeaders
                if UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token) != nil {
                    headers = [.authorization(bearerToken: UserDefaults.standard.object(forKey: WebKeyhandler.User.app_auth_token)! as! String)]
                } else {
                    headers = [.authorization(bearerToken: WebKeyhandler.User.app_auth_token),]
                }
                imageUrlRequest.headers = headers

                view.profileImage.af.setImage(
                    withURLRequest: imageUrlRequest,
                    placeholderImage: placeholderImage,
                    imageTransition: .crossDissolve(0.2), completion: { (_) in
                })

            }

            // Customize cell corners
            cell.contentView.layer.cornerRadius = 5
            cell.contentView.layer.borderWidth = 1
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
            cell.contentView.layer.masksToBounds = true

            // Customize cell shadow
            cell.layer.shadowColor = UIColor.darkGray.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.layer.shadowRadius = 2
            cell.layer.shadowOpacity = 1
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
            }

        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if indexPath.row == profileInfo.imageArray.count {
            return false
        } else {
            return true
        }
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Move images in array
        let imageUrl = profileInfo.imageArray.remove(at: sourceIndexPath.item)
        profileInfo.imageArray.insert(imageUrl, at: destinationIndexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        if proposedIndexPath.row == profileInfo.imageArray.count {
            return IndexPath(row: proposedIndexPath.row - 1, section: proposedIndexPath.section)
        } else {
            return proposedIndexPath
        }
    }

    @objc func handleShortGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {

        case .began:
            guard let selectedIndexPath = profileImageCollectionView.indexPathForItem(at: gesture.location(in: profileImageCollectionView)) else {
                break
            }
            profileImageCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            profileImageCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            profileImageCollectionView.endInteractiveMovement()
        default:
            profileImageCollectionView.cancelInteractiveMovement()
        }
    }
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {

            guard let selectedIndexPath = profileImageCollectionView.indexPathForItem(at: gesture.location(in: profileImageCollectionView)) else {
                return
            }

        if selectedIndexPath.row != profileInfo.imageArray.count {

            let cell = profileImageCollectionView.cellForItem(at: selectedIndexPath)

            let editButton = UIButton(frame: CGRect(x: -15, y: -15, width: 30, height: 30))
            editButton.setImage(UIImage(named: "deleteBtn"), for: UIControl.State.normal)
            editButton.addTarget(self, action: #selector(remove(sender:)), for: .touchUpInside)
            cell?.addSubview(editButton)
        }
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

        let gifVideoAction = UIAlertAction(title: "Record GIF Video", style: .default) { [self] (_) in
            /**
             *  Add 3 seconds gif video
             */
            let vc = AppStoryboard.loadTakeVideoVC()
            let navigation = UINavigationController(rootViewController: vc)
            navigation.isNavigationBarHidden = true
            present(navigation, animated: true, completion: nil)

        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        sheet.addAction(choosePhotoAction)
        sheet.addAction(takePhotoAction)
        sheet.addAction(gifVideoAction)

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
        send(image: scaledImage)
        dismiss(animated: true, completion: nil)

    }
    func send(image: UIImage) {
        let main = MainController() as MainController
        main.uploadSingleProfileImage(image) { (dictionary) in
            if let photoUrl = dictionary["url"] {
                let newImageUrl = photoUrl as! String
                // Add photo to profileInfo.imagesArray and to uicollectionView
                self.profileInfo.imageArray.insert(newImageUrl, at: self.profileInfo.imageArray.count)
                self.profileImageCollectionView.reloadData()
            }
        }
    }

}

extension EditProfileVC: KolodaViewDelegate {
}
extension EditProfileVC: KolodaViewDataSource {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        // Hides the view so it is possible to click again on the UI Below
        kolodaView.isHidden = true

    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let swipeDetailView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "swipeDetailView") as! SwipeDetailVC
        swipeDetailView.swipeInfo = profileInfo
        addChild(swipeDetailView)
        swipeDetailView.view.layer.cornerRadius = 20
        swipeDetailView.dislikeButton.isHidden = true
        swipeDetailView.likeButton.isHidden = true
        swipeDetailView.createScrollView(viewSize: kolodaView.frameForCard(at: 0))

        addChild(swipeDetailView)

        return swipeDetailView.view
    }

    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return numberOfCards
    }

    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }

}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
