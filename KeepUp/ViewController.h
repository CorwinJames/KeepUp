//
//  ViewController.h
//  KeepUp
//

//  Copyright (c) 2014 James Is a Baller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>


@interface ViewController : UIViewController <ADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet ADBannerView *bannerAd;

@property (weak, nonatomic) IBOutlet ADBannerView *bannerAd2;

@end
