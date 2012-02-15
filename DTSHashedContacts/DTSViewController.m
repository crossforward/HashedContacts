//
//  DTSViewController.m
//  DTSHashedContacts
//
//  Created by David Smith on 2/15/12.
//  Copyright (c) 2012 Cross Forward Consulting, LLC. All rights reserved.
//

#import "DTSViewController.h"

@implementation DTSViewController

@synthesize allTokensView, hashedContactsProvider;

-(void)viewDidLoad {
    self.hashedContactsProvider = [[DTSHashedContactsProvider alloc] init];
    self.hashedContactsProvider.hashingMethod = DTSHashWithSHA512;
}

-(IBAction)requestEmailTokens:(id)sender {
    [self.hashedContactsProvider
     emailTokensWithConfirmation:^(NSArray* tokens) {
         
         if([tokens count] > 0) {
             allTokensView.text = [tokens componentsJoinedByString:@"\n\n"];
         } else {
             allTokensView.text = @"No Contacts";
         }
         
     } whenDeclined:^{
         allTokensView.text = @"Declined";
     }];
}
-(IBAction)requestPhoneNumberTokens:(id)sender {
    [self.hashedContactsProvider
     phoneNumberTokensWithConfirmation:^(NSArray* tokens) {
         
         if([tokens count] > 0) {
             allTokensView.text = [tokens componentsJoinedByString:@"\n\n"];
         } else {
             allTokensView.text = @"No Contacts";
         }
         
     } whenDeclined:^{
         allTokensView.text = @"Declined";
     }];
}


-(IBAction)resetConfirmation:(id)sender {
    [self.hashedContactsProvider resetConfirmationAlerts];
}

@end
