//
//  MCMViewController.m
//  Missile Command iOS
//
//  Created by Brian Michel on 9/29/11.
//  Copyright (c) 2011 Brian Michel. All rights reserved.
//

#import "MCMViewController.h"
#import "MCMDetailViewController.h"

@implementation MCMViewController

@synthesize addressArray = __addressArray;
@synthesize serviceBrowser = __serviceBrowser;
@synthesize serverService = __serverService;
@synthesize asyncSocket = __asyncSocket;
@synthesize servicesArray = __servicesArray;

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.servicesArray = [NSMutableArray array];
  
  self.title = @"Turrets";
  
  self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
	
	[self.serviceBrowser setDelegate:self];
	[self.serviceBrowser searchForServicesOfType:@"_missilecommand._tcp." inDomain:@"local."];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}

#pragma mark - Table View Delegate / Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.servicesArray count] ? [self.servicesArray count] : 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString * cellIdentifier = @"addressCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  }
  if ([self.servicesArray count] > 0) {
    NSNetService *service = [self.servicesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = service.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.userInteractionEnabled = YES;
  } else {
    cell.textLabel.text = @"No Turrets Found";
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = NO;
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSNetService *service = [self.servicesArray objectAtIndex:0];
  MCMDetailViewController *detail = [[MCMDetailViewController alloc] initWithNibName:@"MCMDetailViewController" bundle:nil andService:service];
  detail.asyncSocket = self.asyncSocket;
  [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - NSNetService(Browser) Delegate
- (void)netServiceBrowser:(NSNetServiceBrowser *)sender didNotSearch:(NSDictionary *)errorInfo
{
	NSLog(@"DidNotSearch: %@", errorInfo);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender
           didFindService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
	NSLog(@"DidFindService: %@", [netService name]);
	
	// Connect to the first service we find
	if (![self.servicesArray containsObject:netService]) {
    [self.servicesArray addObject:netService];
  }
  
  
	if (self.serverService == nil)
	{
		NSLog(@"Resolving...");
		
		self.serverService = netService;
		
		[self.serverService setDelegate:self];
		[self.serverService resolveWithTimeout:5.0];
	}
  
  [self.tableView reloadData];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
  if ([self.servicesArray containsObject:netService]) {
    [self.servicesArray removeObject:netService];
  }
  [self.tableView reloadData];
	NSLog(@"DidRemoveService: %@", [netService name]);
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)sender
{
	NSLog(@"DidStopSearch");
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	NSLog(@"DidNotResolve");
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	NSLog(@"DidResolve: %@", [sender addresses]);
	
	if (self.addressArray == nil)
	{
		self.addressArray = [[sender addresses] mutableCopy];
	}
	
	if (self.asyncSocket == nil)
	{
		self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self connectToNextAddress];
	}
}

- (void)connectToNextAddress
{
	BOOL done = NO;
	
	while (!done && ([self.addressArray count] > 0))
	{
		NSData *addr;
		
		// Note: The serverAddresses array probably contains both IPv4 and IPv6 addresses.
		// 
		// If your server is also using GCDAsyncSocket then you don't have to worry about it,
		// as the socket automatically handles both protocols for you transparently.
		
		if (YES) // Iterate forwards
		{
			addr = [self.addressArray objectAtIndex:0];
			[self.addressArray removeObjectAtIndex:0];
		}
		else // Iterate backwards
		{
			addr = [self.addressArray lastObject];
			[self.addressArray removeLastObject];
		}
		
		NSLog(@"Attempting connection to %@", addr);
		
		NSError *err = nil;
		if ([self.asyncSocket connectToAddress:addr error:&err])
		{
			done = YES;
		}
		else
		{
			NSLog(@"Unable to connect: %@", err);
		}
	}
	
	if (!done)
	{
		NSLog(@"Unable to connect to any resolved address");
	}
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"Socket:DidConnectToHost: %@ Port: %hu", host, port);
	
	connected = YES;
  [sock readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	NSLog(@"SocketDidDisconnect:WithError: %@", err);
	
	if (!connected)
	{
		[self connectToNextAddress];
	}
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSLog(@"READ STRING %@", string);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
  NSLog(@"DID WRITE THE DATA");
}

- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
  NSLog(@"WROTE PARTIAL DATA?");
}

@end
