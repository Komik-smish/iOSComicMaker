//
//  BubbleViewController.swift
//  ComicBookMaker
//
//  Created by Whitney Hogg on 6/27/15.
//  Copyright (c) 2015 Whitney Lauren. All rights reserved.
//

import UIKit
import AVFoundation

class BubbleViewController: UIViewController, AVAudioPlayerDelegate, UIScrollViewDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet weak var recordingOutlet: UIButton!
    @IBOutlet weak var soundLabel: UILabel!
    @IBOutlet weak var stopOutlet: UIButton!
    
    var audioPlayer: AVAudioPlayer!
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    
    var filePath: NSURL!
    
    
    
    @IBAction func stopButton(sender: AnyObject) {
        
        soundLabel.hidden = true
        recordingOutlet.enabled = true
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
    
    
    @IBAction func recordButton(sender: AnyObject) {
        
        stopOutlet.hidden = false
        soundLabel.hidden = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        var currentDateTime = NSDate()
        var formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        var recordingName = formatter.stringFromDate(currentDateTime) + ".wav"
        var pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        println(filePath)
        
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
    }

    
    var editImages: [AnyObject] = []
    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []
    
    func assignImages() {
        
        self.editImages = RailsRequest.session().singletonImagesArray
        
        println("assign images test 2: \(self.editImages)")
        
        for dict in self.editImages {
            

                let imageURLString = dict["image_url"] as! String
                let imageURL = NSURL(string: imageURLString)
                let imageData = NSData(contentsOfURL: imageURL!)
                let image = UIImage(data: imageData!)
                
                self.pageImages.append(image!)

            
        }
        
        println("Test for pagesImages: \(self.pageImages)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the image you want to scroll & zoom and add it to the scroll view
//        pageImages = [UIImage(named:"photo1.png")!,
//            UIImage(named:"photo2.png")!,
//            UIImage(named:"photo3.png")!,
//            UIImage(named:"photo4.png")!,
//            UIImage(named:"photo5.png")!]
        
        RailsRequest.session().getImages { () -> Void in
            
            self.assignImages()
            
        }
        
        let pageCount = pageImages.count
        
        // Set up the page control
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount
        
        // Set up the array to hold the views for each page
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        // Set up the content size of the scroll view
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * CGFloat(pageImages.count), pagesScrollViewSize.height)
        
        // Load the initial set of pages that are on screen
        loadVisiblePages()
        
        
    }
    
    func loadPage(page: Int) {
        
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Load an individual page, first checking if you've already loaded it
        if let pageView = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            frame = CGRectInset(frame, 10.0, 0.0)
            
            let newPageView = UIImageView(image: pageImages[page])
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
            pageViews[page] = newPageView
        }
    }
    
    func purgePage(page: Int) {
        
        
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
        
    }
    
    func loadVisiblePages() {
        
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for var index = firstPage; index <= lastPage; ++index {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < pageImages.count; ++index {
            purgePage(index)
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
       
        if(flag) {
            
            // store in model
            
            
            recordedAudio.filePathURL = recorder.url
            recordedAudio.title = recorder.url.lastPathComponent
            
            // segway once weve finished processing audio
        } else {
            
            println("recording not successful")
            recordingOutlet.enabled = true
            stopOutlet.hidden = true
        }
        
        
    }
    


}
