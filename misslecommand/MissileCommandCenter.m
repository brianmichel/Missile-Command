//
//  MissileCommandCenter.m
//  missilecommand
//
//  Created by Brian Michel on 9/21/11.
//  Copyright (c) 2011 Foureyes. All rights reserved.
//

#import "MissileCommandCenter.h"
#import <mach/mach_time.h>

NSString * kMissileCommandConnectivityChange = @"kMissileCommandConnectivityChange";

@interface MissileCommandCenter (Private)
- (IOReturn)performMissileCommand:(MissileCommandAction)command;
- (void)createQueryDictionary;
- (BOOL)destroyManager;
- (BOOL)createManager;
- (BOOL)attemptOpen;
@end

static void Handle_DeviceMatchingCallback(void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inDeviceRef) {
  printf("%s(context: %p, result: %p, sender: %p, device: %p).\n",
         __PRETTY_FUNCTION__, inContext, (void *) inResult, inSender, (void*) inDeviceRef);
  MissileCommandCenter *center = (__bridge MissileCommandCenter *)inContext;
  [center attemptOpen];
  center.turretConnected = YES;
  [[NSNotificationCenter defaultCenter] postNotificationName:kMissileCommandConnectivityChange object:[NSNumber numberWithBool:YES]];
}

static void Handle_DeviceRemovalCallback(void *inContext,IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef) {
  printf("%s(context: %p, result: %p, sender: %p, device: %p).\n",
         __PRETTY_FUNCTION__, inContext, (void *) inResult, inSender, (void*) inIOHIDDeviceRef);
  MissileCommandCenter *center = (__bridge MissileCommandCenter *)inContext;
  center.turretConnected = NO;
  [[NSNotificationCenter defaultCenter] postNotificationName:kMissileCommandConnectivityChange object:[NSNumber numberWithBool:NO]];
}  

@implementation MissileCommandCenter

@synthesize manager;
@synthesize queryDictionary;
@synthesize missileLauncher;
@synthesize turretConnected;

+ (id)sharedCommandCenter
{
  static dispatch_once_t once;
  static MissileCommandCenter *sharedCommandCenter;
  dispatch_once(&once, ^{ sharedCommandCenter = [[self alloc] init]; });
  return sharedCommandCenter;
}

- (id)init {
  self = [super init];
  if (self) {
    //do some shit
    [self createQueryDictionary];
    [self createManager];
    [self attemptOpen];
  }
  return self;
}

#pragma IO HID Manager Creation
- (BOOL)createManager {
  self.manager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
  if (self.manager) {
    IOHIDManagerSetDeviceMatching(self.manager, (__bridge CFDictionaryRef)self.queryDictionary);
    IOHIDManagerRegisterDeviceMatchingCallback(self.manager, Handle_DeviceMatchingCallback, (__bridge void*)self);
    IOHIDManagerRegisterDeviceRemovalCallback(self.manager, Handle_DeviceRemovalCallback, (__bridge void*)self);
    IOHIDManagerScheduleWithRunLoop(self.manager, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
  } else {
    return NO;
  }
  return YES;
}

- (BOOL)destroyManager {
  if (self.manager) {
    IOHIDManagerRegisterDeviceMatchingCallback(self.manager, NULL, (__bridge void*)self);
    IOHIDManagerRegisterDeviceRemovalCallback(self.manager, NULL, (__bridge void*)self);
    IOHIDManagerUnscheduleFromRunLoop(self.manager, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    IOHIDManagerClose(self.manager, kIOHIDOptionsTypeNone);
    return YES;
  }
  return NO;
}

- (void)createQueryDictionary {
  self.queryDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"USB Missile Launcher", CFSTR(kIOHIDProductKey), @"Syntek", CFSTR(kIOHIDManufacturerKey), nil];
}

- (BOOL)attemptOpen {
  IOReturn openCode = -1;
  if (self.manager) {
    openCode = IOHIDManagerOpen(self.manager, kIOHIDOptionsTypeNone);
  }
  
  if (openCode == kIOReturnSuccess) {
    NSLog(@"OPENED THE FUCK OUT OF THIS!");
    NSSet *set = (__bridge NSSet *)IOHIDManagerCopyDevices(self.manager);
    self.missileLauncher = (__bridge IOHIDDeviceRef)[set anyObject];
    NSLog(@"DEVICES: %@", set);
    return YES;
  } else {
    NSLog(@"Didn't open shit: %i", openCode);
    return NO;
  }
}

- (void)fireTurret { IOReturn ret = [self performMissileCommand:MissileCommandActionFire]; NSLog(@"Return Value For Fire! %i", ret); }

- (void)upTurret { IOReturn ret = [self performMissileCommand:MissileCommandActionUp]; NSLog(@"Return Value For Up! %i", ret); }

- (void)downTurret { IOReturn ret = [self performMissileCommand:MissileCommandActionDown]; NSLog(@"Return Value For Down! %i", ret); }

- (void)leftTurret { IOReturn ret = [self performMissileCommand:MissileCommandActionLeft]; NSLog(@"Return Value For Left! %i", ret); }

- (void)rightTurret { IOReturn ret = [self performMissileCommand:MissileCommandActionRight]; NSLog(@"Return Value For Right! %i", ret); }

- (void)stopTurret { IOReturn ret = [self performMissileCommand:MissileCommandActionStop]; NSLog(@"Return Value For Stop! %i", ret); }

#pragma mark - The thing that makes this all work.
- (IOReturn)performMissileCommand:(MissileCommandAction)command {
  NSArray *elementArray = (__bridge  NSArray *)IOHIDDeviceCopyMatchingElements(self.missileLauncher, NULL, kIOHIDOptionsTypeNone);
  
  IOHIDElementRef element = (__bridge IOHIDElementRef)[elementArray objectAtIndex:1];
  NSLog(@"Element usage: %i, unit: %i, page: %i, reportid: %i, element exp: %i", IOHIDElementGetUsage(element), IOHIDElementGetUnit(element), IOHIDElementGetUsagePage(element), IOHIDElementGetReportID(element), IOHIDElementGetUnitExponent(element));
  
  NSString *inCommand = nil;
  switch (command) {
    case MissileCommandActionUp: { inCommand = @"\x02"; } break;
    case MissileCommandActionDown: { inCommand = @"\x01"; } break;
    case MissileCommandActionLeft: { inCommand = @"\x04"; } break;
    case MissileCommandActionRight: { inCommand = @"\x08"; } break;
    case MissileCommandActionStop: { inCommand = @"\x20"; } break;
    case MissileCommandActionFire: { inCommand = @"\x10"; } break;
  }
  
  
  NSString *stringCommand = [NSString stringWithFormat:@"\\x02\%@\\x00\\x00\\x00\\x00\\x00\\x00", inCommand];
  NSData  *commandData = [stringCommand dataUsingEncoding:NSUTF8StringEncoding];
  const uint8_t * bytes = (const uint8_t *)[commandData bytes];

  return IOHIDDeviceSetReport(self.missileLauncher, kIOHIDReportTypeOutput, IOHIDElementGetReportID(element), bytes, 8);
  //Holy Ugly!
}

@end
