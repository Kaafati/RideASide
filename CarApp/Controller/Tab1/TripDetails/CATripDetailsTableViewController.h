//
//  CATripDetailsTableViewController.h
//  RoadTrip
//
//  Created by SICS on 21/08/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CATrip.h"
@protocol acceprOrRejectTripDelegate <NSObject>
-(void)actionAfterAcceptOrRejectTripwithIndexPathOfRowSelected:(NSIndexPath *)indexPath;
@end

@interface CATripDetailsTableViewController : UITableViewController
@property(nonatomic,strong)CATrip *trip;
@property(nonatomic,assign)BOOL isFromRequestPage;
@property(nonatomic,strong)NSIndexPath *indexPathOfRowSelected;
@property (weak, nonatomic)id<acceprOrRejectTripDelegate>delegate;
@end
