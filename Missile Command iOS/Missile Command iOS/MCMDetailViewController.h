//
//  MCMDetailViewController.h
//  Missile Command Mobile
//
//  Created by Brian Michel on 9/29/11.
//  Copyright (c) 2011 Brian Michel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface MCMDetailViewController : UIViewController <GCDAsyncSocketDelegate, NSNetServiceDelegate> {
  UILabel *serverLabel;
  UIButton *upButton;
  UIButton *downButton;
  UIButton *leftButton;
  UIButton *rightButton;
  UIButton *stopButton;
  UIButton *fireButton;
  NSNetService *service;
  UIButton *downAction;
  NSArray *buttons;
}

@property (strong, nonatomic) IBOutlet UILabel *serverLabel;
@property (strong, nonatomic) IBOutlet UIButton *upButton;
@property (strong, nonatomic) IBOutlet UIButton *downButton;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UIButton *fireButton;
@property (strong, nonatomic) NSNetService *service;
@property (strong, nonatomic) NSMutableArray *addressArray;
@property (strong, nonatomic) GCDAsyncSocket *asyncSocket;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

- (IBAction)upAction:(id)sender;
- (IBAction)downAction:(id)sender;
- (IBAction)leftAction:(id)sender;
- (IBAction)rightAction:(id)sender;
- (IBAction)stopAction:(id)sender;
- (IBAction)fireAction:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andService:(NSNetService *)service_;

@end
