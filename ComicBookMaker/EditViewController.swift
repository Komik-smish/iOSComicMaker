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
    

    

}
