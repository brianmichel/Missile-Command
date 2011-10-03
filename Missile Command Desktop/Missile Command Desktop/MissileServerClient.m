//
//  MissileServerClient.m
//  Missile Command Desktop
//
//  Created by Brian Michel on 10/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MissileServerClient.h"

@interface MissileServerClient (Internal)
- (void)connectToNextAddress;
@end

@implementation MissileServerClient

@synthesize socket = __socket;
@synthesize service = __service;
@synthesize delegate = __delegate;
@synthesize addresses = __addresses;

- (id)initWithService:(NSNetService *)service {
  self = [super init];
  
  if (self) {
    self.service = service;
  }
  
  return self;
}

#pragma mark - NSNetService Delegate
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	NSLog(@"Unable to resovle service: %@, %@", [sender name], errorDict);
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	NSLog(@"DidResolve: %@", [sender addresses]);
	
	if (self.addresses == nil)
	{
		self.addresses = [[sender addresses] mutableCopy];
	}
	
	if (self.socket == nil)
	{
		self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self connectToNextAddress];
	}
}

#pragma mark - Socket Delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"Socket:DidConnectToHost: %@ Port: %hu", host, port);
	
	_connected = YES;
  [sock readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	NSLog(@"SocketDidDisconnect:WithError: %@", err);
	
  if (self.delegate && [self.delegate respondsToSelector:@selector(client:didDisconnectFromSocket:withError:)]) {
    [self.delegate client:self didDisconnectFromSocket:sock withError:err];
  } 

	if (!_connected)
	{
		[self connectToNextAddress];
	}
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSLog(@"READ STRING %@", string);
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(client:didReceiveMessage:)]) {
    [self.delegate client:self didReceiveMessage:string];
  }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
  NSLog(@"DID WRITE THE DATA");
  if (self.delegate && [self.delegate respondsToSelector:@selector(clientDidWriteMessage)]) {
    [self.delegate clientDidWriteMessage];
  }
}

#pragma mark - Actions
- (void)reconnectSession {
  [self endSession];
  [self startSession];
}

- (void)startSession {
  [self.service setDelegate:self];
  [self.service resolveWithTimeout:5.0];
}

- (void)endSession {
  [self.socket disconnect];
  [self.service stop];
  _connected = NO;
}

- (void)writeDataToSocket:(NSData *)data {
  if (!self.socket) {return;}
  
  [self.socket writeData:data withTimeout:-1 tag:0];
}

- (void)connectToNextAddress
{
	BOOL done = NO;
	
	while (!done && ([self.addresses count] > 0))
	{
		NSData *addr;

		if (YES) // Iterate forwards
		{
			addr = [self.addresses objectAtIndex:0];
			[self.addresses removeObjectAtIndex:0];
		}
		else // Iterate backwards
		{
			addr = [self.addresses lastObject];
			[self.addresses removeLastObject];
		}
		
		NSLog(@"Attempting connection to %@", addr);
		
		NSError *err = nil;
		if ([self.socket connectToAddress:addr error:&err])
		{
			done = YES;
      if (self.delegate && [self.delegate respondsToSelector:@selector(clientDidConnectToServer)]) {
        [self.delegate clientDidConnectToServer];
      }
		}
		else
		{
			NSLog(@"Unable to connect: %@", err);
		}
	}
	
	if (!done)
	{
    if (self.delegate && [self.delegate respondsToSelector:@selector(client:failedToConnectToServer:)]) {
      [self.delegate client:self failedToConnectToServer:[NSError errorWithDomain:@"Unable To Connect" code:0xCAFEBABE userInfo:nil]];
    }
		NSLog(@"Unable to connect to any resolved address");
	}
}

- (void)dealloc {
  [self endSession];
  [__service release];
  __service = nil;
  [__socket release];
  __socket = nil;
  [__addresses release];
  __addresses = nil;
  [super dealloc];
}

@end
