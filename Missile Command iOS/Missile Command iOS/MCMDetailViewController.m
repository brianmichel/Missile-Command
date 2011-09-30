//
//  MCMDetailViewController.m
//  Missile Command Mobile
//
//  Created by Brian Michel on 9/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MCMDetailViewController.h"

#define kUpTag 1
#define kDownTag 2
#define kLeftTag 3
#define kRightTag 4
#define kFireTag 5
#define kStopTag 6

@implementation MCMDetailViewController
@synthesize serverLabel;
@synthesize upButton;
@synthesize downButton;
@synthesize leftButton;
@synthesize rightButton;
@synthesize stopButton;
@synthesize fireButton;
@synthesize service;
@synthesize addressArray;
@synthesize asyncSocket;
@synthesize buttons;

- (IBAction)upAction:(id)sender {
  NSData *data = [[NSString stringWithFormat:@"%i\r\n",kUpTag] dataUsingEncoding:NSUTF8StringEncoding];
  [self.asyncSocket writeData:data withTimeout:-1 tag:kUpTag];
}

- (IBAction)downAction:(id)sender {
  NSData *data = [[NSString stringWithFormat:@"%i\r\n",kDownTag] dataUsingEncoding:NSUTF8StringEncoding];
  [self.asyncSocket writeData:data withTimeout:-1 tag:kDownTag];
}

- (IBAction)leftAction:(id)sender {
  NSData *data = [[NSString stringWithFormat:@"%i\r\n",kLeftTag] dataUsingEncoding:NSUTF8StringEncoding];
  [self.asyncSocket writeData:data withTimeout:-1 tag:kLeftTag];
}

- (IBAction)rightAction:(id)sender {
  NSData *data = [[NSString stringWithFormat:@"%i\r\n",kRightTag] dataUsingEncoding:NSUTF8StringEncoding];
  [self.asyncSocket writeData:data withTimeout:-1 tag:kRightTag];
}

- (IBAction)stopAction:(id)sender {
  NSData *data = [[NSString stringWithFormat:@"%i\r\n",kStopTag] dataUsingEncoding:NSUTF8StringEncoding];
  [self.asyncSocket writeData:data withTimeout:-1 tag:kStopTag];
}

- (IBAction)fireAction:(id)sender {
  NSData *data = [[NSString stringWithFormat:@"%i\r\n",kFireTag] dataUsingEncoding:NSUTF8StringEncoding];
  [self.asyncSocket writeData:data withTimeout:-1 tag:kFireTag];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andService:(NSNetService *)service_ {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.service = service_;
    self.serverLabel.text = self.service.name;
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
  [self setServerLabel:nil];
  [self setUpButton:nil];
  [self setDownButton:nil];
  [self setLeftButton:nil];
  [self setRightButton:nil];
  [self setStopButton:nil];
  [self setFireButton:nil];
  [self setButtons:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}
  
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  for (UIButton *button in self.buttons) {
    [button setEnabled:NO];
  }
  
  self.title = @"Controls";
  self.serverLabel.text = self.service.name;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    for (UIButton *button in self.buttons) {
      [button setEnabled:YES];
    }
	}
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
  NSLog(@"Wrote the data!");
}

- (void)dealloc {
  [serverLabel release];
  [upButton release];
  [downAction release];
  [leftButton release];
  [rightButton release];
  [stopButton release];
  [fireButton release];
  [super dealloc];
}

@end
