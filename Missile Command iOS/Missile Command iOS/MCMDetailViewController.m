//
//  MCMDetailViewController.m
//  Missile Command Mobile
//
//  Created by Brian Michel on 9/29/11.
//  Copyright (c) 2011 Brian Michel. All rights reserved.
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
@synthesize buttons;
@synthesize connectingOverlay;
@synthesize client;

- (IBAction)upAction:(id)sender {
  NSData *data = [[NSString stringWithFormat:@"%i\r\n",kUpTag] dataUsingEncoding:NSUTF8StringEncoding];
  [self.client writeDataToSocket:data];
}

- (IBAction)downAction:(id)sender {
  NSData *data = [[NSString stringWithFormat:@"%i\r\n",kDownTag] dataUsingEncoding:NSUTF8StringEncoding];
  [self.client writeDataToSocket:data];
}

- (IBAction)leftAction:(id)sender {
  NSData *data = [[NSString stringWithFormat:@"%i\r\n",kLeftTag] dataUsingEncoding:NSUTF8StringEncoding];
  [self.client writeDataToSocket:data];
}

- (IBAction)rightAction:(id)sender {
  NSData *data = [[NSString stringWithFormat:@"%i\r\n",kRightTag] dataUsingEncoding:NSUTF8StringEncoding];
  [self.client writeDataToSocket:data];
}

- (IBAction)stopAction:(id)sender {
  NSData *data = [[NSString stringWithFormat:@"%i\r\n",kStopTag] dataUsingEncoding:NSUTF8StringEncoding];
  [self.client writeDataToSocket:data];
}

- (IBAction)fireAction:(id)sender {
  NSData *data = [[NSString stringWithFormat:@"%i\r\n",kFireTag] dataUsingEncoding:NSUTF8StringEncoding];
  [self.client writeDataToSocket:data];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andService:(NSNetService *)service_ {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.client = [[MissileServerClient alloc] initWithService:service_];
    [self.client setDelegate:self];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripebg.png"]];
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
  connectingOverlay = nil;
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
  self.serverLabel.text = self.client.service.name;
  
  [self.client startSession];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.client endSession];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Missile Server Client Delegate
- (void)clientDidConnectToServer {
  [UIView animateWithDuration:0.3 animations:^{
    self.connectingOverlay.alpha = 0.0f;
  }];
}

- (void)client:(MissileServerClient *)client didDisconnectFromSocket:(GCDAsyncSocket *)socket withError:(NSError *)error {
  [UIView animateWithDuration:0.3 animations:^{
    self.connectingOverlay.alpha = 0.5f;
  }];
}

@end
