//
//  MCAppDelegate.m
//  Missile Command Desktop
//
//  Created by Brian Michel on 9/21/11.
//  Copyright (c) 2011 Foureyes. All rights reserved.
//

#import "MCAppDelegate.h"
#import "MissileCommandCenter.h"

@interface MCAppDelegate (Private)
- (void)enableButtons;
- (void)disableButtons;
- (void)turretConnectivityChange:(NSNotification *)notification;
- (void)updateClientLabel;
@end

@implementation MCAppDelegate

@synthesize window = _window;
@synthesize upButton = _upButton;
@synthesize rightButton = _rightButton;
@synthesize downButton = _downButton;
@synthesize leftButton = _leftButton;
@synthesize fireButton = _fireButton;
@synthesize stopButton = _stopButton;
@synthesize failureTextField = _failureTextField;
@synthesize serverSwitch = _serverSwitch;
@synthesize numberOfClients = _numberOfClients;
@synthesize server = __server;

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
  self.server = [[MissileServer alloc] init];
  [self.server setDelegate:self];
}

- (void)updateClientLabel {
  if ([self.server.connections count] == 1) {
    [self.numberOfClients setTitle:@"Client Connected"];
  } else if ([self.server.connections count] > 1) {
    [self.numberOfClients setTitle:[NSString stringWithFormat:@"Clients Connected (%i)", [self.server.connections count]]];
  } else {
    [self.numberOfClients setTitle:@"No Clients Connected"];
  }
}

#pragma mark - Turret Actions
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

- (IBAction)toggleServer:(id)sender {
  NSSegmentedControl *serverSwitch = (NSSegmentedControl *)sender;
  switch (serverSwitch.selectedSegment) {
    case 0:
      NSLog(@"Turn The Server ON!");
      [self.server start];
      break;
    case 1:
      NSLog(@"Turn The Server OFF!");
      [self.server stop];
      break;
  }
}

- (void)turretConnectivityChange:(NSNotification *)notification {
  NSNumber *turretAvailable = (NSNumber *)notification.object;
  if ([turretAvailable boolValue]) {
    [self enableButtons];
  } else {
    [self disableButtons];
  }
}

#pragma mark - Enable / Disable Buttons

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

#pragma mark - Missile Server Delegate
- (void)server:(MissileServer *)server didStartSuccessfully:(NSNetService *)service {}
- (void)server:(MissileServer *)server failedToStartWithError:(NSError *)error {
  [self.server stop];
}

- (void)server:(MissileServer *)server didReceiveCommand:(MissileServerCommand)command {
  switch (command) {
    case MissileServerCommandUp: [self moveUp:self]; break;
    case MissileServerCommandDown: [self moveDown:self]; break;
    case MissileServerCommandLeft: [self moveLeft:self]; break;
    case MissileServerCommandRight: [self moveRight:self]; break;
    case MissileServerCommandFire: [self fire:self]; break;
    case MissileServerCommandStop: [self stopTurret:self]; break;
    default: [self stopTurret:self]; break;
  }
}
- (void)server:(MissileServer *)server didAcceptNewClient:(GCDAsyncSocket *)socket {
  [self updateClientLabel];
}
- (void)server:(MissileServer *)server clientDidDisconnectSocket:(GCDAsyncSocket *)socket withError:(NSError *)error {
  [self updateClientLabel];
}

@end
