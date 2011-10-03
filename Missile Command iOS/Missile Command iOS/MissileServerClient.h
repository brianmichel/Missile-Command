//
//  MissileServerClient.h
//  Missile Command Desktop
//
//  Created by Brian Michel on 10/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@class MissileServerClient;

@protocol MissileServerClientDelegate <NSObject>

@optional
- (void)client:(MissileServerClient *)client didReceiveMessage:(NSString *)message;
- (void)client:(MissileServerClient *)client failedToConnectToServer:(NSError *)error;
- (void)client:(MissileServerClient *)client didDisconnectFromSocket:(GCDAsyncSocket *)socket withError:(NSError *)error;

- (void)clientDidConnectToServer;
- (void)clientDidWriteMessage;
@end

@interface MissileServerClient : NSObject <NSNetServiceDelegate, GCDAsyncSocketDelegate> {
  BOOL _connected;
}

@property (strong) NSNetService *service;
@property (strong) GCDAsyncSocket *socket;
@property (strong) NSMutableArray *addresses;
@property (assign) id<MissileServerClientDelegate>delegate;

- (id)initWithService:(NSNetService *)service;
- (void)startSession;
- (void)endSession;
- (void)writeDataToSocket:(NSData *)data;

@end
