//
//  CameraViewController.swift
//  TheApp
//
//  Created by Abhijeet Malamkar on 2/25/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let captureSession = AVCaptureSession()
    var previewLayer:CALayer?
    var uiView = UIView()

    var captureDevice:AVCaptureDevice?
    
    var takePhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepairCamera()
        view.addSubview(uiView)
        uiView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        uiView.backgroundColor = .clear
        uiView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCamera)))
        uiView.isUserInteractionEnabled = true
    }
    
    func handleCamera(){
        print("captureing image....")
        takePhoto = true
    }
    
    func prepairCamera(){
         captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .front).devices {
           captureDevice = availableDevices.first
           beginSession()
        }
    }
    
    func beginSession(){
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
           self.previewLayer = previewLayer
            self.view.layer.addSublayer(self.previewLayer!)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer.frame = self.view.bounds
            
            captureSession.startRunning()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value: kCVPixelFormatType_32BGRA)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
              captureSession.addOutput(dataOutput)
                
            }
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.TheApp.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if takePhoto {
            takePhoto = false
            if let image =  getImageFromSampleBuffer(buffer: sampleBuffer){
                let photoView = PhotoViewController()
                photoView.takenPhoto = image
                
                DispatchQueue.main.async {
                    self.present(photoView, animated: true, completion: { 
                        self.stopCaptureSession()
                    })
                }
            }
        }
    }
    
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer){
            let ciImage = CIImage(cvImageBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect){
                 return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        
        return nil
    }

    func stopCaptureSession(){
       self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
               self.captureSession.removeInput(input)
            }
        }
    }
   
}
