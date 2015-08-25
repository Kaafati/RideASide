//
//  CAReviewCell.m
//  RideAside
//
//  Created by Srishti Innovative on 18/08/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import "CAReviewCell.h"

@implementation CAReviewCell
@synthesize arrayLabelReview,arrayTextFieldReview;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setReview:(CAReview *)messages
{
    [arrayLabelReview enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        label.text = [messages valueForKey: [NSString stringWithFormat:@"reviewQuestion%d",idx+1]];
    }];
    [arrayTextFieldReview enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
        textField.userInteractionEnabled = NO;
        
        textField.text = [NSString stringWithFormat:@" %@",[messages valueForKey: [NSString stringWithFormat:@"reviewAnswer%d",idx+1 ]]]; ;
        
    }];
   
}

@end
