//
//  sendFormView.swift
//  PickSkip
//
//  Created by Eric Duong on 7/11/17.
//
//

import Foundation
import UIKit

class SendFormView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    var timeLabel: UILabel = {
        let tL = UILabel()
        let traits = [UIFontWeightTrait: UIFontWeightLight]
        var fontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptorFamilyAttribute: "SF Pro Text"])
        fontDescriptor = fontDescriptor.addingAttributes([UIFontDescriptorTraitsAttribute:traits])
        tL.font = UIFont(descriptor: fontDescriptor, size: 22)
        return tL
    }()
    
    func setupView() {
        backgroundColor = UIColor(colorLiteralRed: 0.0, green: 117.0/255.0, blue: 231.0/255.0, alpha: 1.0)
        addSubview(timeLabel)
        timeLabel.text = "hello"
    }
}
