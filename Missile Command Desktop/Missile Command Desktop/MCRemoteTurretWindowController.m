//
//  MCRemoteTurretWindowController.m
//  Missile Command Desktop
//
//  Created by Brian Michel on 10/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MCRemoteTurretWindowController.h"
#import "MCRemoteTurretCellView.h"

@implementation MCRemoteTurretWindowController

@synthesize tableView = __tableView;
@synthesize servicesArray = __servicesArray;
@synthesize serviceBrowser = __serviceBrowser;

- (id)initWithWindow:(NSWindow *)window
{
  self = [super initWithWindow:window];
  if (self) {
    // Initialization code here.
    self.servicesArray = [NSMutableArray array];
    
    self.serviceBrowser = [NSNetServiceBrowser new];
    self.serviceBrowser.delegate = self;
  }
  
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
  [self.serviceBrowser searchForServicesOfType:@"_missilecommand._tcp." inDomain:@"local."];
}

- (NSString *)windowNibName {
  return @"RemoteTurretWindow";
}

#pragma mark - Table View Delegate Methods
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
  NSString *identifier = [tableColumn identifier];
  
  if ([identifier isEqualToString:@"TurretCell"]) {
    // We pass us as the owner so we can setup target/actions into this main controller object
    MCRemoteTurretCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
    // Then setup properties on the cellView based on the column
    if ([self.servicesArray count] == 0) {
      cellView.textField.stringValue = @"No Turrets Found";
      [cellView.fireImage setHidden:YES];
      [cellView.videoImage setHidden:YES];
    } else {
      NSNetService *service = [self.servicesArray objectAtIndex:row];
      cellView.textField.stringValue = service.name;
      [cellView.fireImage setHidden:NO];
      [cellView.videoImage setHidden:NO];
    }

    return cellView;
  } else {
    NSAssert1(NO, @"Unhandled table column identifier %@", identifier);
  }
  return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [self.servicesArray count] == 0 ? 1 : [self.servicesArray count];
}

#pragma mark - NSNetServiceBrowser Delegate
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)aService moreComing:(BOOL)more {
  NSLog(@"FUCK %@", aService.name);
  if (![self.servicesArray containsObject:aService]) {
    [self.servicesArray addObject:aService];
  }
  
  [self.tableView reloadData];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more {
  NSLog(@"FUCK212");
  if ([self.servicesArray containsObject:aService]) {
    [self.servicesArray removeObject:aService];
  }
  [self.tableView reloadData];
}

@end
