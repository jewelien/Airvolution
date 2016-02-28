//
//  AdView.swift
//  Airvolution
//
//  Created by Julien Guanzon on 2/22/16.
//  Copyright © 2016 Julien Guanzon. All rights reserved.
//

import Foundation
import GoogleMobileAds

let adUnitIDtest = "ca-app-pub-3940256099942544/2934735716";
let adUnitIDBannerAd = "ca-app-pub-3012240931853239/1747853102";

class StyleController :NSObject {
    static let sharedInstance = StyleController()

    var bannerView:GADBannerView {
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        let viewFrame = CGRectMake(0, screenHeight - 100, 380, 50)
        let bannerView = GADBannerView(frame: viewFrame)
        bannerView.adUnitID = adUnitIDBannerAd
        return bannerView
    }
}