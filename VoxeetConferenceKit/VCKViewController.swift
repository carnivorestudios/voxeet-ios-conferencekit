//
//  VCKViewController.swift
//  VoxeetConferenceKit
//
//  Created by Corentin Larroque on 15/02/2017.
//  Copyright © 2017 Voxeet. All rights reserved.
//

import UIKit
import VoxeetSDK
import Kingfisher
import MediaPlayer

class VCKViewController: UIViewController {
    
    /* UI */
    
    @IBOutlet weak var callNameLabel: NameCallLabel!
    @IBOutlet weak private var mainContainer: UIView!
    
    @IBOutlet weak var mainVideoRenderer: VTVideoView!
    @IBOutlet weak var ownVideoRenderer: VTVideoView!
    @IBOutlet weak private var screenShareVideoRenderer: VTVideoView!
    
    @IBOutlet weak private var conferenceTimerContainerView: UIView!
    @IBOutlet weak private var conferenceTimerLabel: UILabel!
    @IBOutlet weak var conferenceStateLabel: UILabel!
    
    @IBOutlet weak private var topView: UIView!
    @IBOutlet weak var minimizeButton: UIButton!
    @IBOutlet weak var usersCollectionView: UICollectionView!
    
    @IBOutlet weak private var mainAvatarContainer: UIView!
    @IBOutlet weak private var mainAvatar: UIImageView!
    @IBOutlet weak private var mainAvatarLabel: UILabel!
    @IBOutlet weak private var voiceIndicatorConstraintLeading: NSLayoutConstraint!
    
    @IBOutlet weak var flipImage: UIImageView!
    
    @IBOutlet weak private var bottomContainerView: UIView!
    @IBOutlet weak private var microphoneButton: CircleButton!
    @IBOutlet weak private var cameraButton: CircleButton!
    @IBOutlet weak private var switchBuiltInSpeakerButton: CircleButton!
    @IBOutlet weak private var screenShareButton: UIButton!
    @IBOutlet weak private var hangUpButton: UIButton!
    
    /* Stored */
    
    var mainUser: VTUser?
    var selectedUser: VTUser?
    var screenShareUserID: String?
    
    // Timers.
    var conferenceStartTimer: Timer?
    var activeSpeakerTimer: Timer?
    private var voiceLevelTimer: Timer?
    private var conferenceTimer: Timer?
    private(set) var conferenceTimerStart: Date!
    private var conferenceTimerQueue = DispatchQueue(label: "com.voxeet.conferencekit.conferenceTimer", qos: .background, attributes: .concurrent)
    private var hangUpTimerCount: Int = 0
    private var hangUpTimer: Timer?
    
    // Sounds.
    var outgoingSound: AVAudioPlayer?
    private var hangUpSound: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VoxeetSDK.shared.conference.delegate = self
        
        // Initialization of all UI components.
        initUI()
        
        // Save when a user starts the conference.
        conferenceTimerStart = Date()
        
