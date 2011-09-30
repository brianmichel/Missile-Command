//
//  MCAppDelegate.m
//  Missile Command Desktop
//
//  Created by Brian Michel on 9/21/11.
//  Copyright (c) 2011 Foureyes. All rights reserved.
//

#import "MCAppDelegate.h"
#import "MissileCommandCenter.h"

#define kUpTag 1
#define kDownTag 2
#define kLeftTag 3
#define kRightTag 4
#define kFireTag 5
#define kStopTag 6

@interface MCAppDelegate (Private)
- (void)enableButtons;
- (void)disableButtons;
- (void)turretConnectivityChange:(NSNotification *)notification;
- (void)startServer;
- (void)stopServer;
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
@synthesize asyncSocket = _asyncSocket;
@synthesize connections = _connections;
@synthesize service = _service;

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
      [self startServer];
      break;
    case 1:
      NSLog(@"Turn The Server OFF!");
      [self stopServer];
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

#pragma - Bonjour Server Methods
- (void)startServer {
  self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
  
  self.connections = [NSMutableArray array];
  
  NSError *err = nil;
	if ([self.asyncSocket acceptOnPort:0 error:&err])
	{
		// So what port did the OS give us?
		
		UInt16 port = [self.asyncSocket localPort];
		
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

- (void)stopServer {
  [self.asyncSocket disconnectAfterReadingAndWriting];
  [self.service stop];
}

#pragma mark - ASyncSocket Delegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	NSLog(@"Accepted new socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
	
	// The newSocket automatically inherits its delegate & delegateQueue from its parent.
	
	[self.connections addObject:newSocket];
  
	NSString *welcomeMsg = @"Welcome to the AsyncSocket Echo Server\r\n";
	NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
	
	[newSocket writeData:welcomeData withTimeout:-1 tag:4];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	[self.connections removeObject:sock];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
  [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
  NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
  NSLog(@"READ THE SOCKET!");
	dispatch_async(dispatch_get_main_queue(), ^{
		switch (tag) {
      case kUpTag: [self moveUp:self]; break;
      case kDownTag: [self moveDown:self]; break;
      case kLeftTag: [self moveLeft:self]; break;
      case kRightTag: [self moveRight:self]; break;
      case kFireTag: [self fire:self]; break;
      case kStopTag: [self stopTurret:self]; break;
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
		
		[sock writeData:warningData withTimeout:-1 tag:5];
		
		return 10.0;
	}
	
	return 0.0;
}

#pragma mark - NSNetService Delegate
- (void)netServiceDidPublish:(NSNetService *)ns
{
	NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)",
        [ns domain], [ns type], [ns name], (int)[ns port]);
}

- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{
	// Override me to do something here...
	// 
	// Note: This method in invoked on our bonjour thread.
	
	NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@",
        [ns domain], [ns type], [ns name], errorDict);
}
@end
