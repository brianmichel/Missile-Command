//
//  MissileServer.h
//  Missile Command Desktop
//
//  Created by Brian Michel on 10/2/11.
//  Copyright (c) 2011 Brian Michel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

typedef enum MissileServerCommand {
  MissileServerCommandUp = 1,
  MissileServerCommandDown,
  MissileServerCommandLeft,
  MissileServerCommandRight,
  MissileServerCommandFire,
  MissileServerCommandStop,
} MissileServerCommand; 

@class MissileServer;

@protocol MissileServerDelegate <NSObject>

@optional
//Bonjour Stuff
- (void)server:(MissileServer *)server didStartSuccessfully:(NSNetService *)service;
- (void)server:(MissileServer *)server failedToStartWithError:(NSError *)error;

//Socket Stuff
- (void)server:(MissileServer *)server didReceiveCommand:(MissileServerCommand)command;
- (void)server:(MissileServer *)server didAcceptNewClient:(GCDAsyncSocket *)socket;
- (void)server:(MissileServer *)server clientDidDisconnectSocket:(GCDAsyncSocket *)socket withError:(NSError *)error;

@end

@interface MissileServer : NSObject <NSNetServiceDelegate, GCDAsyncSocketDelegate>

@property (strong) GCDAsyncSocket *socket;
@property (strong) NSNetService *service;
@property (strong) NSMutableArray *connections;
@property (assign) id<MissileServerDelegate>delegate;

- (void)start;
- (void)stop;
@end
