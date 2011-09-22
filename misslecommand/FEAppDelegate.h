//
//  FEAppDelegate.h
//  missilecommand
//
//  Created by Brian Michel on 9/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FEAppDelegate : NSObject <NSApplicationDelegate> {
  NSButton *_upButton;
  NSButton *_rightButton;
  NSButton *_downButton;
  NSButton *_leftButton;
  NSButton *_fireButton;
  NSButton *_stopButton;
  NSTextField *_failureTextField;
}


@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSButton *upButton;
@property (strong) IBOutlet NSButton *rightButton;
@property (strong) IBOutlet NSButton *downButton;
@property (strong) IBOutlet NSButton *leftButton;
@property (strong) IBOutlet NSButton *fireButton;
@property (strong) IBOutlet NSButton *stopButton;
@property (strong) IBOutlet NSTextField *failureTextField;


- (IBAction)stopTurret:(id)sender;
- (IBAction)moveUp:(id)sender;
- (IBAction)moveRight:(id)sender;
- (IBAction)moveDown:(id)sender;
- (IBAction)moveLeft:(id)sender;
- (IBAction)fire:(id)sender;
@end
