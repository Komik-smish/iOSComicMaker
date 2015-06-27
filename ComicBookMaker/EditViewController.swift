//
//  EditViewController.swift
//  ComicBookMaker
//
//  Created by Whitney Lauren on 6/26/15.
//  Copyright (c) 2015 Whitney Lauren. All rights reserved.
//

import UIKit

var originalimage: UIImage?

class EditViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var imageCollection: UICollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollection.dataSource = self
        imageCollection.delegate = self
        editImageView.image = originalimage
        
        var pinchGesture = UIPinchGestureRecognizer(target: self, action: "resizeAccessory")
        
        view.addGestureRecognizer(pinchGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func saveImage(sender: UIButton) {
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("editCell", forIndexPath: indexPath) as! EditCollectionViewCell
        
        //let accessory = accessoryImages[indexPath.item]
        let sword: UIImage = accessoryImages[3]!
        
        cell.accessoryImage.image = sword
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return accessoryImages.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! EditCollectionViewCell
        
        println("\(cell.accessoryImage.image)")
        
        currentAccessory?.image = cell.accessoryImage.image
            
        addNewAccessory()
        
    }
    
    var currentAccessory: UIImageView?
    
    func resizeAccessory(gr: UIPinchGestureRecognizer) {
        
        if let currentAccessory = currentAccessory {
            
            let width = currentAccessory.frame.width
            let height = currentAccessory.frame.height
            
            let scale = 1.0 - ((1.0 - gr.scale) / 2)
            
            currentAccessory.frame.size.height = height + gr.velocity
            currentAccessory.frame.size.width = width + gr.velocity
        }
        
        
    }
    
    func addNewAccessory() {
        
        var newAccessoryView = UIImageView(frame: CGRectMake(0, 0, 200, 200))
        
        newAccessoryView.image = currentAccessory?.image
        newAccessoryView.center = view.center
        
        view.addSubview(newAccessoryView)
        
        currentAccessory = newAccessoryView
        
    }
    
    var startTouchLocation: CGPoint!
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if touches.count > 1 { return }
        
        if let touch = touches.first as? UITouch {
            
            let location = touch.locationInView(editImageView)
            
            startTouchLocation = touch.locationInView(editImageView)
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if touches.count > 1 { return }
        
        if let touch = touches.first as? UITouch {
            
            let location = touch.locationInView(editImageView)
            
            let distance = CGPointMake(location.x - startTouchLocation.x, location.y - startTouchLocation.y)
            
            if let currentAccessory = currentAccessory {
                
                currentAccessory.center = CGPointMake(currentAccessory.center.x + distance.x, currentAccessory.center.y + distance.y)
            }
            
            startTouchLocation = location
        }
        
    }
    
}


