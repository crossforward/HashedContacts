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
    DTSHashWithSHA256 = 1,
    DTSHashWithSHA512 = 2,
} DTSHashMethod;


@interface DTSHashedContactsProvider : NSObject <UIAlertViewDelegate>

//Request tokens for contact fields.  A Confirmation will show asking the user for permission
-(void)emailTokensWithConfirmation:(DTSConfirmationBlock)confirmed whenDeclined:(DTSDeclinedBlock)declined;
-(void)phoneNumberTokensWithConfirmation:(DTSConfirmationBlock)confirmed whenDeclined:(DTSDeclinedBlock)declined;

//Tokenize the given string using the current hashing setup
-(NSString*)tokenForString:(NSString*)string;

//The user will be prompted to give permission before access to addressbook is granted
-(BOOL)userHasGivenPermission;
-(void)resetConfirmationAlerts;

//Choose an option from DTSHashMethod to use for hashing
@property DTSHashMethod hashingMethod;
@property (strong) NSString* hashSalt;
@property (strong) NSString* alertTitle;
@property (strong) NSString* alertMessage;

@end
