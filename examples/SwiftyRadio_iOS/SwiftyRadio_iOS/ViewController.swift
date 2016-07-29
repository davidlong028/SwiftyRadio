//
//  ViewController.swift
//  SwiftyRadio_iOS
//
//  Created by Eric Conner on 7/28/16.
//  Copyright © 2016 Eric Conner Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var songTitle: UILabel!
	@IBOutlet weak var artistTitle: UILabel!

	@IBAction func playPauseButton(sender: AnyObject) {
		if swiftyRadio.isPlaying() {
			swiftyRadio.pause()
		} else {
			swiftyRadio.play()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// Setup the station
		swiftyRadio.setStation("WTSQ 88.1FM", URL: "http://stream.wtsq.org:8000/xstream2")
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateView), name: "SwiftyRadioMetadataUpdated", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playWasPressed), name: "SwiftyRadioPlayWasPressed", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(pauseWasPressed), name: "SwiftyRadioPauseWasPressed", object: nil)
		
		swiftyRadio.customMetadata("Press Play to Begin")
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func updateView() {
		songTitle.text = swiftyRadio.trackTitle()
		artistTitle.text = swiftyRadio.trackArtist()
	}
	
	func playWasPressed() {
		swiftyRadio.customMetadata("Loading...")
	}
	
	func pauseWasPressed() {
		swiftyRadio.customMetadata("Paused...")
	}

}

