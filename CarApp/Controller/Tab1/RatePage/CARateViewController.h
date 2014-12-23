//
//  CARateViewController.h
//  RoadTrip
//
//  Created by Bala on 30/10/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol updateUserDetails <NSObject>
-(void)updateUserDetails;
@end

@interface CARateViewController : UIViewController
@property(nonatomic,strong)NSString *userId;
@property(nonatomic,weak)id<updateUserDetails>delegate;
@end
