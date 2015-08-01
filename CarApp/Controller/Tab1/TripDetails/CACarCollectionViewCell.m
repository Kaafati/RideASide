//
//  CACarCollectionViewCell.m
//  RoadTrip
//
//  Created by Srishti Innovative on 21/07/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import "CACarCollectionViewCell.h"

@implementation CACarCollectionViewCell
- (void)awakeFromNib
{
    self.buttonCar.layer.cornerRadius = self.buttonCar.frame.size.width / 2;
    self.buttonCar.clipsToBounds = YES;
    [self.buttonCar.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.buttonCar.layer setBorderWidth:2];
    
    

    // Initialization code
}

@end
