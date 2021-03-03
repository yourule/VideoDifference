//
//  ViewController.swift
//  SE Mockup
//
//  Created by Frans-Jan Wind on 02/08/2020.
//  Copyright © 2020 Frans-Jan Wind. All rights reserved.
//

import UIKit
import SwiftUI

final class ViewController: UIViewController, FrameExtractorDelegate {
    
    var frameExtractor: FrameExtractor!
    var previewView: UIView!

    @IBOutlet weak var imageView: UIImageView!
    
//    @IBAction func flipButton(_ sender: UIButton) {
//        frameExtractor.flipCamera()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
        
        previewView = UIView(frame: CGRect(x:0, y:0, width: 320, height: 240))
        previewView.contentMode = UIView.ContentMode.scaleAspectFit
        view.addSubview(previewView)
        try? self.frameExtractor.displayPreview(on: self.previewView)
    }
    
    func captured(image: UIImage) {
//        if imageView.image != nil {
//            imageView.image = image
//        }
    }
    
}

extension ViewController : UIViewControllerRepresentable{
    
    public typealias UIViewControllerType = ViewController
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<ViewController>) -> ViewController {
        return ViewController()
    }
    
    public func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<ViewController>) {
    }
}
