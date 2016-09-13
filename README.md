# SwiftyRadio #
Simple and easy way to build streaming radio apps for iOS, tvOS, & macOS.

## Installation ##
SwiftyRadio can be installed by simply adding the SwiftyRadio.swift file to your project.

## Usage ##
In AppDelegate.swift add the following code after imports and before `@UIApplicationMain`.
```swift
// Create a variable for SwiftyRadio
var swiftyRadio: SwiftyRadio = SwiftyRadio()
```

Include the following code in `viewDidLoad()`
```swift
// Initialize SwiftyRadio
swiftyRadio.setup()
	
// Setup the station
swiftyRadio.setStation("WTSQ 88.1FM", URL: "http://stream.wtsq.org:8000/xstream2")

// Start playing the station
swiftyRadio.play()
```
