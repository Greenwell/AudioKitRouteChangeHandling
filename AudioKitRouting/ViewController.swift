//
//  ViewController.swift
//  AudioKitRouting
//
//  Created by Yaron Karasik on 6/24/17.
//  Copyright © 2017 karasik. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    var audioEngine = AudioEngine()

    lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.green
        button.layer.cornerRadius = 50.0
        button.layer.borderWidth = 10.0
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(playButtonWasTapped), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var headphonesLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 20.0)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioEngine.delegate = self
        view.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        setupPlayPauseButton()
        setupHeadphonesLabel()
        
        updateHeadphonesLabel(connected: audioEngine.areHeadphonesConnected)
    }
    
    func setupPlayPauseButton() {
        playPauseButton.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        playPauseButton.center = view.center
        view.addSubview(playPauseButton)
    }
    
    func setupHeadphonesLabel () {
        headphonesLabel.frame = CGRect(x: 0.0, y: view.bounds.size.height - 50.0, width: view.bounds.size.width, height: 20.0)
        view.addSubview(headphonesLabel)
    }
    
    func updateHeadphonesLabel(connected: Bool) {
        headphonesLabel.text = connected ? "HEADPHONES CONNECTED" : "HEADPHONES DISCONNECTED"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func playButtonWasTapped() {
        audioEngine.togglePlaying()        
    }
}

extension ViewController: AudioEngineDelegate {
    func playbackStateDidChange(playing: Bool) {
        playPauseButton.backgroundColor = playing ? UIColor.red : UIColor.green
    }
    
    func headphonesStateDidChange(connected: Bool) {
        updateHeadphonesLabel(connected: connected)
    }
}

