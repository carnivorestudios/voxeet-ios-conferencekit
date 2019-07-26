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
    func participantJoined(userID: String, stream: MediaStream) {
        if userID == VoxeetSDK.shared.session.user?.id {
            // Monkey patch: Wait WebRTC media to be started.
            conferenceStartTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(conferenceStart), userInfo: nil, repeats: false)
            /*if (VoxeetSDK.shared.conference.alias?.firstIndex(of: ":") == nil) {
                self.callNameLabel.text = "Unnamed"
            } else {
                let endIndex = VoxeetSDK.shared.conference.alias!.firstIndex(of: ":")
                self.callNameLabel.text = String(VoxeetSDK.shared.conference.alias![..<endIndex!])
            }*/
        } else {
            // Update user's audio position to listen each users clearly in a 3D environment.
            updateUserPosition()
            
            // Reload collection view to update active / inactive users.
            usersCollectionView.reloadData()
            
            // Hide conference state when a user joins the conference.
            conferenceStateLabel.isHidden = true
            conferenceStateLabel.text = nil
            
            callNameLabel.text = VoxeetSDK.shared.conference.alias
            
            // Stop outgoing sound when a user enters in conference.
            outgoingSound?.stop()
        }
        
        // Update streams and UI.
        participantUpdated(userID: userID, stream: stream)
    }
    
    func participantUpdated(userID: String, stream: MediaStream) {
        if userID == VoxeetSDK.shared.session.user?.id {
            // Attach own stream to the own video renderer.
            if !stream.videoTracks.isEmpty {
                VoxeetSDK.shared.conference.attachMediaStream(stream, renderer: ownVideoRenderer)
                
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
            let users = VoxeetSDK.shared.conference.users
            if let index = users.firstIndex(where: { $0.id == userID }) {
                usersCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
            
            // Update current main user to update video stream.
            if userID == mainUser?.id {
                updateMainUser(user: mainUser)
            }
        }
    }
    
    func participantLeft(userID: String) {
        if userID != VoxeetSDK.shared.session.user?.id {
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
            
            if (VoxeetSDK.shared.conference.users.filter({ $0.asStream }).count == 0)  {
                let alertController = UIAlertController(title: "Update: Call Ended", message: "Call terminated from insufficient users", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                self.hangUpAction()
            }
        }
    }
    
    func messageReceived(userID: String, message: String) {}
    
    func screenShareStarted(userID: String, stream: MediaStream) {
        screenShareUserID = userID
        
        // Re-update the current main user to enable / disable a video stream.
        updateMainUser(user: mainUser)
    }
    
    func screenShareStopped(userID: String) {
        screenShareUserID = nil
        
        // Re-update the current main user to enable / disable a video stream.
        updateMainUser(user: mainUser)
    }
    
    private func updateUserPosition() {
        let users = VoxeetSDK.shared.conference.users.filter({ $0.asStream })
        let sliceAngle = Double.pi / Double(users.count)
        
        for (index, user) in users.enumerated() {
            let angle = ((Double.pi / 2) - (Double.pi - (sliceAngle * Double(index) + sliceAngle / 2))) / (Double.pi / 2)
            if let userID = user.id {
                VoxeetSDK.shared.conference.userPosition(userID: userID, angle: angle, distance: 0.2)
            }
        }
    }
}
