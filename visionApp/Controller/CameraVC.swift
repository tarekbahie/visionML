//
//  ViewController.swift
//  visionApp
//
//  Created by tarek bahie on 1/1/19.
//  Copyright © 2019 tarek bahie. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

enum flashState {
    case off
    case on
}

class CameraVC: UIViewController, AVCapturePhotoCaptureDelegate, AVSpeechSynthesizerDelegate {

    var captureSession : AVCaptureSession!
    var cameraOutput : AVCapturePhotoOutput!
    var previewLayer : AVCaptureVideoPreviewLayer!
    var photoData : Data?
    
    var flashControlState : flashState = .off
    var speechSynthesizer = AVSpeechSynthesizer()
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var nameOfItemsLbl: UILabel!
    @IBOutlet weak var confidence: UILabel!
    @IBOutlet weak var flashBtn: RoundedShadowButton!
    @IBOutlet weak var capturedImg: UIImageView!
    @IBOutlet weak var roundedView: RoundedShadowView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
   @objc func handleTap() {
    
    self.cameraView.isUserInteractionEnabled = false
    self.activityIndicator.isHidden = false
    self.activityIndicator.startAnimating()
    
    let settings = AVCapturePhotoSettings()
    let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
    let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String : previewPixelType, kCVPixelBufferWidthKey as String : 160, kCVPixelBufferHeightKey as String : 160]
    settings.previewPhotoFormat = previewFormat
    
    
    if flashControlState == .off {
        settings.flashMode = .off
        
    } else {
        settings.flashMode = .on
    }
    
    
    cameraOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    
    func resultsMethod(request : VNRequest, error : Error?) {
        guard let results = request.results as? [VNClassificationObservation] else{return}
        
        for classification in results {
            if classification.confidence < 0.5 {
                print(classification.identifier)
                print(classification.confidence)
                let unknownObjectMessage = "Not sure what this is. Please try again !"
                self.nameOfItemsLbl.text = unknownObjectMessage
                syenthesizeSpeech(FromString: unknownObjectMessage)
                self.confidence.text = ""
                break
            } else{
                let identification = classification.identifier
                let confidence = Int(classification.confidence * 100)
                self.nameOfItemsLbl.text = identification
                self.confidence.text = "Confidence: \(confidence) %"
                let compSentence = "this looks like a \(identification), i'm \(confidence) percent sure"
                syenthesizeSpeech(FromString: compSentence)
                break
            }
        }
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation()
            
            do {
             let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            } catch {
                debugPrint(error)
            }
            let image = UIImage(data: photoData!)
            self.capturedImg.image = image
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
        speechSynthesizer.delegate = self
        activityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tap = UITapGestureRecognizer(target: self, action: #selector(CameraVC.handleTap))
        tap.numberOfTapsRequired = 1
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try! AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input)  == true {
                captureSession.addInput(input)
            }
            cameraOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(cameraOutput) == true {
                captureSession.addOutput(cameraOutput!)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                cameraView.layer.addSublayer(previewLayer!)
                cameraView.addGestureRecognizer(tap)
                captureSession.startRunning()
            }
            
        } catch {
            debugPrint(error)
        }
    }

    @IBAction func flashBtnPressed(_ sender: Any) {
        switch flashControlState {
        case .off:
            flashBtn.setTitle("Flash is on", for: .normal)
            flashControlState = .on
        case .on:
            flashBtn.setTitle("Flash is off", for: .normal)
            flashControlState = .off
        }
       
    }
    
    func syenthesizeSpeech(FromString string : String){
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynthesizer.speak(speechUtterance)
        if speechSynthesizer.isSpeaking == false {
            
    }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.cameraView.isUserInteractionEnabled = true
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    
}