        // Active speaker mode.
        resetActiveSpeakerTimer()
        // Voice level.
        voiceLevelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refreshVoiceLevel), userInfo: nil, repeats: true)
        // Start the conference timer.
        conferenceTimerQueue.async { [unowned self] in
            // Start the conference timer.
            self.conferenceTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateConferenceTimer), userInfo: nil, repeats: true)
            let currentRunLoop = RunLoop.current
            currentRunLoop.add(self.conferenceTimer!, forMode: RunLoop.Mode.common)
            currentRunLoop.run()
        }
        
        // Own video renderer tap gesture.
        let tap = UITapGestureRecognizer(target: self, action: #selector(flipCamera(recognizer:)))
        ownVideoRenderer.addGestureRecognizer(tap)
        // Main video renderer swipe gesture.
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(mainContainerPinchGesture(recognizer:)))
        mainVideoRenderer.addGestureRecognizer(pinch)
        
        // Sounds set up.
        if let outgoingSoundURL = Bundle(for: type(of: self)).url(forResource: "CallOutgoing", withExtension: "mp3") {
            outgoingSound = try? AVAudioPlayer(contentsOf: outgoingSoundURL, fileTypeHint: AVFileType.mp3.rawValue)
            outgoingSound?.numberOfLoops = 3
        }
        if let hangUpSoundURL = Bundle(for: type(of: self)).url(forResource: "CallHangUp", withExtension: "mp3") {
            hangUpSound = try? AVAudioPlayer(contentsOf: hangUpSoundURL, fileTypeHint: AVFileType.mp3.rawValue)
        }
        
        // Hide switch speaker button on other device than iPhone.
        if UIDevice.current.userInterfaceIdiom != .phone {
            switchBuiltInSpeakerButton.isHidden = true
        }
        
        // Device orientation observer.
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        // Refresh users list to handle waiting room observer.
        NotificationCenter.default.addObserver(self, selector: #selector(participantAddedNotification), name: .VTParticipantAdded, object: nil)
        // CallKit mute behaviour to update UI observer.
        NotificationCenter.default.addObserver(self, selector: #selector(callKitMuteToggled), name: .VTCallKitMuteToggled, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check microphone permission.
        VCKPermission.microphonePermission(controller: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Stop timers.
        conferenceStartTimer?.invalidate()
        activeSpeakerTimer?.invalidate()
        voiceLevelTimer?.invalidate()
        conferenceTimerQueue.sync { [unowned self] in
            self.conferenceTimer?.invalidate()
            self.conferenceTimer = nil
        }
        
        // Reset: Force the device screen to never going to sleep mode.
        UIApplication.shared.isIdleTimerDisabled = false
        // Reset: Proxymity sensor.
        UIDevice.current.isProximityMonitoringEnabled = false
        
        // Remove observers
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initUI() {
        // Main avatar corner radius.
        mainAvatar.layer.cornerRadius = mainAvatar.frame.width / 2
        
        // Default behavior to choose between internal or external speakers.
        if !VoxeetSDK.shared.conference.defaultBuiltInSpeaker {
            switchBuiltInSpeakerAction()
        }
        
        // Hide by default minimized elements.
        mainAvatarContainer.alpha = 0
        alphaTransitionUI(minimized: false)
        
        cameraButton.backgroundColor = UIColor(red:0.14, green:0.14, blue:0.14, alpha:1)
        microphoneButton.backgroundColor = UIColor(red:0.14, green:0.14, blue:0.14, alpha:1)
        switchBuiltInSpeakerButton.backgroundColor = UIColor.white
        
        // Default behavior to check if video is enabled.
        if VoxeetSDK.shared.conference.defaultVideo {
            cameraButton.tag = 1
            cameraButton.setImage(UIImage(named: "CameraOn", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
            cameraButton.backgroundColor = UIColor.white
        }
        // Selfie camera mirror.
        ownVideoRenderer.mirrorEffect = true
        
        // Hide screen share button for devices below iOS 11.
        if #available(iOS 11.0, *) {} else {
            screenShareButton.isHidden = true
        }
        
        // Disable automatic screen lock.
        UIApplication.shared.isIdleTimerDisabled = true
        NetworkStatus.shared.startListener()
        
        // Disable buttons until the end of join process.
        enableButtons(areEnabled: false)
    }
    
    func enableButtons(areEnabled: Bool) {
        let mode = VoxeetSDK.shared.conference.mode
        
        buttonTransitionAnimation(button: hangUpButton, isEnabled: areEnabled)
        buttonTransitionAnimation(button: microphoneButton, isEnabled: mode != .standard ? false : areEnabled)
        buttonTransitionAnimation(button: cameraButton, isEnabled: mode != .standard ? false : areEnabled)
        buttonTransitionAnimation(button: switchBuiltInSpeakerButton, isEnabled: areEnabled)
        buttonTransitionAnimation(button: screenShareButton, isEnabled: mode != .standard ? false : areEnabled)
        buttonTransitionAnimation(button: minimizeButton, isEnabled: areEnabled)
        
        if mode != .standard {
            UIView.animate(withDuration: 0.125) {
                self.microphoneButton.alpha = 0
                self.cameraButton.alpha = 0
                self.screenShareButton.alpha = 0
            }
            UIView.animate(withDuration: 0.25) {
                self.microphoneButton.isHidden = true
                self.cameraButton.isHidden = true
                self.screenShareButton.isHidden = true
            }
            cameraButton.tag = 0
        }
    }
    
    private func buttonTransitionAnimation(button: UIButton, isEnabled: Bool) {
        UIView.transition(with: button,
                          duration: 0.125,
                          options: .transitionCrossDissolve,
                          animations: { button.isEnabled = isEnabled },
                          completion: nil)
    }
    
    /*
     *  MARK: Maximize / minimize UI
     */
    
    func maximize(animated: Bool = true) {
        resizeTransitionUI(minimized: false, animated: animated)
        
        // Reset container corner radius.
        self.view.layer.cornerRadius = 0
        mainContainer.layer.cornerRadius = self.view.layer.cornerRadius
        
        // Reload collection view layout.
        usersCollectionView.reloadData()
    }
    
    func minimize(animated: Bool = true) {
        resizeTransitionUI(minimized: true, animated: animated)
        
        // Set container corner radius.
        self.view.layer.cornerRadius = 6
        mainContainer.layer.cornerRadius = self.view.layer.cornerRadius
    }
    
    private func resizeTransitionUI(minimized: Bool, animated: Bool) {
        let animationDuration = 0.125
        
        // Update all UI components (with an animation or not).
        if animated {
            UIView.animate(withDuration: animationDuration) {
                self.alphaTransitionUI(minimized: minimized)
            }
        } else {
            alphaTransitionUI(minimized: minimized)
        }
        
        // Update main avatar corner radius.
        DispatchQueue.main.async {
            if animated {
                let mainAvatarAnimation = CABasicAnimation(keyPath: "cornerRadius")
                mainAvatarAnimation.duration = animationDuration
                mainAvatarAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                mainAvatarAnimation.fromValue = self.mainAvatar.layer.cornerRadius
                mainAvatarAnimation.toValue = self.mainAvatar.frame.width / 2
                self.mainAvatar.layer.add(mainAvatarAnimation, forKey: "cornerRadius")
            }
            self.mainAvatar.layer.cornerRadius = self.mainAvatar.frame.width / 2
        }
    }
    
    private func alphaTransitionUI(minimized: Bool) {
        topView.alpha = minimized ? 0 : 1
        bottomContainerView.alpha = minimized ? 0 : 1
        conferenceTimerContainerView.alpha = 1
        mainAvatarLabel.alpha = minimized ? 0 : 1
        
        if cameraButton.tag != 0 {
            ownVideoRenderer.alpha = minimized ? 0 : 1
            flipImage.alpha = minimized ? 0 : 1
        } else {
            ownVideoRenderer.alpha = 0
            flipImage.alpha = 0
        }
    }
    
    /*
     *  MARK: Actions
     */
    
    @IBAction func minimizeAction(_ sender: Any) {
        VoxeetConferenceKit.shared.minimize()
    }
    
    @IBAction func microphoneAction(_ sender: Any) {
        if let userID = VoxeetSDK.shared.session.user?.id {
            let isMuted = VoxeetSDK.shared.conference.toggleMute(userID: userID)
            microphoneButton.setImage(UIImage(named: isMuted ? "MicrophoneOff" : "MicrophoneOn", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
            if (isMuted) {
                microphoneButton.backgroundColor = UIColor.white
            } else {
                microphoneButton.backgroundColor = UIColor(red:0.14, green:0.14, blue:0.14, alpha:1)
            }
        }
    }
    
    @IBAction func cameraAction(_ sender: Any? = nil) {
        VCKPermission.cameraPermission(controller: self) { granted in
            guard let userID = VoxeetSDK.shared.session.user?.id, granted else { return }
            
            if self.cameraButton.tag == 0 {
                self.cameraButton.tag = 1
                self.cameraButton.setImage(UIImage(named: "CameraOn", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                self.cameraButton.backgroundColor = UIColor.white
                
                VoxeetSDK.shared.conference.startVideo(userID: userID)
                
                // Also switch to the built in speaker when the video starts.
                if self.switchBuiltInSpeakerButton.tag != 0 {
                    self.switchBuiltInSpeakerAction()
                }
            } else {
                self.cameraButton.tag = 0
                self.cameraButton.setImage(UIImage(named: "CameraOff", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                self.cameraButton.backgroundColor = UIColor(red:0.14, green:0.14, blue:0.14, alpha:1)
                VoxeetSDK.shared.conference.stopVideo(userID: userID)
            }
        }
    }
    
    @IBAction func switchBuiltInSpeakerAction(_ sender: Any? = nil) {
        if switchBuiltInSpeakerButton.tag == 0 {
            switchBuiltInSpeakerButton.tag = 1
            switchBuiltInSpeakerButton.setImage(UIImage(named: "BuiltInSpeakerOff", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
            switchBuiltInSpeakerButton.backgroundColor = UIColor(red:0.14, green:0.14, blue:0.14, alpha:1)
        } else {
            switchBuiltInSpeakerButton.tag = 0
            switchBuiltInSpeakerButton.setImage(UIImage(named: "BuiltInSpeakerOn", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
            switchBuiltInSpeakerButton.backgroundColor = UIColor.white
        }
        
        // Switch device speaker and set the proximity sensor in line with the current speaker.
        UIDevice.current.isProximityMonitoringEnabled = switchBuiltInSpeakerButton.tag != 0
        VoxeetSDK.shared.conference.switchDeviceSpeaker(forceBuiltInSpeaker: switchBuiltInSpeakerButton.tag == 0)
    }
    
    @IBAction func screenShareAction(_ sender: Any) {
        guard screenShareUserID == nil || screenShareUserID == VoxeetSDK.shared.session.user?.id else {
            return
        }
        
        if #available(iOS 11.0, *) {
            if screenShareButton.tag == 0 {
                screenShareButton.tag = 1
                screenShareButton.setImage(UIImage(named: "ScreenShareOn", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                
                VoxeetSDK.shared.conference.startScreenShare { (error) in
                    if let _ = error {
                        self.screenShareButton.setImage(UIImage(named: "ScreenShareOff", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                        return
                    }
                }
            } else {
                screenShareButton.tag = 0
                screenShareButton.setImage(UIImage(named: "ScreenShareOff", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                
                VoxeetSDK.shared.conference.stopScreenShare { (error) in
                    if let _ = error {
                        return
                    }
                }
            }
        }
    }
    
    @IBAction func hangUpAction(_ sender: Any? = nil) {
        // Block hang up action if the hangUpTimer if currently active.
        guard hangUpTimer == nil else {
            return
        }
        
        // Hang up sound.
        hangUpSound?.play()
        
        // Disable buttons when leaving.
        enableButtons(areEnabled: false)
        
        // Remove audio observer to desactivate switchBuiltInSpeakerButton behaviour.
        conferenceStartTimer?.invalidate()
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        
        // Hide conference state before stopping the conference.
        conferenceStateLabel.isHidden = true
        conferenceStateLabel.text = nil
        
        // Hide own video renderer.
        if cameraButton.tag != 0 {
            ownVideoRenderer.alpha = 0
            flipImage.alpha = ownVideoRenderer.alpha
        }
        
        // If the conference is not connected yet, retry the hang up action after few milliseconds to stop the conference.
        guard VoxeetSDK.shared.conference.state == .connected else {
            hangUpTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(hangUpRetry), userInfo: nil, repeats: true)
            return
        }
        VoxeetSDK.shared.conference.leave()
    }
    
    /*
     *  MARK: Gesture recognizers
     */
    
    @objc private func flipCamera(recognizer: UITapGestureRecognizer) {
        let mirrorEffectTransformation = self.ownVideoRenderer.layer.transform.m11 * -1
        flipImage.isHidden = true
        ownVideoRenderer.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
            self.ownVideoRenderer.transform = CGAffineTransform(scaleX: 1.2 * mirrorEffectTransformation, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.10, delay: 0, options: .curveEaseOut, animations: {
                self.ownVideoRenderer.transform = CGAffineTransform(scaleX: 1 * mirrorEffectTransformation, y: 1)
            }) { _ in
                self.flipImage.isHidden = false
                self.ownVideoRenderer.isUserInteractionEnabled = true
            }
        }
        
        ownVideoRenderer.subviews.first?.alpha = 0
        VoxeetSDK.shared.conference.flipCamera {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.10, animations: {
                    self.ownVideoRenderer.subviews.first?.alpha = 1
                })
            }
        }
    }
    
    @objc private func mainContainerPinchGesture(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .ended {
            // Main video view content fill / fit.
            mainVideoRenderer.contentFill = recognizer.scale > 1 ? true : false
            mainVideoRenderer.setNeedsLayout()
        }
    }
    
    /*
     *  MARK: Timers
     */
    
    @objc func conferenceStart() {
        // Register to audio route changing.
        if UIDevice.current.userInterfaceIdiom == .phone {
            NotificationCenter.default.addObserver(self, selector: #selector(audioSessionRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
        }
        
        // Set minimum audio.
        if AVAudioSession.sharedInstance().outputVolume < 0.1 {
            MPVolumeView.setVolume(0.1)
        }
        
        // Play outgoing sound only if the caller didn't join the conference yet.
        if VoxeetSDK.shared.conference.users.filter({ $0.asStream }).isEmpty {
            // Play outgoing sound.
            outgoingSound?.play()
        }
    }
    
    @objc private func activeSpeaker() {
        var loudestUser: VTUser?
        var loudestVoiceLevel: Double = 0
        
        // Getting the loudest speaker.
        for user in VoxeetSDK.shared.conference.users.filter({ $0.asStream }) {
            if let userID = user.id {
                let currentVoiceLevel = VoxeetSDK.shared.conference.voiceLevel(userID: userID)
                
                if (mainUser == nil || currentVoiceLevel >= 0.01) && currentVoiceLevel >= loudestVoiceLevel {
                    loudestUser = user
                    loudestVoiceLevel = currentVoiceLevel
                }
            }
        }
        
        if let user = loudestUser {
            updateMainUser(user: user)
        }
    }
    
    @objc private func refreshVoiceLevel() {
        // Optimization: refresh the voice level only if the application is active and the proximity sensor in not active.
        if case UIApplication.shared.applicationState = UIApplication.State.active {} else {
            return
        }
        guard let userID = mainUser?.id, !UIDevice.current.proximityState else {
            return
        }
        
        let voiceLevel = VoxeetSDK.shared.conference.voiceLevel(userID: userID)
        
        if voiceLevel >= 0.01 { // Avoid useless animations.
            // y = ax + b.
            let a: CGFloat = (mainAvatar.frame.origin.x - 0) / (0 - 1)
            let b: CGFloat = mainAvatar.frame.origin.x - a * 0
            let x: CGFloat = CGFloat(voiceLevel)
            let y: CGFloat = a * x + b
            
            // Animate voice indicator.
            voiceIndicatorConstraintLeading.constant = y
            UIView.animate(withDuration: 0.1) {
                self.mainAvatarContainer.layoutIfNeeded()
            }
        } else {
            voiceIndicatorConstraintLeading.constant = mainAvatar.frame.origin.x
        }
    }
    
    @objc private func updateConferenceTimer() {
        let date = Date().timeIntervalSince(conferenceTimerStart)
        let hour = date / 3600
        let minute = (date / 60).truncatingRemainder(dividingBy: 60)
        let second = date.truncatingRemainder(dividingBy: 60)
        DispatchQueue.main.async {
            if (floor(date) > 60 && (self.conferenceStateLabel.text == NSLocalizedString("CONFERENCE_STATE_CALLING", bundle: Bundle(for: type(of: self)), comment: "")) && !((self.conferenceStateLabel.isHidden))) {
                let alertController = UIAlertController(title: "Error: Call Inactivity", message: "Call terminated from insufficient users", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                self.hangUpAction()
            }
        }
        DispatchQueue.main.async {
            if hour >= 1 {
                self.conferenceTimerLabel.text = String(format: "%02.0f:%02.0f:%02.0f", floor(hour), floor(minute), floor(second))
            } else {
                self.conferenceTimerLabel.text = String(format: "%02.0f:%02.0f", floor(minute), floor(second))
            }
        }
        if (!(NetworkStatus.shared.isReachable) && floor(date) > 7) {
            self.conferenceTimer?.invalidate()
            let alertController = UIAlertController(title: "Error: Connection Lost", message: "Unable to connect to internet", preferredStyle: UIAlertController.Style.alert)
            self.present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                alertController.dismiss(animated: true, completion: nil)
            }
            self.hangUpAction()
        }
    }
    
    @objc private func hangUpRetry() {
        guard hangUpTimerCount < 50 else {
            hangUpTimer?.invalidate()
            hangUpTimer = nil
            hangUpTimerCount = 0
            
            // Force leave.
            VoxeetSDK.shared.conference.leave { _ in
                VoxeetConferenceKit.shared.hide()
            }
            
            return
        }
        
        if VoxeetSDK.shared.conference.state == .connected {
            hangUpTimer?.invalidate()
            hangUpTimer = nil
            hangUpTimerCount = 0
            
            hangUpAction()
        } else {
            hangUpTimerCount += 1
        }
    }
    
    /*
     *  MARK: Timers helpers
     */
    
    func resetActiveSpeakerTimer() {
        activeSpeakerTimer?.invalidate()
        activeSpeakerTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(activeSpeaker), userInfo: nil, repeats: true)
        activeSpeakerTimer?.fire()
    }
    
    func updateMainUser(user: VTUser?) {
        let previousMainUser = mainUser
        
        mainUser = user
        let avatarURL = user?.avatarURL ?? ""
        if avatarURL.count == 2 {
            mainAvatar.image = InitialsImageFactory.imageWith(initials: user?.avatarURL, user: user)
        } else {
            let imageURLStr = avatarURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let imageURL = URL(string: imageURLStr) {
                mainAvatar.kf.setImage(with: imageURL)
            }
        }
        mainAvatarLabel.text = user?.name
        
        let userID = user?.id
        let stream = VoxeetSDK.shared.conference.mediaStream(userID: userID ?? "")
        let screenStream = VoxeetSDK.shared.conference.screenShareMediaStream()
        
        // Unattach old main stream.
        if let previousStream = VoxeetSDK.shared.conference.mediaStream(userID: previousMainUser?.id ?? ""), !previousStream.videoTracks.isEmpty && (previousMainUser?.id != userID || userID == screenShareUserID) {
            VoxeetSDK.shared.conference.unattachMediaStream(previousStream, renderer: mainVideoRenderer)
        }
        
        if !(stream?.videoTracks.isEmpty ?? true) || (!(screenStream?.videoTracks.isEmpty ?? true) && userID == screenShareUserID) {
            // Attach new stream.
            if let screenStream = screenStream, userID == screenShareUserID {
                mainVideoRenderer.isHidden = true
                screenShareVideoRenderer.isHidden = false
                VoxeetSDK.shared.conference.attachMediaStream(screenStream, renderer: screenShareVideoRenderer)
            } else if let stream = stream {
                mainVideoRenderer.isHidden = false
                screenShareVideoRenderer.isHidden = true
                VoxeetSDK.shared.conference.attachMediaStream(stream, renderer: mainVideoRenderer)
            }
            
            // Update conferenceTimer view's background color.
            conferenceTimerContainerView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            
            // Hide main avatar and stop voice level timer.
            voiceLevelTimer?.invalidate()
            mainAvatarContainer.alpha = 0
        } else {
            // Hide main video renderer & update the conferenceTimer view's background color.
            mainVideoRenderer.isHidden = true
            screenShareVideoRenderer.isHidden = true
            conferenceTimerContainerView.backgroundColor = UIColor.clear
            
            // Relaunch voice level timer.
            if user != nil && mainAvatarContainer.alpha == 0 {
                voiceLevelTimer?.invalidate()
                voiceLevelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refreshVoiceLevel), userInfo: nil, repeats: true)
                voiceLevelTimer?.fire()
            }
            
            // Hide / unhide main avatar.
            if mainAvatarContainer.alpha != (user != nil ? 1 : 0) {
                UIView.animate(withDuration: 0.10, animations: {
                    self.mainAvatarContainer.alpha = user != nil ? 1 : 0
                })
            }
        }
    }
    
    /*
     *  MARK: Observer
     */
    
    @objc private func audioSessionRouteChange(notification: Notification) {
        // SwitchBuiltInSpeakerButton state.
        DispatchQueue.main.async {
            let output = AVAudioSession.sharedInstance().currentRoute.outputs.first
            if output?.portType == .builtInReceiver || output?.portType == .builtInSpeaker {
                self.switchBuiltInSpeakerButton.isEnabled = true
                
                if output?.portType == .builtInSpeaker {
                    self.switchBuiltInSpeakerButton.tag = 0
                    self.switchBuiltInSpeakerButton.setImage(UIImage(named: "BuiltInSpeakerOn", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                } else {
                    self.switchBuiltInSpeakerButton.tag = 1
                    self.switchBuiltInSpeakerButton.setImage(UIImage(named: "BuiltInSpeakerOff", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                }
            } else {
                self.switchBuiltInSpeakerButton.isEnabled = false
                self.switchBuiltInSpeakerButton.setImage(UIImage(named: "BuiltInSpeakerOff", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
            }
        }
    }
    
    @objc private func deviceOrientationDidChange(notification: Notification) {
        // Re-center cells.
        usersCollectionView.reloadData()
    }
    
    @objc private func participantAddedNotification(_ notification: Notification) {
        // Refresh invited users.
        usersCollectionView.reloadData()
        DispatchQueue.main.async {
            self.usersCollectionView.flashScrollIndicators()
        }
    }
    
    @objc private func callKitMuteToggled(notification: NSNotification) {
        guard let isMuted = notification.userInfo?["mute"] as? Bool else { return }
        microphoneButton.setImage(UIImage(named: isMuted ? "MicrophoneOff" : "MicrophoneOn", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
    }
}
