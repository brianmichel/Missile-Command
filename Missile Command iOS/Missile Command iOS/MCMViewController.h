//
//  MCMViewController.h
//  Missile Command iOS
//
//  Created by Brian Michel on 9/29/11.
//  Copyright (c) 2011 Brian Michel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface MCMViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate,NSNetServiceBrowserDelegate, NSNetServiceDelegate, GCDAsyncSocketDelegate> {
  BOOL connected;
}

@property (strong) NSMutableArray *addressArray;
@property (strong) NSMutableArray *servicesArray;
@property (strong) NSNetService *serverService;
@property (strong) NSNetServiceBrowser *serviceBrowser;
@property (strong) GCDAsyncSocket *asyncSocket;

- (void)connectToNextAddress;

@end
