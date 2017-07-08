//
//  ViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/6/17.
//
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pages: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let messageList = MessageListViewController(nibName: "MessageListViewController", bundle: nil)
        let cameraView = CameraViewController(nibName: "CameraViewController", bundle: nil)
        
        self.addChildViewController(messageList)
        self.pages.addSubview(messageList.view)
        messageList.didMove(toParentViewController: self)
        
        self.addChildViewController(cameraView)
        self.pages.addSubview(cameraView.view)
        cameraView.didMove(toParentViewController: self)
        
        var cameraFrame = cameraView.view.frame
        cameraFrame.origin.x = self.view.frame.width
        cameraView.view.frame = cameraFrame
        
        self.pages.contentSize = CGSize(width: self.view.frame.width * 2, height: self.view.frame.height)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

