//
//  ViewController.m
//  KeepUp
//
//  Created by James Corwin on 5/17/14.
//  Copyright (c) 2014 James Is a Baller. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"

NSTimer *adPositionChangeTimer;
BOOL adAtTop;
int randomTimeForSwitchAd;

@implementation ViewController

-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    self.bannerAd.backgroundColor = [UIColor clearColor];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [self.bannerAd setAlpha:1];
   
    self.bannerAd.frame = CGRectMake(0, self.view.frame.size.height-self.bannerAd.frame.size.height, self.bannerAd.frame.size.width, self.bannerAd.frame.size.height);
    adAtTop = false;
      
    
    [UIView commitAnimations];
    
    self.bannerAd.hidden = NO;
    NSLog(@"Banner is NOT hidden");
    
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"running");
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [self.bannerAd setAlpha:0];
    [UIView commitAnimations];
    self.bannerAd.hidden = YES;
    self.bannerAd2.hidden = YES;
    NSLog(@"banner is hidden YES");
    
    if (self.bannerAd)
        
    {
        
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // Assumes the banner view is placed at the bottom of the screen.
        
        [UIView commitAnimations];
        
        self.bannerAd = NO;
    }
    
    
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    NSLog(@"Banner finushed!");
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [self.bannerAd setAlpha:0];
    [UIView commitAnimations];
    self.bannerAd.hidden = YES;
    NSLog(@"banner is hidden YES");
    [adPositionChangeTimer invalidate];
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
