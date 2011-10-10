//
//  MCMAppDelegate.h
//  Missile Command Desktop
//
//  Created by Brian Michel on 9/29/11.
//  Copyright (c) 2011 Brian Michel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MissileCommandWindow.h"
#import "GCDAsyncSocket.h"
#import "MissileServer.h"

@interface MCAppDelegate : NSObject <NSApplicationDelegate, MissileServerDelegate> {
  NSButton *_upButton;
  NSButton *_rightButton;
  NSButton *_downButton;
  NSButton *_leftButton;
  NSButton *_fireButton;
  NSButton *_stopButton;
  NSTextField *_failureTextField;
  NSSegmentedControl *_serverSwitch;
  NSTextFieldCell *_numberOfClients;
}

@property (strong) IBOutlet MissileCommandWindow *window;
@property (strong) IBOutlet NSButton *upButton;
@property (strong) IBOutlet NSButton *rightButton;
@property (strong) IBOutlet NSButton *downButton;
@property (strong) IBOutlet NSButton *leftButton;
@property (strong) IBOutlet NSButton *fireButton;
@property (strong) IBOutlet NSButton *stopButton;
@property (strong) IBOutlet NSTextField *failureTextField;
@property (strong) IBOutlet NSSegmentedControl *serverSwitch;
@property (strong) IBOutlet NSTextFieldCell *numberOfClients;
@property (strong) MissileServer *server;


- (IBAction)stopTurret:(id)sender;
- (IBAction)moveUp:(id)sender;
- (IBAction)moveRight:(id)sender;
- (IBAction)moveDown:(id)sender;
- (IBAction)moveLeft:(id)sender;
- (IBAction)fire:(id)sender;
- (IBAction)toggleServer:(id)sender;
- (IBAction)showRemoteTurrets:(id)sender;
@end
