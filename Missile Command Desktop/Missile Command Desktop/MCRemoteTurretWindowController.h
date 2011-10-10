//
//  MCRemoteTurretWindowController.h
//  Missile Command Desktop
//
//  Created by Brian Michel on 10/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MCRemoteTurretWindowController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource, NSNetServiceBrowserDelegate> {
  NSMutableArray *servicesArray;
}


@property (strong) IBOutlet NSTableView *tableView;
@property (strong) NSMutableArray *servicesArray;
@property (strong) NSNetServiceBrowser *serviceBrowser;
@end
