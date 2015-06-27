//
//  EditViewController.swift
//  ComicBookMaker
//
//  Created by Whitney Lauren on 6/26/15.
//  Copyright (c) 2015 Whitney Lauren. All rights reserved.
//

import UIKit
import AFNetworking
import AFAmazonS3Manager

var originalimage: UIImage?

class EditViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var imageCollection: UICollectionView!
    
    // Array of dictionaries
    var accessoriesArray: [AnyObject] = []
    
    var imagesArray: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollection.dataSource = self
        imageCollection.delegate = self
        editImageView.image = originalimage
        editImageView.contentMode = .ScaleAspectFill
        
        RailsRequest.session().getAccessories { () -> Void in
            self.assignAccessories()
            
            self.imageCollection.reloadData()
        }
        
        imageCollection.reloadData()
        
        var pinchGesture = UIPinchGestureRecognizer(target: self, action: "resizeAccessory")
        
        view.addGestureRecognizer(pinchGesture)
    }

    func assignAccessories() {
        
        self.accessoriesArray = RailsRequest.session().singletonAccessoriesArray
        
        println("assignAccesories test 1: \(self.accessoriesArray)")
        
        for dict in self.accessoriesArray {
            
            let imageURLString = dict["accessory_url"] as! String
            let imageURL = NSURL(string: imageURLString)
            let imageData = NSData(contentsOfURL: imageURL!)
            let image = UIImage(data: imageData!)
            
            self.imagesArray.append(image!)
            
        }
        
        println("Test for imagesArray: \(self.imagesArray)")
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
//        let sword: UIImage = accessoryImages[3]!
//        
//        cell.accessoryImage.image = sword
        
        println(imagesArray[indexPath.row])

        cell.accessoryImage.image = imagesArray[indexPath.row]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imagesArray.count
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
    
    @IBAction func sendSavedImage(sender: UIButton) {
        
        saveImageToS3(editImageView.image!)
    }
    
    let s3Manager = AFAmazonS3Manager(accessKeyID: accessKey, secret: secret)
    
    func saveImageToS3(image: UIImage) {
        
        s3Manager.requestSerializer.bucket = bucket
        s3Manager.requestSerializer.region = AFAmazonS3USStandardRegion
        
        let timeStamp = NSDate().timeIntervalSince1970
        
        let imageName = "myImage_\(timeStamp)"
        
        let imageData = UIImagePNGRepresentation(image)
        
        if let documentPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as? String {
            
            let filePath = documentPath.stringByAppendingPathComponent(imageName + ".png")
            
            imageData.writeToFile(filePath, atomically: false)
            
            let fileURL = NSURL(fileURLWithPath: filePath)
            
            s3Manager.putObjectWithFile(filePath, destinationPath:imageName + ".png", parameters: nil, progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                
                let percentageWritten = (CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)) * 100.0
                
                println("Uploaded \(percentageWritten)%")
                
                }, success: { (responseObject) -> Void in
                    
                    let info = responseObject as! AFAmazonS3ResponseObject
                    
                    println("\(info.URL.absoluteString)")
                    
                    RailsRequest.session().imageURL = info.URL.absoluteString!
                    
                    RailsRequest.session().postImageWithCompletion({ () -> Void in
                        
                        println("sent to rails")
                        
                    })
                    
                }, failure: { (error) -> Void in
                    
                    println("\(error)")
                    
                    
            })
            
            
        }
        
    }
    
    
}

func resizeImageWithSize(image: UIImage, newSize: CGSize) -> UIImage {
    println("resize")
    
    var scaleImageRect = CGRectMake(0, 0, newSize.width, newSize.height)
    
    if (newSize.height / newSize.width != image.size.height / image.size.width) {
        
        if (image.size.height > image.size.width) {
            
            //portrait
            
            var ratio = newSize.width / image.size.width;
            var newHeight = ratio * image.size.height;
            var newY = (newSize.height - newHeight) / 2;
            scaleImageRect = CGRectMake(0, newY, newSize.width, newHeight);
            
        } else {
            
            //landscape
            
            var ratio = newSize.height / image.size.height;
            var newWidth = ratio * image.size.width;
            var newX = (newSize.width - newWidth) / 2;
            scaleImageRect = CGRectMake(0, newX, newWidth, newSize.height);
        }
    }
    UIGraphicsBeginImageContext(newSize)
    image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
    var newImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return newImage

}







