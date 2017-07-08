//
//  CameraViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/7/17.
//
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var tempPhotoView: UIImageView!
    var captureSession : AVCaptureSession?
    var photoOutput = AVCapturePhotoOutput()
    var backCameraInput : AVCaptureDeviceInput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var photoSampleBuffer: CMSampleBuffer?
    var previewPhotoSampleBuffer: CMSampleBuffer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCaptureSession(forView: cameraView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        didPressTakeAnother()
    }
    
    // initiating capture session
    func createCaptureSession(forView: UIView) {
        captureSession = AVCaptureSession()
        captureSession?.addOutput(photoOutput)
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let backCamera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        
        do {
            backCameraInput = try AVCaptureDeviceInput(device: backCamera)
            captureSession?.addInput(backCameraInput)
        }
        catch {
            print("Camera input error \(error)")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        if let captureLayer = previewLayer  {
            captureLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            captureLayer.frame.size = forView.frame.size
            forView.layer.addSublayer(captureLayer)
        }
        
        
        captureSession?.startRunning()
        
        
    }

    //capture and display photo
    func takePhoto() {
        print("hello 2")
        let settings = AVCapturePhotoSettings()
        
        photoOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    var didTakePhoto = Bool()
    
    func didPressTakeAnother() {
        if didTakePhoto == true {
            tempPhotoView.isHidden = true
            didTakePhoto = false
        } else {
            didTakePhoto = true
            takePhoto()
            captureSession?.startRunning()
        }
    }
    
    //MARK: - AVCapturePhotoCaptureDelegate
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        
        let dataProvider = CGDataProvider(data: imageData! as CFData)
        
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .right)
        
        self.tempPhotoView.image = image
        self.tempPhotoView.isHidden = false
    }
    
    
    

}
