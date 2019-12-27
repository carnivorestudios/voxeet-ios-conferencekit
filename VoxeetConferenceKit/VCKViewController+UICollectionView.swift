//
//  VCKViewController+UICollectionView.swift
//  VoxeetConferenceKit
//
//  Created by Corentin Larroque on 16/02/2017.
//  Copyright © 2017 Voxeet. All rights reserved.
//

import Foundation
import VoxeetSDK

extension VCKViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let currentConference = VoxeetSDK.shared.conference.current{
            if currentConference.participants.count == 1, let firstParticipant = currentConference.participants.first, !firstParticipant.streams.isEmpty{
                collectionView.alpha = 0
            }else{
                collectionView.alpha = 1
            }
            return currentConference.participants.count
        }else{
            // If there is no users in the conference
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! VCKViewControllerUserCell
        guard let currentConference = VoxeetSDK.shared.conference.current else{
            return cell
        }
        // Get participants.
        let participants = currentConference.participants
        guard participants.count != 0 && indexPath.row <= participants.count else { return cell }
        if participants.count == 1, let firstParticipant = participants.first, !firstParticipant.streams.isEmpty { return cell }
        let participant = participants[indexPath.row]
        
        // Clear the image while reload
        cell.avatar.image = nil
        
        // Cell data.
        let avatarURL = participant.info.avatarURL ?? ""
        if avatarURL.count == 2 {
            cell.avatar.image = InitialsImageFactory.imageWith(initials: participant.info.avatarURL, user: participant)
        } else {
            let imageURLStr = avatarURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let imageURL = URL(string: imageURLStr) {
                cell.avatar.kf.setImage(with: imageURL)
            }else if participant.info.name == nil {
                participant.info.name = ""
                cell.avatar.image = InitialsImageFactory.imageWith(initials: participant.info.avatarURL, user: participant)
            }else{
                cell.avatar.image = InitialsImageFactory.imageWith(initials: participant.info.avatarURL, user: participant)
            }
        }
        cell.name.text = participant.info.name
        
        // Cell alpha.
        cell.avatar.alpha = 0.4
        cell.name.alpha = cell.avatar.alpha
        
        // Cell border property.
        cell.avatar.layer.borderColor = UIColor(red: 41/255, green: 162/255, blue: 251/255, alpha: 1).cgColor
        cell.videoRenderer.layer.borderColor = cell.avatar.layer.borderColor
        if let userID = participant.id, userID == selectedUser?.id {
            cell.avatar.layer.borderWidth = 2
        } else {
            cell.avatar.layer.borderWidth = 0
        }
        cell.videoRenderer.layer.borderWidth = cell.avatar.layer.borderWidth
        
        // User is currently in conference.
        if !participant.streams.isEmpty {
            // Update cell alpha.
            cell.avatar.alpha = 1
            cell.name.alpha = cell.avatar.alpha
            
            // Update cell's user.
            cell.participant = participant
            
            // Attach a video stream.
            if let stream = participant.streams.first(where: { $0.type == .Camera }), !stream.videoTracks.isEmpty {
                cell.videoRenderer.isHidden = false
                VoxeetSDK.shared.mediaDevice.attachMediaStream(stream, renderer: cell.videoRenderer)
            }
        }
        
        return cell
    }
}

extension VCKViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentConference = VoxeetSDK.shared.conference.current else{
            return
        }
        let user = currentConference.participants[indexPath.row]
        
        // Select / unselect a user.
        if let userID = user.id, user.status == .connected, userID != selectedUser?.id {
            var indexPaths = [indexPath]
            // Reload old selected user's cell.
            if let selectedUserID = selectedUser?.id, let selectedUserIndex = currentConference.participants.firstIndex(where: { $0.id == selectedUserID }) {
                let selectedUserIndexPath = IndexPath(item: selectedUserIndex, section: 0)
                indexPaths.append(selectedUserIndexPath)
            }
            
            // Reload collection view.
            selectedUser = user
            collectionView.reloadItems(at: indexPaths)
            
            // Set the new main avatar.
            updateMainUser(user: user)
            
            // Stop active speaker mode.
            activeSpeakerTimer?.invalidate()
        } else if selectedUser != nil {
            selectedUser = nil
            collectionView.reloadData()
            
            // Relaunch active speaker mode.
            resetActiveSpeakerTimer()
        }
    }
}

extension VCKViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let numberOfItems = CGFloat(collectionView.numberOfItems(inSection: section))
        let combinedItemWidth = (numberOfItems * flowLayout.itemSize.width) + ((numberOfItems - 1) * flowLayout.minimumLineSpacing)
        let padding = (collectionView.frame.width - combinedItemWidth) / 2
        
        if padding >= minimizeButton.frame.width {
            return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 0, left: minimizeButton.frame.width, bottom: 0, right: 0)
        }
    }
}
