//
//  DTSHashedContacts.m
//  DTSHashedContacts
//
//  Created by David Smith on 2/15/12.
//  Copyright (c) 2012 Cross Forward Consulting, LLC. All rights reserved.
//

#import "DTSHashedContactsProvider.h"
#import <AddressBook/AddressBook.h>
#import <CommonCrypto/CommonDigest.h>

#warning Update the value of DTSHashSALT to something specific to your application
#define DTSHashSALT @"CHANGE ME PLEASE"

#define DTSHashedContactsHasGivenPermission @"DTSHashedContactsHasGivenPermission"

typedef enum _DTSFieldToReturn {
    DTSEmailField = 0,
    DTSPhoneNumberField = 1,
} DTSFieldToReturn;

@interface DTSHashedContactsProvider ()

@property (copy) DTSConfirmationBlock confirmationBlock;
@property (copy) DTSDeclinedBlock declinedBlock;
@property DTSFieldToReturn contactFieldToReturn;

@end

@implementation DTSHashedContactsProvider

@synthesize confirmationBlock, declinedBlock, hashingMethod, contactFieldToReturn, alertTitle, alertMessage;

- (id)init {
    self = [super init];
    if (self) {
        //Default to SHA1
        self.hashingMethod = DTSHashWithSHA1;
        
        //Default Messaging
        self.alertTitle = NSLocalizedString(@"Allow Access to Contacts?", @"Alert title");
        NSString *appname = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        self.alertMessage = [NSString stringWithFormat:NSLocalizedString(@"%@ would like access to your contact information.", @"Alert message"), appname];
        
    }
    return self;
}

-(NSString *)createSHA512:(NSString *)string
{
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, data.length, digest);
    NSMutableString* output = [NSMutableString  stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

-(NSString *)createSHA256:(NSString *)string
{
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, data.length, digest);
    NSMutableString* output = [NSMutableString  stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

-(NSString *)createSHA1:(NSString *)string
{
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSMutableString* output = [NSMutableString  stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

-(NSString*)tokenForString:(NSString*)string {
    //The concatenation of the application hash given in DTSHashSALT and the given string is used for hashing.
    NSString* stringToHash = [NSString stringWithFormat:@"%@%@", DTSHashSALT, [string lowercaseString]];
    NSString* token = nil;
    
    switch (self.hashingMethod) {
        case DTSHashWithSHA1:
            token = [self createSHA1:stringToHash];
            break;
        case DTSHashWithSHA256:
            token = [self createSHA256:stringToHash];
            break;
        case DTSHashWithSHA512:
            token = [self createSHA512:stringToHash];
            break;
    }
    
    return token;
}

-(NSString*)cleanNumber:(NSString*)number
{
    NSCharacterSet *numbers = [[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"] invertedSet];
    return [[number componentsSeparatedByCharactersInSet:numbers] componentsJoinedByString:@""];
}

-(NSString*)cleanEmail:(NSString*)email
{
    // This cleans email+additional@provider.com to be email@provider.com
    // which is another problematic scenario..
    
    NSRange plusRange = [email rangeOfString:@"+"];
    if(plusRange.length > 0)
    {
        // found
        NSRange atRange = [email rangeOfString:@"@"];
        
        NSString * start    = [email substringToIndex:plusRange.location];
        NSString * rest     = [email substringFromIndex:atRange.location];
        email = [start stringByAppendingString:rest];
    }
    
    return email;
}

-(void)getTokens {
    //Retrieve entries on background thread so that we don't block the main one
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray* tokens = [NSMutableArray array];
        
        ABAddressBookRef addressBook = ABAddressBookCreate();
        CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        
        for( int i = 0; i < nPeople; ++i ) {
            
            ABRecordRef ref = CFArrayGetValueAtIndex(contacts,i);
            ABMultiValueRef contactRef;
            
            if(self.contactFieldToReturn == DTSEmailField) {
                contactRef = ABRecordCopyValue(ref, kABPersonEmailProperty);
            } else if(self.contactFieldToReturn == DTSPhoneNumberField) {
                contactRef = ABRecordCopyValue(ref, kABPersonPhoneProperty);
            } else {
                break;
            }
            
            CFIndex numberOfEntries = ABMultiValueGetCount(contactRef);
            CFArrayRef entries = ABMultiValueCopyArrayOfAllValues(contactRef);
            for( int j = 0; j < numberOfEntries; ++j ) {
                NSString* email = (__bridge NSString *)CFArrayGetValueAtIndex(entries, j);
                
                if(self.contactFieldToReturn == DTSEmailField) {
                    email = [self cleanEmail:email];
                } else if(self.contactFieldToReturn == DTSPhoneNumberField) {
                    email = [self cleanNumber:email];
                }
                
                NSString* hashed = [self tokenForString:email];
                [tokens addObject:hashed];
            };
            
            // clean up
            if(entries) {
                CFRelease(entries);
            }
            if(contactRef) {
                CFRelease(contactRef);
            }
        }
        
        if(contacts) {
            CFRelease(contacts);
        }
        
        //Always return data on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            self.confirmationBlock(tokens);
            self.confirmationBlock = nil;
            self.declinedBlock = nil;
        });
        
        if(addressBook) {
            CFRelease(addressBook);
        }
    });
    
}
#pragma Mark Permission Confirmation

-(void)resetConfirmationAlerts {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:DTSHashedContactsHasGivenPermission];
    [defaults synchronize];
}

-(BOOL)userHasGivenPermission {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:DTSHashedContactsHasGivenPermission];
}

-(void)askForPermission {
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:self.alertTitle
                          message:self.alertMessage
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Don’t Allow", @"Cancel button title")
                          otherButtonTitles:NSLocalizedString(@"Allow", @"Allow button title"), nil];
    [alert show];
}

#pragma Mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if(buttonIndex == 1) {
        [defaults setBool:YES forKey:DTSHashedContactsHasGivenPermission];
    } else  {
        [defaults setBool:NO forKey:DTSHashedContactsHasGivenPermission];
    }
    [defaults synchronize];
    
    
    if ([self userHasGivenPermission]) {
        [self getTokens];
    } else {
        self.declinedBlock();
        self.confirmationBlock = nil;
        self.declinedBlock = nil;
    }
}

-(void)processRequest {
    if ([self userHasGivenPermission]) {
        [self getTokens];
    } else {
        [self askForPermission];
    }
}
#pragma Mark Token Requests
-(void)phoneNumberTokensWithConfirmation:(DTSConfirmationBlock)confirmation whenDeclined:(DTSDeclinedBlock)declined {
    self.confirmationBlock = confirmation;
    self.declinedBlock = declined;
    self.contactFieldToReturn = DTSPhoneNumberField;
    [self processRequest];
}


-(void)emailTokensWithConfirmation:(DTSConfirmationBlock)confirmation whenDeclined:(DTSDeclinedBlock)declined {
    self.confirmationBlock = confirmation;
    self.declinedBlock = declined;
    self.contactFieldToReturn = DTSEmailField;
    [self processRequest];
}


@end
