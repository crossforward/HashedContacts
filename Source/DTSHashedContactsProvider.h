//
//  DTSHashedContacts.h
//  DTSHashedContacts
//
//  Created by David Smith on 2/15/12.
//  Copyright (c) 2012 Cross Forward Consulting, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DTSConfirmationBlock)(NSArray* tokens);
typedef void (^DTSDeclinedBlock)(void);

typedef enum _DTSHashMethod {
	DTSHashWithSHA1 = 0,
	DTSHashWithSHA512 = 1,
} DTSHashMethod;


@interface DTSHashedContactsProvider : NSObject <UIAlertViewDelegate>

//Request tokens for contact fields.  A Confirmation will show asking the user for permission
-(void)emailTokensWithConfirmation:(DTSConfirmationBlock)confirmed whenDeclined:(DTSDeclinedBlock)declined;
-(void)phoneNumberTokensWithConfirmation:(DTSConfirmationBlock)confirmed whenDeclined:(DTSDeclinedBlock)declined;

//Tokenize the given string using the current hashing setup
-(NSString*)tokenForString:(NSString*)string;

//The user will be prompted to give permission before access to addressbook is granted
-(void)setConfirmationAlertTitle:(NSString*)title;
-(void)setConfirmationAlertMessage:(NSString*)message;
-(BOOL)userHasGivenPermission;
-(void)resetConfirmationAlerts;

//Choose an option from DTSHashMethod to use for hashing
@property DTSHashMethod hashingMethod;

@end
