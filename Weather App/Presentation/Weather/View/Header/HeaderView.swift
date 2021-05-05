//
//  HeaderView.swift
//  Weather App
//
//  Created by Hossein Vesali Naesh on 5/2/21.
//  Copyright © 2021 Kirtan Patel. All rights reserved.
//

import UIKit

class HeaderView : UIView {
    
    var cityLabel : UILabel!
    var temperatureLabel : UILabel!
    var hiloLabel : UILabel!
    var conditionsLabel : UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        
        self.frame = CGRect(x: 0, y: 44, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
        
        let inset: CGFloat = 16
        let temperatureHeight: CGFloat = self.frame.size.height / 2
        let hiloHeight: CGFloat = 40
        let iconHeight: CGFloat = 30
        let searchBarHeight: CGFloat = 52
        
        let hiloFrame = CGRect.init(x: inset, y: self.frame.size.height - hiloHeight, width: self.frame.size.width - 2*inset, height: hiloHeight)
        
        let temperatureFrame = CGRect.init(x: 0, y: searchBarHeight, width: self.frame.size.width, height: temperatureHeight)
        
        let iconFrame = CGRect.init(x: inset, y: hiloFrame.origin.y - iconHeight, width: iconHeight, height: iconHeight)
        
        var conditionsFrame = iconFrame
        
        conditionsFrame.size.width = self.bounds.size.width - 2*inset - iconHeight - 10
        conditionsFrame.origin.x = iconFrame.origin.x + iconHeight + 10
        
        temperatureLabel = UILabel(frame: temperatureFrame)
        temperatureLabel.backgroundColor = .clear
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center
        temperatureLabel.text = "0°"
        temperatureLabel.font = UIFont.init(name: "HelveticaNeue-UltraLight", size: 120)
        self.addSubview(temperatureLabel)
        
        
        hiloLabel = UILabel(frame: hiloFrame)
        hiloLabel.backgroundColor = .clear
        hiloLabel.textColor = .white
        hiloLabel.text = "0° / 0°"
        hiloLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 28)
        self.addSubview(hiloLabel)
        
        
        cityLabel = UILabel(frame: CGRect(x: temperatureLabel.frame.origin.x, y: inset + temperatureLabel.frame.origin.y + temperatureHeight, width: temperatureLabel.frame.size.width, height: 30))
        cityLabel.backgroundColor = .clear
        cityLabel.textColor = .white
        cityLabel.textAlignment = .center
        cityLabel.text = "Loading..."
        cityLabel.font = UIFont.init(name: "HelveticaNeue-Bold", size: 25)
        self.addSubview(cityLabel)
        
        conditionsLabel = UILabel(frame: conditionsFrame)
        conditionsLabel.backgroundColor = .clear
        conditionsLabel.textColor = .white
        conditionsLabel.text = "Loading..."
        conditionsLabel.font = UIFont.init(name: "HelveticaNeue-Light", size: 18)
        self.addSubview(conditionsLabel)
        
        let iconView = UIImageView(frame: iconFrame)
        iconView.contentMode = .scaleAspectFit
        iconView.backgroundColor = .clear
        iconView.image = UIImage(named: "few")
        self.addSubview(iconView)
    }
}
