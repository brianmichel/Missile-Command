//
//  MissileCommandWindow.m
//  missilecommand
//
//  Created by Brian Michel on 9/27/11.
//  Copyright (c) 2011 Foureyes. All rights reserved.
//

#import "MissileCommandWindow.h"
#import "MissileCommandCenter.h"

@implementation MissileCommandWindow

- (void)keyDown:(NSEvent *)theEvent{
  [super keyDown:theEvent];

  switch (theEvent.keyCode) {
    case 13:
    case 126:
      [[MissileCommandCenter sharedCommandCenter] upTurret];
      break;
    case 0:
    case 123:
      [[MissileCommandCenter sharedCommandCenter] leftTurret];
      break;
    case 1:
    case 125:
      [[MissileCommandCenter sharedCommandCenter] downTurret];
      break;
    case 2:
    case 124:
      [[MissileCommandCenter sharedCommandCenter] rightTurret];
      break;
    case 49:
      [[MissileCommandCenter sharedCommandCenter] fireTurret];
      break;
    default:
      break;
  }
}

- (void)keyUp:(NSEvent *)theEvent{
  [super keyUp:theEvent];
  
  if (theEvent.keyCode != 49) {
    [[MissileCommandCenter sharedCommandCenter] stopTurret];
  }
}

- (void)mouseUp:(NSEvent *)theEvent {
  [super mouseUp:theEvent];
  [[MissileCommandCenter sharedCommandCenter] stopTurret];
}
@end
