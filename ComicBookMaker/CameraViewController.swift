//
//  ViewController.swift
//  ComicBookMaker
//
//  Created by Whitney Lauren on 6/26/15.
//  Copyright (c) 2015 Whitney Lauren. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        
        self.presentViewController(imagePicker, animated: false, completion: nil)
    
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        originalimage = image
        
        let editVC = self.storyboard?.instantiateViewControllerWithIdentifier("editVC") as! EditViewController
        
        self.navigationController?.pushViewController(editVC, animated: true)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

