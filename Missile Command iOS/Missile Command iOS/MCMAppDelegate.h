//
//  MCMAppDelegate.h
//  Missile Command iOS
//
//  Created by Brian Michel on 9/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCMViewController;

@interface MCMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MCMViewController *viewController;

@end
