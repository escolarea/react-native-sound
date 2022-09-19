//
//  RNSound.swift
//  RNSound
//
//  Created by Claudia Cortes on 19/9/22.
//  Copyright © 2022 zmxv. All rights reserved.
//

import Foundation
import AVKit
@objc(RNSound)
final class RNSound: NSObject, ObservableObject{
    private var count=0;
    
    let audioEngine = AVAudioEngine()
    var playerNode = AVAudioPlayerNode()
    var pitchNode = AVAudioUnitTimePitch()
    var speedNode  = AVAudioUnitVarispeed()

    @objc
    func prepare(_ fileName: String?) {
        
        let mainMixer = audioEngine.mainMixerNode
        
        do {
            /**sounds are loaded here**/
            let soundUrl = Bundle.main.url(forResource: fileName, withExtension: "mp3")!
            let fileSound = try AVAudioFile(forReading: soundUrl as URL)
            let soundNode = AVAudioPlayerNode()
            let pitchControl = AVAudioUnitTimePitch()
            let speedControl = AVAudioUnitVarispeed()
            
            playerNode=soundNode
            audioEngine.attach(soundNode)
            speedNode=speedControl
            pitchNode=pitchControl
            audioEngine.attach(speedControl)
            audioEngine.attach(pitchControl)
            
            audioEngine.connect(soundNode,
                                to: mainMixer,
                                format: fileSound.processingFormat)
            
            //connecting the pitch and more
            audioEngine.connect(soundNode, to: speedControl, format: fileSound.processingFormat)
            audioEngine.connect(speedControl, to: pitchControl, format: fileSound.processingFormat)
            audioEngine.connect(pitchControl, to: audioEngine.mainMixerNode, format: fileSound.processingFormat)
            //creatng buffer
            let bufferSound = AVAudioPCMBuffer(pcmFormat: fileSound.processingFormat, frameCapacity: UInt32(fileSound.length))
            
            try fileSound.read(into: bufferSound!)
            
            //Creating loop
            soundNode.scheduleBuffer(bufferSound!, at: nil, options: [.loops]) {}
            
            
            try audioEngine.start()
            
            //initializing in background
            UIApplication.shared.beginReceivingRemoteControlEvents()
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(.playback)
            
            // Allow audio some time to load
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.play()
                
                self.setupRemoteControls()
            }
            
        } catch {
            print(error)
        }
    }
    @objc
    func reset(_ fileName: String?) {
        // saving old value
        let volume = self.playerNode.volume
        audioEngine.stop()
        audioEngine.reset()
       prepare(fileName)
        // reset volumes
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.playerNode.volume=volume
        }
        
    }
    
//    @objc
//    func playPause() {
//        if (playerNode.isPlaying) {
//            pause()
//        } else {
//            play()
//        }
//    }
    @objc
    func play() {
        playerNode.volume = 0
        playerNode.play()
        fade(from: 0, to: 0.5, duration: 0.25, completion: nil)
    }
    @objc
    func pause() {
        fade(from: playerNode.volume, to: 0, duration: 0.25) {
            self.playerNode.pause()
        }
    }
    
    @objc
    func stop() {
        fade(from: playerNode.volume, to: 0, duration: 0.25) {
            self.playerNode.stop()
        }
    }
    
    @objc
    func setVolume(value: Float) {
        playerNode.volume = value
    }
    
    @objc
    func setPan(value: Float) {
        playerNode.pan=value
    }
    
    @objc
    func setPitch(value: Float) {
        pitchNode.pitch=value
        speedNode.rate=value
    }
    
    @objc
    func setSpeed(value: Float) {
        speedNode.rate=value
    }
    
    
    @objc
    func fade(from: Float, to: Float, duration: TimeInterval, completion: (() -> Void)?) {
        let stepTime = 0.01
        let times = duration / stepTime
        let step = (to - from) / Float(times)
        for i in 0...Int(times) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepTime) {
                self.playerNode.volume = from + Float(i) * step
                if i == Int(times) {
                    completion?()
                }
            }
        }
    }
    
    @objc
    func setupRemoteControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.play()
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.pause()
            return .success
        }
    }
}

