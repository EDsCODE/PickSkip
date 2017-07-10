//
//  CameraViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/7/17.
//
//

import UIKit
import AVFoundation
import RecordButton

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var photoOptionsView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var tempPhotoView: UIImageView!
    var captureSession : AVCaptureSession?
    var photoOutput = AVCapturePhotoOutput()
    var backCameraInput : AVCaptureDeviceInput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var photoSampleBuffer: CMSampleBuffer?
    var previewPhotoSampleBuffer: CMSampleBuffer?

    var recordButton = MyButton()
    
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
    
    func recordButtonPressed(sender: UIButton){
        takePhoto()
    }
    
    // initiating capture session
    func createCaptureSession(forView: UIView) {
        
        photoOptionsView.isHidden = true
        
        //load recordButton
        recordButton = MyButton(frame: CGRect(x: self.view.frame.width/2 - 35, y: self.view.frame.height - 100, width: 70, height: 70))
        recordButton.addTarget(self, action: #selector(recordButtonPressed(sender:)), for: .touchUpInside)
        view.addSubview(recordButton)
        recordButton.addTarget(self, action: #selector(record(sender:)), for: .touchDown)
        recordButton.addTarget(self, action: #selector(stop(sender:)), for: .touchUpInside)
        
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
    
    
    @IBAction func cancelPhotoView(_ sender: UIButton) {
        tempPhotoView.isHidden = true
        recordButton.isHidden = false
        photoOptionsView.isHidden = true
        captureSession?.startRunning()
    }
    
    
    @IBAction func sendPhoto(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ContactView")
        present(vc, animated: true, completion: {_ in} )
    }
    
    
    //MARK: - AVCapturePhotoCaptureDelegate
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        
        let dataProvider = CGDataProvider(data: imageData! as CFData)
        
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .right)
        
        self.tempPhotoView.image = image
        self.recordButton.isHidden = true
        self.tempPhotoView.isHidden = false
        self.photoOptionsView.isHidden = false
    }
    
    //button timer
    var progressTimer : Timer!
    var progress : CGFloat! = 0
    
    func record(sender: UIButton) {
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    func updateProgress() {
        
        let maxDuration = CGFloat(5) // max duration of the recordButton
        
        progress = progress + (CGFloat(0.05) / maxDuration)
        recordButton.setProgress(progress)
        
        if progress >= 1 {
            progressTimer.invalidate()
        }
        
    }
    
    func stop(sender: UIButton) {
        self.progressTimer.invalidate()
        progress = 0
    }
    
    

}
