//
//  SwiftyRadio.swift
//  Swifty Radio
//  Simple and easy way to build streaming radio apps for iOS, tvOS, & macOS
//
//  Version 1.2.3
//  Created by Eric Conner on 7/9/16.
//  Copyright © 2016 Eric Conner Apps. All rights reserved.
//

import Foundation
import AVFoundation

#if os(iOS) || os(tvOS)
	import MediaPlayer
#endif

/// Simple and easy way to build streaming radio apps for iOS, tvOS, & macOS
public class SwiftyRadio: NSObject {

//*****************************************************************
// MARK: - SwiftyRadio Variables
//*****************************************************************
	private var Player: AVPlayer!
	private var PlayerItem: AVPlayerItem!
	private var track: Track!
	private var stationInfo: StationInfo!

	private struct Track {
		var title: String = ""
		var artist: String = ""
		var isPlaying: Bool = false
	}

	private struct StationInfo {
		var name: String = ""
		var URL: String = ""
		var shortDesc: String = ""
		var albumArt: UIImage = UIImage()
	}


//*****************************************************************
// MARK: - Initialization Functions
//*****************************************************************
	/// Initial setup for SwiftyRadio. Should be included in AppDelegate.swift under `didFinishLaunchingWithOptions`
	public func setup() {
		#if os(iOS) || os(tvOS)
			NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioRouteChangeListener(_:)), name: AVAudioSessionRouteChangeNotification, object: nil)
			NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(audioInterruption(_:)), name: AVAudioSessionInterruptionNotification, object: nil)

			// Set AVFoundation category, required for background audio
			do {
				try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
			} catch {
				print("Setting category to AVAudioSessionCategoryPlayback failed")
			}
		#endif

		track = Track()
	}

	/// Setup the station, must be called before `Play()`
	/// - parameter stationName: Name of the station
	/// - parameter URL: The station URL
	/// - parameter shortDesc: A short description of the station **(Not required)**
	/// - parameter albumArt: Name of image to display as album art **(Not required)**
	public func setStation(stationName: String, URL: String, shortDesc: String = "", albumArt: UIImage = UIImage()) {
		stationInfo = StationInfo(name: stationName, URL: URL, shortDesc: shortDesc, albumArt: albumArt)
	}


//*****************************************************************
// MARK: - General Functions
//*****************************************************************
	/// Get the current playing track title. Use with notification `SwiftyRadioMetadataUpdated`
	/// - returns: Text string of the track title.
	public func trackTitle() -> String {
		return track.title
	}

	/// Get the current playing track artist. Use with notification `SwiftyRadioMetadataUpdated`
	/// - returns: Text string of the track artist.
	public func trackArtist() -> String {
		return track.artist
	}

	/// Get the current playing state
	/// - returns: `True` if SwiftyRadio is playing and `False` if it is not
	public func isPlaying() -> Bool {
		return track.isPlaying
	}

	/// Plays the current set station. Uses notification `SwiftyRadioPlayWasPressed`
	public func play() {
		if stationInfo.URL != "" {
			if !isPlaying() {
				PlayerItem = AVPlayerItem(URL: NSURL(string: stationInfo.URL)!)
				PlayerItem.addObserver(self, forKeyPath: "timedMetadata", options: NSKeyValueObservingOptions.New, context: nil)
				PlayerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
				
				Player = AVPlayer(playerItem: PlayerItem)
				Player.play()
				
				track.isPlaying = true
				NSNotificationCenter.defaultCenter().postNotificationName("SwiftyRadioPlayWasPressed", object: nil)
			} else {
				print("ERROR: SwiftyRadio is already playing")
			}
		} else {
			print("ERROR: Station has not been setup")
		}
	}

	/// Pauses the current set station. Uses notification `SwiftyRadioPauseWasPressed`
	public func pause() {
		if isPlaying() {
			Player.pause()
			PlayerItem.removeObserver(self, forKeyPath: "timedMetadata")
			PlayerItem.removeObserver(self, forKeyPath: "status")
			Player = nil
			track.isPlaying = false
			NSNotificationCenter.defaultCenter().postNotificationName("SwiftyRadioPauseWasPressed", object: nil)
		} else {
			print("ERROR: SwiftyRadio is already paused")
		}
	}

	/// Toggles between `Play()` and `Pause()`. Uses notifications `SwiftyRadioPlayWasPressed` & `SwiftyRadioPlayWasPressed`
	public func togglePlayPause() {
		if isPlaying() {
			pause()
		} else {
			play()
		}
	}

	/// Set the metadata to custom values. Uses notification `SwiftyRadioMetadataUpdated`
	/// - parameter title: Custom metadata title
	/// - parameter artist: Custom metadata artist **(If not provided the Station Name will be used)**
	public func customMetadata(title: String, artist: String = "") {
		track.title = title
		track.artist = artist

		if artist == "" {
			track.artist = stationInfo.name
		}

		updateLockScreen()
		NSNotificationCenter.defaultCenter().postNotificationName("SwiftyRadioMetadataUpdated", object: nil)
	}

	/// Update the lockscreen with the now playing information
	private func updateLockScreen() {
		#if os(iOS)
			if stationInfo.albumArt != "" {
				let albumArtwork = MPMediaItemArtwork(image: stationInfo.albumArt)
				MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
					MPMediaItemPropertyArtist: track.artist,
					MPMediaItemPropertyTitle: track.title,
					MPMediaItemPropertyArtwork: albumArtwork
				]
			} else {
				MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
					MPMediaItemPropertyArtist: track.artist,
					MPMediaItemPropertyTitle: track.title
				]
			}
		#elseif os(tvOS)
			MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [
				MPMediaItemPropertyArtist: track.artist,
				MPMediaItemPropertyTitle: track.title
			]
		#elseif os(OSX)
			let notification = NSUserNotification()
			notification.title = stationInfo.name
			notification.subtitle = track.artist
			notification.informativeText = track.title
			NSUserNotificationCenter.defaultUserNotificationCenter().removeAllDeliveredNotifications()
			NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
		#endif
	}
	
	/// Update the now playing artwork
	/// - parameter imageName: Name of image to display as album art
	public func updateArtwork(imageName: UIImage) {
		stationInfo.albumArt = imageName
		updateLockScreen()
	}
	
	/// Removes special characters from a text string
	/// - parameter text: Text to be cleaned
	/// - returns: Cleaned text
	private func clean(text: String) -> String {
		let safeChars : Set<Character> = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890- []".characters)
		return String(text.characters.filter { safeChars.contains($0) })
	}


