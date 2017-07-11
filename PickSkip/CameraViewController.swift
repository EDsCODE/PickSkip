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
import AVKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {

    @IBOutlet weak var photoOptionsView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var tempPhotoView: UIImageView!
    var captureSession : AVCaptureSession?
    var videoOutput = AVCaptureMovieFileOutput()
    var photoOutput = AVCapturePhotoOutput()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var photoSampleBuffer: CMSampleBuffer?
    var previewPhotoSampleBuffer: CMSampleBuffer?
    
    var player: AVPlayer!
    var playerLayer = AVPlayerLayer()

    var recordButton = MyButton()
    
    var backCameraInput: AVCaptureDeviceInput!
    var frontCameraInput: AVCaptureDeviceInput!
    
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
    
    // initiating capture session
    func createCaptureSession(forView: UIView) {
        
        photoOptionsView.isHidden = true
        
        //load recordButton
        recordButton = MyButton(frame: CGRect(x: self.view.frame.width/2 - 35, y: self.view.frame.height - 100, width: 70, height: 70))
        view.addSubview(recordButton)
        let recordRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didHoldRecordButton))
        recordButton.addGestureRecognizer(recordRecognizer)
        let photoRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapRecordButton))
        recordButton.addGestureRecognizer(photoRecognizer)
        let switchCameraRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapScreen))
        switchCameraRecognizer.numberOfTapsRequired = 2
        forView.addGestureRecognizer(switchCameraRecognizer)
        
        
        captureSession = AVCaptureSession()
        captureSession?.addOutput(photoOutput)
        captureSession?.addOutput(videoOutput)
        captureSession?.sessionPreset = AVCaptureSessionPresetHigh
        
        let backCamera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        let mic = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        let frontCamera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
        do {
            backCameraInput = try AVCaptureDeviceInput(device: backCamera)
            frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            captureSession?.addInput(backCameraInput)
            let micInput = try AVCaptureDeviceInput(device: mic)
            captureSession?.addInput(micInput)
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
    
    func didHoldRecordButton(gesture: UITapGestureRecognizer) {
        if gesture.state == .began {
            record()
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsURL.appendingPathComponent("temp.mp4")
            videoOutput.startRecording(toOutputFileURL: filePath, recordingDelegate: self)
            print("Record")
        } else if gesture.state == .ended {
            stop()
            videoOutput.stopRecording()
            print("End Record")
        }
    }

    //capture and display photo
    func didTapRecordButton(gesture: UITapGestureRecognizer) {
        print("Take Photo")
        let settings = AVCapturePhotoSettings()
        
        photoOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    func didDoubleTapScreen(gesture: UITapGestureRecognizer) {
        print("Double tap screen")
        let inputs = captureSession?.inputs as! [AVCaptureDeviceInput]
        self.captureSession?.beginConfiguration()
        if inputs.contains(backCameraInput) {
            captureSession?.removeInput(backCameraInput)
            captureSession?.addInput(frontCameraInput)
        } else if inputs.contains(frontCameraInput) {
            captureSession?.removeInput(frontCameraInput)
            captureSession?.addInput(backCameraInput)
        } else {
            print("No camera found?")
        }
        captureSession?.commitConfiguration()
    }
    
    var didTakePhoto = Bool()
    
    /*func didPressTakeAnother() {
        if didTakePhoto == true {
            tempPhotoView.isHidden = true
            didTakePhoto = false
        } else {
            didTakePhoto = true
            takePhoto()
            captureSession?.startRunning()
        }
    }*/
    
    
    @IBAction func cancelPhotoView(_ sender: UIButton) {
        tempPhotoView.isHidden = true
        videoView.isHidden = true
        recordButton.isHidden = false
        photoOptionsView.isHidden = true
        cameraView.isHidden = false
        if player != nil {
            player.pause()
        }
        playerLayer.removeFromSuperlayer()
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
    
    func record() {
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
    
    func stop() {
        self.progressTimer.invalidate()
        progress = 0
        recordButton.setRecording(false)
        recordButton.setProgress(progress)
    }
    
    public func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        if error != nil {
            print("ERROR RECORDING: \(error.localizedDescription)")
        } else {
            print("Saved to output file: \(outputFileURL)")
            
            player = AVPlayer(url: outputFileURL)
            playerLayer.player = player
            playerLayer.frame = self.tempPhotoView.bounds
            playerLayer.backgroundColor = UIColor.clear.cgColor
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
            self.tempPhotoView.layer.addSublayer(playerLayer)
            tempPhotoView.isHidden = false
            photoOptionsView.isHidden = false
            recordButton.isHidden = true
            
            player.play()
            
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: nil, using: { (_) in
                DispatchQueue.main.async {
                    self.player?.seek(to: kCMTimeZero)
                    self.player?.play()
                }
            })
            
        }
    }
    
    
    
    

}
