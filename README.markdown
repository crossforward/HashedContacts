## Hashed Contacts

Hashed Contacts is a drop-in iOS library that provides a wrapper around the Address Book frameworks designed to ensure the privacy of user data.  It does this in two ways:

1. Before access is ever made to the Address Book the user will first be prompted for permission
1. Once access is granted the library returns hashed tokens representing the user's private data rather than the data itself.

These two steps do much to establish user trust with how you treat their data.

## Installation

Copy the two files `DTSHashedContactsProvider.h` & `DTSHashedContactsProvider.m` into your project from `Source` directory.

Add the `AddressBook.framework` to your project.

__Supports iOS 4.0 and above__

Replace the value of `DTSHashSALT` in `DTSHashedContactsProvider.m` and remove the warning.

## Usage

See a full working example of how this library can be used by opening the included in this repository.

To use the library simply initialize an instance of the `DTSHashedContactsProvider` class.  _Note:_ You will need to retain a reference to this instance until you are done loading the user's data.

You may configure this in three ways:

1. Choose the hashing method used via the `hashingMethod` property.  Options are SHA1 and SHA512
1. Specify the alert title via the `alertTitle` property
1. Specify the alert message via the `alertMessage` property

A default value for the alert is provided based on the application display name.

![](https://github.com/crossforward/HashedContacts/raw/master/alert_example.png)

Once that is done simply call the desired retrieval method to get your tokens.

    [hashedContactsProvider emailTokensWithConfirmation:^(NSArray* tokens) {
    //When permission given
    } whenDeclined:^{
    //When permission denied
    }];

The result provided in `tokens` will look like this:

`[@"eca7cf4a5981108abb6e2b9754c96b62e6c241db",@"a927a7e701521fd46b89db0162a05c1159cbd2aa"]`
