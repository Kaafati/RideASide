//
//  CAContacts.m
//  RoadTrip
//
//  Created by Srishti Innovative on 12/06/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import "CAContacts.h"

@implementation CAContacts
//+ (NSArray *)getContacts {
//    
//    CFErrorRef *error = nil;
//    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
//    
//    ABRecordRef source = ABAddressBookCopyArrayOfAllPeople(addressBook);
//    CFArrayRef allPeople = (ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName));
//    //CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
//    CFIndex nPeople = CFArrayGetCount(allPeople); // bugfix who synced contacts with facebook
//    NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];
//    
//    if (!allPeople || !nPeople) {
//        NSLog(@"people nil");
//    }
//    
//    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
//    NSCharacterSet *characterset = [NSCharacterSet characterSetWithCharactersInString:@"() -,"];
//    for (int i = 0; i < nPeople; i++)
//    {
//        
//        @autoreleasepool {
//            
//            //data model
//            CAContacts *contacts = [CAContacts new];
//            
//            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
//            
//            //get First Name
//            CFStringRef firstName = (CFStringRef)ABRecordCopyValue(person,kABPersonFirstNameProperty);
//            contacts.firstName = [(__bridge NSString*)firstName copy];
//            
//            if (firstName != NULL) {
//                CFRelease(firstName);
//            }
//            
//            
//            //get Last Name
//            CFStringRef lastName = (CFStringRef)ABRecordCopyValue(person,kABPersonLastNameProperty);
//            contacts.lastName = [(__bridge NSString*)lastName copy];
//            
//            if (lastName != NULL) {
//                CFRelease(lastName);
//            }
//            
//            
//            if (!contacts.firstName) {
//                contacts.firstName = @"";
//            }
//            
//            if (!contacts.lastName) {
//                contacts.lastName = @"";
//            }
//            
//            
//            
//          //  contacts.contactId = ABRecordGetRecordID(person);
//            //append first name and last name
//          //  contacts.fullname = [NSString stringWithFormat:@"%@ %@", contacts.firstNames, contacts.lastNames];
//            
//            
//            // get contacts picture, if pic doesn't exists, show standart one
//            CFDataRef imgData = ABPersonCopyImageData(person);
//            NSData *imageData = (__bridge NSData *)imgData;
//        //    contacts.image = [UIImage imageWithData:imageData];
//            
//            if (imgData != NULL) {
//                CFRelease(imgData);
//            }
//            
////            if (!contacts.image) {
////                contacts.image = [UIImage imageNamed:@"avatar.png"];
////            }
////            
//            
//            //get Phone Numbers
//            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
//            
//            for(CFIndex i=0; i<ABMultiValueGetCount(multiPhones); i++) {
//                @autoreleasepool {
//                    CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
//                    NSString *phoneNumber = CFBridgingRelease(phoneNumberRef);
//                    [contacts setPhoneNumber:[[phoneNumber componentsSeparatedByCharactersInSet:characterset] componentsJoinedByString:@""]];
//
//                    if (phoneNumber != nil)[phoneNumbers addObject:[[phoneNumber componentsSeparatedByCharactersInSet:characterset] componentsJoinedByString:@""]];
//                    //NSLog(@"All numbers %@", phoneNumbers);
//                }
//            }
//            
//            if (multiPhones != NULL) {
//                CFRelease(multiPhones);
//            }
//            
//            
//            //get Contact email
//            NSMutableArray *contactEmails = [NSMutableArray new];
//            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
//            
//            for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
//                @autoreleasepool {
//                    CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
//                    NSString *contactEmail = CFBridgingRelease(contactEmailRef);
//                    if (contactEmail != nil)[contactEmails addObject:contactEmail];
//                    // NSLog(@"All emails are:%@", contactEmails);
//                }
//            }
//            
//            if (multiPhones != NULL) {
//                CFRelease(multiEmails);
//            }
//            
//           // [contacts setEmails:contactEmails];
//            
//            [items addObject:contacts];
//            
//#ifdef DEBUG
//            //NSLog(@"Person is: %@", contacts.firstNames);
//            //NSLog(@"Phones are: %@", contacts.numbers);
//            //NSLog(@"Email is:%@", contacts.emails);
//#endif
//            
//        }
//        
//        
//        
//    } //autoreleasepool
//    CFRelease(allPeople);
//    CFRelease(addressBook);
//    CFRelease(source);
//    return items;
//    
//}
+(NSArray*)getcontact{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    
    __block BOOL accessGranted = NO;
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
      //  dispatch_release(semaphore);
    }
    
    else { // We are on iOS 5 or Older
        accessGranted = YES;
        [[self getContactsWithAddressBook:addressBook] mutableCopy];
    }
    
    if (accessGranted) {
     return  [[self getContactsWithAddressBook:addressBook] mutableCopy];
    }
    else return  [[self getContactsWithAddressBook:addressBook] mutableCopy];
}

// Get the contacts.
+ (NSMutableArray *)getContactsWithAddressBook:(ABAddressBookRef )addressBook {
    
   NSMutableArray * contactList = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < nPeople;i++) {
      //  NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
         CAContacts *contacts = [CAContacts new];
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        contacts.firstName = (__bridge NSString *)(firstName);
        contacts.lastName =(__bridge NSString *)(lastName);
      //  [dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
      
        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if(ABMultiValueGetCount(eMail) > 0) {
          //  [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
            
        }
        
        //For phone Number
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
         NSCharacterSet *character = [NSCharacterSet characterSetWithCharactersInString:@"() -,"];
        if (ABMultiValueGetCount(phones) > 0) {
            contacts.phoneNumber = [[(__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, 0) componentsSeparatedByCharactersInSet:character] componentsJoinedByString:@""];
            
//            [dOfPerson setObject:[[(__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, 0) componentsSeparatedByCharactersInSet:character] componentsJoinedByString:@""] forKey:@"Phone"];
        }
      //  NSLog(@"phone %@",[(__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, 0) componentsSeparatedByCharactersInSet:character]);
      /*
        //For Phone number
        NSString* mobileLabel;
        
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, j);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"Phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"Phone"];
                break ;
            }
            
        }
       */
        [contactList addObject:contacts];
        
    }
    NSLog(@"Contacts = %@",contactList);
    return contactList;
}
@end;