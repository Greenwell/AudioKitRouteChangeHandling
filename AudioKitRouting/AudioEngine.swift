//
//  AudioEngine.swift
//  AudioKitRouting
//
//  Created by Yaron Karasik on 6/25/17.
//  Copyright © 2017 karasik. All rights reserved.
//

import Foundation
import AudioKit

protocol AudioEngineDelegate {
    func playbackStateDidChange(playing: Bool)
    func headphonesStateDidChange(connected: Bool)
}

class AudioEngine {
    var delegate: AudioEngineDelegate?
    
    var mixer: AKMixer?
    var player: AKAudioPlayer?
    
    var isPlaying = false
    var shouldBePlaying = false
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioRouteChangeListener(notification:)),
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil)
        
        setupAudioKit()
    }
    
    public func setupAudioKit() {
        AudioKit.stop()
        
        AKSettings.defaultToSpeaker = true
        AKSettings.enableRouteChangeHandling = true
        AKSettings.playbackWhileMuted = true
        
        do {
            try AKSettings.setSession(category: .playAndRecord, with: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
        } catch {
            print("Errored setting category.")
        }
        
        do {
            guard let filePath = Bundle.main.path(forResource: "guitar", ofType: "wav") else { return }
            guard let fileUrl = URL(string: filePath) else { return }
            let audioFile = try AKAudioFile(forReading: fileUrl)
            player = try AKAudioPlayer(file: audioFile)
        } catch let error {
            fatalError("AudioKit: Could not load audio file. error: \(error).")
        }
        
        mixer = AKMixer()
        if let player = player, let mixer = mixer {
            mixer.connect(player)
            AudioKit.output = mixer
        }
        
        AudioKit.start()
        
        if shouldBePlaying {
            play()
        }
    }
    
    public func togglePlaying() {
        isPlaying ? stop() : play()
        shouldBePlaying = isPlaying
    }
    
    private func stop() {
        guard let player = player else { return }
        guard isPlaying else { return }
        isPlaying = false
        player.stop()
        if let delegate = delegate {
            delegate.playbackStateDidChange(playing: false)
        }
    }
    
    private func play() {
        guard let player = player else { return }
        guard !isPlaying else { return }
        
        player.completionHandler = {
            self.isPlaying = false
            if player.currentTime == player.endTime {
                self.shouldBePlaying = false
            }
            if let delegate = self.delegate {
                DispatchQueue.main.async {
                    delegate.playbackStateDidChange(playing: false)
                }                
            }
        }
        self.isPlaying = true
        if let delegate = delegate {
            delegate.playbackStateDidChange(playing: true)
        }
        player.play()
    }

    @objc private func audioRouteChangeListener(notification: Notification) {
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        
        let headphonesConnected = areHeadphonesConnected
        switch (audioRouteChangeReason, headphonesConnected) {
        case (AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue, true):
            setupAudioKit()
            if let delegate = delegate {
                delegate.headphonesStateDidChange(connected: headphonesConnected)
            }
        case (AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue, false):
            setupAudioKit()
            if let delegate = delegate {
                delegate.headphonesStateDidChange(connected: headphonesConnected)
            }
        default:
            break
        }
    }
    
    var areHeadphonesConnected: Bool {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for description in currentRoute.outputs {
            if description.portType == AVAudioSessionPortHeadphones {
                return true
            }
        }
        return false
    }

}

