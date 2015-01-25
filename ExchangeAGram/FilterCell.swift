//
//  FilterCell.swift
//  ExchangeAGram
//
//  Created by Patrick Dawson on 25.01.15.
//  Copyright (c) 2015 Patrick Dawson. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {

    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        self.contentView.addSubview(imageView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
