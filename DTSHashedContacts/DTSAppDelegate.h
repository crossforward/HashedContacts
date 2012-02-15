//
//  DTSAppDelegate.h
//  DTSHashedContacts
//
//  Created by David Smith on 2/15/12.
//  Copyright (c) 2012 Cross Forward Consulting, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTSViewController;

@interface DTSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DTSViewController *viewController;

@end