//*****************************************************************
// MARK: - Notification Functions
//*****************************************************************
	override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		/// Called when the player item status changes
		if keyPath == "status" {
			if PlayerItem.status == AVPlayerItemStatus.Failed {
				pause()
				customMetadata("\(stationInfo.name) is offline", artist: "Please try again later")
				NSNotificationCenter.defaultCenter().postNotificationName("SwiftyRadioStationOffline", object: nil)
			}
		}
		
		/// Called when new song metadata is available
		if keyPath == "timedMetadata" {
			if(PlayerItem.timedMetadata != nil && PlayerItem.timedMetadata!.count > 0) {
				let metaData = PlayerItem.timedMetadata!.first!.value as! String
				let cleanedMetadata = clean(metaData)

				// Remove junk song code i.e. [4T3]
				var removeSongCode = [String]()
				removeSongCode = cleanedMetadata.componentsSeparatedByString(" [")

				// Separate metadata by " - "
				var metadataParts = [String]()
				metadataParts = removeSongCode[0].componentsSeparatedByString(" - ")

				// Set artist to the station name if it is blank or unknown
				switch metadataParts[0] {
					case "", "Unknown", "unknown":
					track.artist = stationInfo.name
					default:
					track.artist = metadataParts[0]
				}

				if metadataParts.count > 0 {
					// Remove artist and join remaining values for song title
					metadataParts.removeAtIndex(0)
					let combinedTitle = metadataParts.joinWithSeparator(" - ")
					track.title = combinedTitle
				} else {
					// If the song title is missing
					track.title = metadataParts[0]
					track.artist = stationInfo.name
				}

				// If the track title is still blank use the station description
				if track.title == "" {
					track.title = stationInfo.shortDesc
				}

				print("METADATA - artist: \(track.artist) | title: \(track.title)")

				updateLockScreen()
				NSNotificationCenter.defaultCenter().postNotificationName("SwiftyRadioMetadataUpdated", object: nil)
			}
		}
	}
	
	#if os(iOS) || os(tvOS)
		/// Called when when the current audio routing changes
		@objc private func audioRouteChangeListener(notification: NSNotification) {
			dispatch_async(dispatch_get_main_queue(), {
				let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt

				// Pause audio when headphones are removed
				if AVAudioSessionRouteChangeReason.OldDeviceUnavailable.rawValue == audioRouteChangeReason {
					if self.isPlaying() {
						self.pause()
					}

					print("Audio Device was removed")
				}
			})
		}

		/// Called when the current audio is interrupted
		@objc private func audioInterruption(notification: NSNotification) {
			dispatch_async(dispatch_get_main_queue(), {
				let audioInterruptionReason = notification.userInfo![AVAudioSessionInterruptionTypeKey] as! UInt

				// Pause audio when a phone call is received
				if AVAudioSessionInterruptionType.Began.rawValue == audioInterruptionReason {
					if self.isPlaying() {
						self.pause()
					}

					print("Interruption Began")
				}

				if AVAudioSessionInterruptionType.Ended.rawValue == audioInterruptionReason {
					print("Interruption Ended")
				}
			})
		}
	#endif
}
