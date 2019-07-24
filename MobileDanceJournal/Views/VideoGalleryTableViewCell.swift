//
//  VideoGalleryTableViewCell.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 5/9/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import UIKit

class VideoGalleryTableViewCell: UITableViewCell {

    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    
    var video: PracticeVideo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
