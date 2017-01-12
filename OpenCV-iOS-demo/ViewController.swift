//
//  ViewController.swift
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 11/01/2017.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var openCVVersionLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openCVVersionLabel.text = OpenCVWrapper.openCVVersionString()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func onButtonClick(_ sender: UIButton) {
        
        imageView.image = OpenCVWrapper.makeGray(from: imageView.image)
        
    }

}

