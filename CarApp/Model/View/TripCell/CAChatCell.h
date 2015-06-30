//
//  CAChatCell.h
//  SampleChat
//
//  Created by Aswin on 01/06/14.
//  Copyright (c) 2014 Aswin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAMessage.h"

@class CAChatCell;
@protocol ChatCellDelegate <NSObject>
- (void)didTapImage:(UIImage *)messageAttachedImage;
@end

@interface CAChatCell : UITableViewCell

@property (nonatomic, readonly) UIView *messageView;
@property (nonatomic, readonly) UILabel *messageLabel;
@property (nonatomic, readonly) UILabel *messageStatusLabel;
@property (nonatomic, readonly) UIImageView *personImageView;
@property (nonatomic, readonly) UIImageView *messageAttachedImage;
@property (nonatomic, readonly) UIImageView *balloonView;
@property (assign) BOOL isSent;

@property (nonatomic, strong) CAMessage *message;

@property (nonatomic, strong) id <ChatCellDelegate> cellDelegate;

+ (CGFloat) textMarginHorizontal;
+ (CGFloat) textMarginVertical;
+ (CGFloat) maxTextWidth;
+ (CGSize)messageSize:(NSString *)message withFont:(UIFont *)font withWidth:(CGFloat)width;
+ (UIImage*)balloonImage:(BOOL)sent isSelected:(BOOL)selected;

@end
