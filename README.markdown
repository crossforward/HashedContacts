# Hashed Contacts

HashedContacts is a drop-in iOS library that provides a wrapper around the AddressBook framework designed to ensure the privacy of user data.  It does this in two ways:

1. Before access is ever made to the Address Book the user will first be prompted for permission
1. Once access is granted the library returns hashed tokens representing the user's private data rather than the data itself.

These two steps do much to establish user trust with how you treat their data.

## Installation

- Drag the `HashedContacts/Source` folder into your project.
- Add the `AddressBook.framework` to your project.
- `#import "DTSHashedContactsProvider.h"`

## ARC

HashedContacts works with Xcode 4.4+ and ARC. Supports iOS 4.0 and above.

## Usage
(see sample Xcode project)

``` objective-c
__block DTSHashedContactsProvider *hashedContactsProvider = [[DTSHashedContactsProvider alloc] init];
[hashedContactsProvider setHashSalt:@"Super Secret Salt"];
[hashedContactsProvider setHashingMethod:DTSHashWithSHA512];
[hashedContactsProvider emailTokensWithConfirmation:^(NSArray *tokens) {
    NSLog(@"Email Tokens: %@", tokens);
    hashedContactsProvider = nil;
} whenDeclined:^{
    NSLog(@"Access was denied");
    hashedContactsProvider = nil;
}];
```

### Hashed Tokens of Phone Numbers
``` objective-c
__block DTSHashedContactsProvider *hashedContactsProvider = [[DTSHashedContactsProvider alloc] init];
[hashedContactsProvider setHashSalt:@"The quick brown fox jumps over the lazy dog."];
[hashedContactsProvider setHashingMethod:DTSHashWithSHA256];
[hashedContactsProvider phoneNumberTokensWithConfirmation:^(NSArray *tokens) {
    NSLog(@"Phone Number Tokens: %@", tokens);
    hashedContactsProvider = nil;
} whenDeclined:^{
    NSLog(@"Access was denied");
    hashedContactsProvider = nil;
}];
```

### Custom alert message and title
``` objective-c
__block DTSHashedContactsProvider *hashedContactsProvider = [[DTSHashedContactsProvider alloc] init];
[hashedContactsProvider setHashSalt:@"Salt"];
[hashedContactsProvider setHashingMethod:DTSHashWithSHA1];
[hashedContactsProvider setAlertTitle:@"¡Atención"];
[hashedContactsProvider setAlertMessage:@"HashedContacts le gustaría tener acceso a su información de contacto."];
[hashedContactsProvider emailTokensWithConfirmation:^(NSArray *tokens) {
    NSLog(@"Email Tokens: %@", tokens);
    hashedContactsProvider = nil;
} whenDeclined:^{
    NSLog(@"Access was denied");
    hashedContactsProvider = nil;
}];
```

### Supported Hashing Methods
- `SHA1`
- `SHA256`
- `SHA512`


## License

HashedContacts is available under the MIT license. See the LICENSE file for more information.