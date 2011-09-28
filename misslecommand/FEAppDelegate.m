//
//  FEAppDelegate.m
//  missilecommand
//
//  Created by Brian Michel on 9/21/11.
//  Copyright (c) 2011 Foureyes. All rights reserved.
//

#import "FEAppDelegate.h"
#import "MissileCommandCenter.h"

@interface FEAppDelegate (Private)
- (void)enableButtons;
- (void)disableButtons;
- (void)turretConnectivityChange:(NSNotification *)notification;
@end

@implementation FEAppDelegate

@synthesize window = _window;
@synthesize upButton = _upButton;
@synthesize rightButton = _rightButton;
@synthesize downButton = _downButton;
@synthesize leftButton = _leftButton;
@synthesize fireButton = _fireButton;
@synthesize stopButton = _stopButton;
@synthesize failureTextField = _failureTextField;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // Insert code here to initialize your application
  [MissileCommandCenter sharedCommandCenter];
  
  if ([[MissileCommandCenter sharedCommandCenter] turretConnected]) {
    [self enableButtons];
  } else {
    [self disableButtons];
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turretConnectivityChange:) name:kMissileCommandConnectivityChange object:nil];
}

- (IBAction)stopTurret:(id)sender {
  [[MissileCommandCenter sharedCommandCenter] stopTurret];
}

- (IBAction)moveUp:(id)sender {
  [[MissileCommandCenter sharedCommandCenter] upTurret];
}

- (IBAction)moveRight:(id)sender {
  [[MissileCommandCenter sharedCommandCenter] rightTurret];
}

- (IBAction)moveDown:(id)sender {
  [[MissileCommandCenter sharedCommandCenter] downTurret];
}

- (IBAction)moveLeft:(id)sender {
  [[MissileCommandCenter sharedCommandCenter] leftTurret];
}

- (IBAction)fire:(id)sender {
  [[MissileCommandCenter sharedCommandCenter] fireTurret];
}

- (void)turretConnectivityChange:(NSNotification *)notification {
  NSNumber *turretAvailable = (NSNumber *)notification.object;
  if ([turretAvailable boolValue]) {
    [self enableButtons];
  } else {
    [self disableButtons];
  }
}

- (void)enableButtons {
  [_failureTextField setHidden:YES];
  [_upButton setEnabled:YES];
  [_rightButton setEnabled:YES];
  [_leftButton setEnabled:YES];
  [_downButton setEnabled:YES];
  [_stopButton setEnabled:YES];
  [_fireButton setEnabled:YES];
}

- (void)disableButtons {
  [_failureTextField setHidden:NO];
  [_upButton setEnabled:NO];
  [_rightButton setEnabled:NO];
  [_leftButton setEnabled:NO];
  [_downButton setEnabled:NO];
  [_stopButton setEnabled:NO];
  [_fireButton setEnabled:NO];
}

@end
