//
//  CCSearchLocationViewController.h
//  ConnecxxionCarsCustomer
//
//  Created by Srishti on 11/09/14.
//  Copyright (c) 2014 chitra. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol searchLocationDelegate <NSObject>

-(void)searchLocationWithAddress:(NSDictionary*)address withTextFieldTag:(NSUInteger)textFieldTag;
@end

@interface CASearchLocationViewController : UIViewController
@property(nonatomic,assign)NSUInteger textFieldTag;
@property(nonatomic,retain)id <searchLocationDelegate>  delegates;
@property(nonatomic,strong)NSString *addressName;
@end
