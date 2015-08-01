//
//  CAContacts.h
//  RoadTrip
//
//  Created by Srishti Innovative on 12/06/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AddressBook;
@import AddressBookUI;
@interface CAContacts : NSObject
@property (nonatomic,strong) NSString *firstName;
@property (nonatomic,strong) NSString *lastName;
@property (nonatomic,strong) NSString *phoneNumber;
@property (nonatomic,strong) UIImage *image;
@property BOOL isContactSelected;
//+(NSArray *)getContacts;
+(NSMutableArray *)getcontact;
@end
