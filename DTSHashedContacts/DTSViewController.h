//
//  DTSViewController.h
//  DTSHashedContacts
//
//  Created by David Smith on 2/15/12.
//  Copyright (c) 2012 Cross Forward Consulting, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTSHashedContactsProvider.h"

@interface DTSViewController : UIViewController

@property (strong) IBOutlet UITextView* allTokensView;

@property (strong) DTSHashedContactsProvider* hashedContactsProvider;

-(IBAction)requestEmailTokens:(id)sender;
-(IBAction)requestPhoneNumberTokens:(id)sender;
-(IBAction)resetConfirmation:(id)sender;

@end
