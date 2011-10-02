//
//  MissileServer.m
//  Missile Command Desktop
//
//  Created by Brian Michel on 10/2/11.
//  Copyright (c) 2011 Brian Michel. All rights reserved.
//

#import "MissileServer.h"

@implementation MissileServer

@synthesize socket = __socket;
@synthesize service = __service;
@synthesize connections = __connections;
@synthesize delegate = __delegate;


#pragma mark - Start / Stop Server
- (void)start {
  self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
  
  self.connections = [NSMutableArray array];
  
  NSError *err = nil;
	if ([self.socket acceptOnPort:0 error:&err])
	{
		// So what port did the OS give us?
		
		UInt16 port = [self.socket localPort];
		
		// Create and publish the bonjour service.
		// Obviously you will be using your own custom service type.
		
		self.service = [[NSNetService alloc] initWithDomain:@"local."
                                                   type:@"_missilecommand._tcp."
                                                   name:@""
                                                   port:port];
		
		[self.service setDelegate:self];
		[self.service publish];
	}
	else
	{
		NSLog(@"Error in acceptOnPort:error: -> %@", err);
	}
}

- (void)stop {
  [self.connections removeAllObjects];
  [self.socket disconnectAfterReadingAndWriting];
  [self.service stop];
  self.service = nil;
  self.socket = nil;
}

#pragma mark - ASyncSocket Delegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	NSLog(@"Accepted new socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
	
	// The newSocket automatically inherits its delegate & delegateQueue from its parent.
	
	[self.connections addObject:newSocket];
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(server:didAcceptNewClient:)]) {
    [self.delegate server:self didAcceptNewClient:newSocket];
  }
  
	NSString *welcomeMsg = @"Connected to Missile Server, Enter Launch Codes!\r\n";
	NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
	
	[newSocket writeData:welcomeData withTimeout:-1 tag:1];
  [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	[self.connections removeObject:sock];
  if (self.delegate && [self.delegate respondsToSelector:@selector(server:clientDidDisconnectSocket:withError:)]) {
    [self.delegate server:self clientDidDisconnectSocket:sock withError:err];
  }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
  [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
  NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length])];
	NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
  NSLog(@"READ THE SOCKET! %@", msg);
	dispatch_async(dispatch_get_main_queue(), ^{
    if (self.delegate && [self.delegate respondsToSelector:@selector(server:didReceiveCommand:)]) {
      MissileServerCommand command = MissileServerCommandStop;
      switch ([msg intValue]) {
        case MissileServerCommandUp: command = MissileServerCommandUp; break;
        case MissileServerCommandDown: command = MissileServerCommandDown; break;
        case MissileServerCommandLeft: command = MissileServerCommandLeft; break;
        case MissileServerCommandRight: command = MissileServerCommandRight; break;
        case MissileServerCommandFire: command = MissileServerCommandFire; break;
        case MissileServerCommandStop: command = MissileServerCommandStop; break;
      }
      [self.delegate server:self didReceiveCommand:command];
    }
	});
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
	if (elapsed <= 5.0)
	{
		NSString *warningMsg = @"Are you still there?\r\n";
		NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
		
		[sock writeData:warningData withTimeout:-1 tag:2];
		
		return 10.0;
	}
	
	return 0.0;
}

#pragma mark - NSNetService Delegate
- (void)netServiceDidPublish:(NSNetService *)ns
{
	NSLog(@"Missile Server Published: domain(%@) type(%@) name(%@) port(%i)",
        [ns domain], [ns type], [ns name], (int)[ns port]);
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(server:didStartSuccessfully:)]) {
    [self.delegate server:self didStartSuccessfully:ns];
  }
}

- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{
	NSLog(@"Missile Server Failed to Publish Service: domain(%@) type(%@) name(%@) - %@",
        [ns domain], [ns type], [ns name], errorDict);
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(server:failedToStartWithError:)]) {
    [self.delegate server:self failedToStartWithError:[NSError errorWithDomain:@"Server Startup Failure" code:0xDEADBEEF userInfo:errorDict]];
  }
}

@end
