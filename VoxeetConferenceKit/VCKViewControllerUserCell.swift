//
//  VCKViewControllerUserCell.swift
//  VoxeetConferenceKit
//
//  Created by Corentin Larroque on 16/02/2017.
//  Copyright © 2017 Voxeet. All rights reserved.
//

import UIKit
import VoxeetSDK

class VCKViewControllerUserCell: UICollectionViewCell {
    @IBOutlet weak var videoRenderer: VTVideoView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var participant: VTParticipant?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        videoRenderer.isHidden = true
        // Unattach the old stream before reusing the cell.
        if let participant = participant, let stream = participant.streams.first(where: { $0.type == .Camera }), !stream.videoTracks.isEmpty {
           VoxeetSDK.shared.mediaDevice.attachMediaStream(stream, renderer: videoRenderer)
        }
    }
}
