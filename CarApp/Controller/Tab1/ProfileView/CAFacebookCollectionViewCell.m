//
//  CAFacebookCollectionViewCell.m
//  RideAside
//
//  Created by Srishti Innovative on 31/08/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import "CAFacebookCollectionViewCell.h"

@implementation CAFacebookCollectionViewCell
-(void)awakeFromNib
{
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width/2;
    self.imageView.layer.masksToBounds = YES;
    
}
@end
