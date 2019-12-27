//
//  VCKViewController+VTConferenceDelegate.swift
//  VoxeetConferenceKit
//
//  Created by Corentin Larroque on 16/02/2017.
//  Copyright © 2017 Voxeet. All rights reserved.
//

import Foundation
import VoxeetSDK

extension VCKViewController: VTConferenceDelegate {
    func streamAdded(participant: VTParticipant, stream: MediaStream) {
        
    }
    
    func streamUpdated(participant: VTParticipant, stream: MediaStream) {
        
    }
    
    func streamRemoved(participant: VTParticipant, stream: MediaStream) {
        
    }
    
    func statusUpdated(status: VTConferenceStatus) {
        
    }
    
    func participantJoined(userID: String, stream: MediaStream) {
        if userID == VoxeetSDK.shared.session.participant?.id {
            // Monkey patch: Wait WebRTC media to be started.
            conferenceStartTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(conferenceStart), userInfo: nil, repeats: false)
        } else {
            // Update user's audio position to listen each users clearly in a 3D environment.
            updateUserPosition()
            
            // Reload collection view to update active / inactive users.
            usersCollectionView.reloadData()
            
            // Hide conference state when a user joins the conference.
            conferenceStateLabel.isHidden = true
            conferenceStateLabel.text = nil
            
            // Stop outgoing sound when a user enters in conference.
            outgoingSound?.stop()
        }
        
        // Update streams and UI.
        participantUpdated(userID: userID, stream: stream)
    }
    
    func participantUpdated(userID: String, stream: MediaStream) {
        if userID == VoxeetSDK.shared.session.participant?.id {
            // Attach own stream to the own video renderer.
            if !stream.videoTracks.isEmpty {
                VoxeetSDK.shared.mediaDevice.attachMediaStream(stream, renderer: ownVideoRenderer)
                
                // Selfie camera mirror.
                ownVideoRenderer.mirrorEffect = true
            }
            
            // Hide / unhide own renderer.
            UIView.animate(withDuration: 0.125, animations: {
                self.ownVideoRenderer.alpha = stream.videoTracks.isEmpty ? 0 : 1
                self.flipImage.alpha = self.ownVideoRenderer.alpha
            })
        } else {
            // Reload users' collection view.
            if let current = VoxeetSDK.shared.conference.current,let index = current.participants.firstIndex(where: { $0.id == userID }) {
                usersCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
            
            // Update current main user to update video stream.
            if userID == mainUser?.id {
                updateMainUser(user: mainUser)
            }
        }
    }
    
    func participantLeft(userID: String) {
        if userID != VoxeetSDK.shared.session.participant?.id {
            // If the main user was the loudest speaker resets it.
            if userID == mainUser?.id {
                // Also reset the selected user.
                if userID == selectedUser?.id {
                    selectedUser = nil
                    // Relaunch active speaker mode.
                    resetActiveSpeakerTimer()
                }
                updateMainUser(user: nil)
            }
            
            // Reset screen share user.
            if screenShareUserID == userID {
                screenShareUserID = nil
            }
            
            // Reload collection view to update active / inactive users.
            usersCollectionView.reloadData()
            
            // Update user's audio position to listen each users clearly in a 3D environment.
            updateUserPosition()
            
            if getActiveParticipants().count == 0  {
//                let alertController = UIAlertController(title: "Update: Call Ended", message: "Call terminated from insufficient users", preferredStyle: UIAlertController.Style.alert)
//                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
//                self.present(alertController, animated: true, completion: nil)
                self.hangUpAction()
            }
        }
    }
    
    func messageReceived(userID: String, message: String) {}
    
    func screenShareStarted(userID: String, stream: MediaStream) {
        if userID == VoxeetSDK.shared.session.participant?.id { return }
        
        // Re-update the current main user to enable / disable a video stream.
        updateMainUser(user: mainUser)
        
        if !stream.videoTracks.isEmpty {
            // Stop active speaker and lock current user.
            screenShareUserID = userID
            
            // Attach screen share stream.
            speakerVideoContentFill = self.screenShareVideoRenderer.contentFill
            self.screenShareVideoRenderer.unattach()
            if let screenShareStartedParticipant = VoxeetSDK.shared.conference.current?.participants.filter({ (participant) -> Bool in
                if participant.id == userID{
                    return true
                }else{
                    return false
                }
                }).first{
                self.screenShareVideoRenderer.attach(participant: screenShareStartedParticipant, stream: stream)
            }
            self.screenShareVideoRenderer.contentFill(false, animated: false)
            self.screenShareVideoRenderer.setNeedsLayout()
        }
        
    }
    
    func screenShareStopped(userID: String) {
        if userID == VoxeetSDK.shared.session.participant?.id { return }
        
        // Re-update the current main user to enable / disable a video stream.
        updateMainUser(user: mainUser)
        
        // Unattach screen share stream.
        self.screenShareVideoRenderer.unattach()
        self.screenShareVideoRenderer.contentFill(speakerVideoContentFill, animated: false)
        
        // Reset active speaker and unlock previous user.
        screenShareUserID = nil
    }
    
    private func updateUserPosition() {
        let users = getActiveParticipants()
        let sliceAngle = Double.pi / Double(users.count)
        
        for (index, user) in users.enumerated() {
            let angle = ((Double.pi / 2) - (Double.pi - (sliceAngle * Double(index) + sliceAngle / 2))) / (Double.pi / 2)
            if user.id != nil {
                VoxeetSDK.shared.conference.position(participant: user, angle: angle)
            }
        }
    }
}
