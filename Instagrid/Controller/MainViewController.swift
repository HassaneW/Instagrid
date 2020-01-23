//
//  ViewController.swift
//  Instagrid
//
//  Created by WANDIANGA on 15/01/2020.
//  Copyright © 2020 WANDIANGA. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - Initialization
    @IBOutlet weak var swipeToShare: UILabel!
    @IBOutlet weak var mainView : UIView!
    //  Main view buttons
    @IBOutlet weak var buttonImageTopLeft: UIButton!
    @IBOutlet weak var buttonImageTopRight: UIButton!
    @IBOutlet weak var buttonImageBottomLeft: UIButton!
    @IBOutlet weak var buttonImageBottomRight: UIButton!
    // Array of buttons
    @IBOutlet var layoutButtons: [UIButton]!
    // Button that allow us to select the view layout
    @IBOutlet weak var buttonActionLeft: UIButton!
    @IBOutlet weak var buttonActionCenter: UIButton!
    @IBOutlet weak var buttonActionRight: UIButton!
    var buttonTapped : UIButton?
    var imagePicker = UIImagePickerController()
    // Button that allow us to reset images
    var buttonTopLeftTapped = false
    var buttonTopRightTapped = false
    var buttonBottomLeftTapped = false
    var buttonBottomRightTapped = false
    // MARK: - Make a swipe
    override func viewDidLoad() {
        super.viewDidLoad()
        // Swipe gesture left statement
        let leftswipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToShare(_:)))
        leftswipeGesture.direction = .left
        self.view.addGestureRecognizer(leftswipeGesture)
        // Swipe gesture right statement
        let TopswipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToShare(_:)))
        TopswipeGesture.direction = .up
        self.view.addGestureRecognizer(TopswipeGesture)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    @objc func orientationChanged () {
        if UIDevice.current.orientation.isPortrait {
            swipeToShare.text = "Swipe up to share"
        } else {
            swipeToShare.text = "Swipe left to share"
        }
    }
    // Check the orientation of the phone
    func landscape () -> Bool {
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ||
            UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            return true
        }
        return false
    }
    @objc func swipeToShare(_ gesture: UISwipeGestureRecognizer) {
        selectActionButton()
        guard viewImageVerification() else  {
            let alert = UIAlertController(title: "Operation Impossible", message: "You did not fill all the images", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        // Create the correct transform for each gesture direction
        var transform = CGAffineTransform()
        switch gesture.direction {
        case .up:
            transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
        case .left:
            transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
        default:
            print("unknow direction")
        }
        // Animation that pushes the main view out of the screen
        UIView.animate(withDuration: 0.3, animations: {
            self.mainView.transform = transform
        // Once the animation is finished share the images
        },completion: {_ in self.shareImage() })
    }
       //CheckImagesAreFilled
       func viewImageVerification() -> Bool {
           var result = false
           if buttonActionLeft.isSelected {
               result = buttonTopRightTapped && buttonTopLeftTapped && buttonBottomRightTapped
           } else if buttonActionCenter.isSelected {
               result = buttonTopRightTapped && buttonTopLeftTapped && buttonBottomRightTapped
           } else if buttonActionRight.isSelected {
               result = buttonTopRightTapped && buttonTopLeftTapped && buttonBottomRightTapped && buttonBottomLeftTapped
           }
           return result
       }
    // MARK: - Select a layout
    // Check that an action button is selected
    private func selectActionButton() {
        guard !buttonActionLeft.isSelected && !buttonActionCenter.isSelected && !buttonActionRight.isSelected else { return }
        let alert = UIAlertController(title: "Button Action", message:
            "Please select an Action button" , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    // ActionButtonTapped
    @IBAction func layoutButtonTapped(_ sender: UIButton) {
        for button in layoutButtons {
            button.isSelected = false
        }
        sender.isSelected = true
        switch sender {
        case buttonActionLeft:
            buttonActionCenter.isSelected = false
            buttonActionRight.isSelected = false
            buttonImageTopLeft.isHidden = true
            buttonImageBottomLeft.isHidden = false
        case buttonActionCenter:
            buttonActionLeft.isSelected = false
            buttonActionRight.isSelected = false
            buttonImageTopLeft.isHidden = false
            buttonImageBottomLeft.isHidden = true
        case buttonActionRight:
            buttonActionLeft.isSelected = false
            buttonActionCenter.isSelected = false
            buttonImageTopLeft.isHidden = false
            buttonImageBottomLeft.isHidden = false
        default:
            print("button action not managed")
            break
        }
    }
    // MARK: - Share images
    func shareImage() {
        guard let imageToshare = generateImageFromMainView(input: mainView) else {
            print("can not generate image from main view")
            return
        }
        let activityController = UIActivityViewController(activityItems: [imageToshare as Any], applicationActivities: nil)
        activityController.completionWithItemsHandler = {
            (activityType, completed, returnedItems, error)
            in
            print("Share Completed")
        }
        present(activityController, animated: true)
        start()
    }
    // Transform the image buttons into a single image
    func generateImageFromMainView(input : UIView) -> UIImage? {
        UIGraphicsBeginImageContext(input.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        input.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    // MARK: - Retrieve an image from the photo library
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        switch sender {
        case buttonImageTopLeft:
            buttonTopLeftTapped = true
        case buttonImageTopRight:
            buttonTopRightTapped = true
        case buttonImageBottomLeft:
            buttonBottomLeftTapped = true
        case buttonImageBottomRight :
            buttonBottomRightTapped = true
        default:
            break
        }
        buttonTapped = sender
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController,animated: true)
    }
    // MARK: - Return to the original screen
    func start() {
        let originalImage = UIImage(named: "Plus")
        if  buttonActionLeft.isSelected {
            buttonImageTopLeft.setImage(originalImage, for: .normal)
            buttonImageBottomLeft.setImage(originalImage, for: .normal)
            buttonImageBottomRight.setImage(originalImage, for: .normal)
            resetImageButtons()
            resetActionButtons()
            mainView.transform = .identity
        } else if buttonActionCenter.isSelected {
            buttonImageTopRight.setImage(originalImage, for: .normal)
            buttonImageTopLeft.setImage(originalImage, for: .normal)
            buttonImageBottomRight.setImage(originalImage, for: .normal)
            resetImageButtons()
            resetActionButtons()
            mainView.transform = .identity
        } else if buttonActionRight.isSelected {
            buttonImageTopLeft.setImage(originalImage, for: .normal)
            buttonImageTopRight.setImage(originalImage, for: .normal)
            buttonImageBottomLeft.setImage(originalImage, for: .normal)
            buttonImageBottomRight.setImage(originalImage, for: .normal)
            resetImageButtons()
            resetActionButtons()
            mainView.transform = .identity
        } else {
            buttonImageTopLeft.setImage(originalImage, for: .normal)
            buttonImageTopRight.setImage(originalImage, for: .normal)
            buttonImageBottomLeft.setImage(originalImage, for: .normal)
            buttonImageBottomRight.setImage(originalImage, for: .normal)
            resetImageButtons()
            resetActionButtons()
            mainView.transform = .identity
        }
    }
    func resetImageButtons() {
        let originalImage = UIImage(named: "Plus")
        buttonImageTopLeft.setImage(originalImage, for: .normal)
        buttonImageTopRight.setImage(originalImage, for: .normal)
        buttonImageBottomLeft.setImage(originalImage, for: .normal)
        buttonImageBottomRight.setImage(originalImage, for: .normal)
        mainView.transform = .identity
    }
    func resetActionButtons() {
        buttonActionLeft.isSelected = false
        buttonActionCenter.isSelected = false
        buttonActionRight.isSelected = false
    }
}
// MARK: - UIImagePickerController delegate Methode
// Organization of UIImagePicker and delegate method methods
extension MainViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let originalPicture = info[.originalImage] as? UIImage else { return }
        // According to the button select fill the corresponding image
        switch buttonTapped {
        case buttonImageTopLeft:
            buttonImageTopLeft.setImage(originalPicture, for: .normal)
        case buttonImageTopRight:
            buttonImageTopRight.setImage(originalPicture, for: .normal)
        case buttonImageBottomLeft:
            buttonImageBottomLeft.setImage(originalPicture, for: .normal)
        case buttonImageBottomRight:
            buttonImageBottomRight.setImage(originalPicture, for: .normal)
        default:
            break
        }
        buttonTapped = nil
        picker.dismiss(animated: true, completion: nil)
    }
    // Exit the pickerViewController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
