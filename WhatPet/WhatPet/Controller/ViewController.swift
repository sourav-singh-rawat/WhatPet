//
//  ViewController.swift
//  WhatPet
//
//  Created by Sourav Singh Rawat on 15/11/22.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePickerController = UIImagePickerController()
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var selectedImagePreview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        
    }


    @IBAction func onCameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePickerController, animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImagePreview.image = selectedImage
            
            guard let ciImage = CIImage(image: selectedImage) else {
                fatalError("CIImage can't be formed")
            }
            
            detectImage(image: ciImage)
            
            imagePickerController.dismiss(animated: true)
        }
    }
    
    func detectImage(image: CIImage){
        do {
            let model = try VNCoreMLModel(for: PetClassifier(configuration: MLModelConfiguration()).model)
            
            let request = VNCoreMLRequest(model: model) { request, error in
                guard let result = request.results as? [VNClassificationObservation] else {
                    fatalError("Model failed to detect image")
                }
                
                if let firstItem = result.first {
                    self.navigationBar.topItem?.title = firstItem.identifier
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            
            try handler.perform([request])
        } catch {
            print("Failed to detect image")
        }
        
    }
}

