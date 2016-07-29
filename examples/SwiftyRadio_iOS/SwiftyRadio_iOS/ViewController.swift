//
//  ViewController.swift
//  SwiftyRadio_iOS
//
//  Created by Eric Conner on 7/28/16.
//  Copyright © 2016 Eric Conner Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// Setup the station
		swiftyRadio.setStation("WTSQ 88.1FM", URL: "http://stream.wtsq.org:8000/xstream2")
		
		// Start playing the station
		swiftyRadio.play()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}

