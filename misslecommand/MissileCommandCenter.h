//
//  MissileCommandCenter.h
//  missilecommand
//
//  Created by Brian Michel on 9/21/11.
//  Copyright (c) 2011 Foureyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>
#import <IOKit/usb/IOUSBLib.h>

extern NSString * kMissileCommandConnectivityChange;

typedef enum MissileCommandAction {
  MissileCommandActionUp = 0,
  MissileCommandActionDown,
  MissileCommandActionLeft,
  MissileCommandActionRight,
  MissileCommandActionStop,
  MissileCommandActionFire
} MissileCommandAction;


@interface MissileCommandCenter : NSObject {
  IOHIDManagerRef manager;
  IOHIDDeviceRef missileLauncher;
  NSDictionary *queryDictionary;
  BOOL turretConnected;
}

@property (nonatomic, assign) IOHIDManagerRef manager;
@property (nonatomic, assign) IOHIDDeviceRef missileLauncher;
@property (nonatomic, retain) NSDictionary *queryDictionary;
@property (nonatomic, assign) BOOL turretConnected;

+ (id)sharedCommandCenter;

- (void)fireTurret;
- (void)stopTurret;
- (void)leftTurret;
- (void)rightTurret;
- (void)downTurret;
- (void)upTurret;
@end
