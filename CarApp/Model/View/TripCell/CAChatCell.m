//
//  CAChatCell.m
//  SampleChat
//
//  Created by Aswin on 01/06/14.
//  Copyright (c) 2014 Aswin. All rights reserved.
//

#import "CAChatCell.h"

static CGFloat textMarginHorizontal = 17.5f;
static CGFloat textMarginVertical = 12.5f;
static CGFloat messageTextSize = 17.0f;

@interface CAChatCell ()<UIGestureRecognizerDelegate>

@end

@implementation CAChatCell

#pragma mark - Static methods
+ (CGFloat)textMarginHorizontal {
    return textMarginHorizontal;
}

+ (CGFloat)textMarginVertical {
    return textMarginVertical;
}

+ (CGFloat)maxTextWidth {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 195.0f : 600.0f;
}

+ (CGSize)messageSize:(NSString *)message withFont:(UIFont *)font withWidth:(CGFloat)width {
    return [message boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, nil] context:nil].size;
}

+ (UIImage*)balloonImage:(BOOL)sent isSelected:(BOOL)selected {
    return [[UIImage imageNamed:(sent == NO) ? @"senderBubble" : @"recieverBubble"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
}

#pragma mark Reuse
- (void)prepareForReuse {
    [_messageAttachedImage setImage:nil];
}

#pragma mark Initialization
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideEditMenu:) name:UIMenuControllerWillHideMenuNotification object:nil];
        /*Initializing view-lements*/
        _messageView = [[UIView alloc] initWithFrame:CGRectZero];
        _balloonView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _messageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        /*Set Image*/
        _personImageView = [self setImageView];
        _messageAttachedImage = [self setImageView];
        [_messageAttachedImage setUserInteractionEnabled:YES];
        [_messageAttachedImage setHidden:YES];
        /*Message & Time-Label*/
        _messageLabel = [self setLabelWithFontSize:[UIFont fontWithName:@"HelveticaNeue-Light" size:messageTextSize]];
        _messageLabel.textAlignment = NSTextAlignmentJustified;
        _messageStatusLabel = [self setLabelWithFontSize:[UIFont boldSystemFontOfSize:12.0f]];
        [_messageStatusLabel setTextColor:[UIColor lightGrayColor]];
        /*View Hierarchy*/
        [_messageView addSubview: _balloonView];
        [_messageView addSubview: _messageLabel];
        [self.contentView addSubview: _messageView];
        [self.contentView addSubview: _personImageView];
        [self.contentView addSubview: _messageAttachedImage];
        [self.contentView addSubview: _messageStatusLabel];
        /*Add Gestures*/
        [self setGestures];
    }
    return self;
}

- (UIImageView *)setImageView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setClipsToBounds:YES];
    CALayer *imageLayer = imageView.layer;
    [imageLayer setCornerRadius:25.0];
    [imageLayer setBorderColor:[[UIColor colorWithRed:207.0/255.0 green:234.0/255.0 blue:251.0/255.0 alpha:1.0]CGColor]];
    [imageLayer setMasksToBounds:YES];
    return imageView;
}

- (UILabel *)setLabelWithFontSize:(UIFont *)font {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = font;
    [label setNumberOfLines:0];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

- (void)setGestures {
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [recognizer setMinimumPressDuration:1.0f];
    [_messageView addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer *tapGesture= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setUpTapGestureToShowPicture:)];
    [tapGesture setNumberOfTouchesRequired:1];
    [tapGesture setNumberOfTapsRequired:1];
    [_messageAttachedImage addGestureRecognizer:tapGesture];
    [tapGesture setDelegate:self];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - Layouting

- (void)layoutSubviews {
    [super layoutSubviews];

    CGSize statusSize = [CAChatCell messageSize:_messageStatusLabel.text withFont:_messageStatusLabel.font withWidth:([CAChatCell maxTextWidth] + (2 * textMarginHorizontal))];
    CGSize textSize = [CAChatCell messageSize:_messageLabel.text withFont:_messageLabel.font withWidth:[CAChatCell maxTextWidth]];
    
    _personImageView.frame = CGRectMake(_isSent ? (CGRectGetMinX(self.bounds) + 5.0f) : (CGRectGetMaxX(self.bounds) - 55.0f), CGRectGetMinY(self.bounds) + 5.0f, 50.0f, 50.0f);
    
    _messageView.frame = CGRectMake(_isSent ? (CGRectGetMaxX(_personImageView.frame) + 5.0f) : (CGRectGetMinX(_personImageView.frame) - (5.0f + (2 * textMarginHorizontal) + textSize.width)), CGRectGetMinY(_personImageView.frame), (2 * textMarginHorizontal) + textSize.width, (2 * textMarginVertical) + textSize.height);
    
    _balloonView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(_messageView.frame), CGRectGetHeight(_messageView.frame));
   // NSLog(@"Baloon View %@",NSStringFromCGRect(_balloonView.frame));
    _messageLabel.frame = CGRectMake(textMarginHorizontal, textMarginVertical, textSize.width, textSize.height);
    _messageStatusLabel.frame = CGRectMake(_isSent ? CGRectGetMinX(_messageView.frame) : (CGRectGetMaxX(_messageView.frame) - statusSize.width), CGRectGetMaxY(_messageView.frame) + 5.0f, statusSize.width, statusSize.height);
    _messageAttachedImage.frame = CGRectMake(_isSent ? CGRectGetMinX(_messageStatusLabel.frame) : (CGRectGetMaxX(_messageView.frame) - 110.0), CGRectGetMaxY(_messageStatusLabel.frame) + 5.0f, 110.0, 110.0);
    _balloonView.image = [CAChatCell balloonImage:_isSent isSelected:self.selected];

}

#pragma mark SetMessage
- (void)setMessage:(CAMessage *)message
{
    _messageLabel.text = message.messageText;
    _personImageView.image = [UIImage imageNamed:@"PersonPlaceHolder"];
    
    [_messageAttachedImage setHidden:!message.messageImage];
  //  [_messageAttachedImage setImage:message.messageImage];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    _messageStatusLabel.text = [NSString stringWithFormat:@"Delivered %@",[dateFormatter stringFromDate:message.messageTime]];
}

#pragma mark - UIGestureRecognizer-Handling
#pragma mark TapImage
- (void)setUpTapGestureToShowPicture:(UITapGestureRecognizer *)gestureRecognizer {
    [_cellDelegate didTapImage:((UIImageView *)gestureRecognizer.view).image];
}
 
#pragma mark TapMenu
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer {
    /*When a LongPress is recognized, the copy-menu will be displayed.*/
    if (longPressRecognizer.state != UIGestureRecognizerStateBegan || [self becomeFirstResponder] == NO)
        return;
    
    [[UIMenuController sharedMenuController] setTargetRect:_messageView.frame inView:self];
    UIMenuItem *forwardItem = [[UIMenuItem alloc] initWithTitle:@"Do Custom Function" action:@selector(customAction:)];
    [[UIMenuController sharedMenuController] setMenuItems:@[forwardItem]];
    [_messageLabel setBackgroundColor: _isSent ? [UIColor colorWithRed:1.0/255.0 green:178.0/255.0 blue:255.0/255.0 alpha:1.0f] : [UIColor colorWithRed:136.0/255.0 green:101.0/255.0 blue:59.0/255.0 alpha:1.0f]];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}

#pragma mark MenuActions
- (BOOL)canBecomeFirstResponder {
    /*This cell can become first-responder*/
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    BOOL result = NO;
    result = (@selector(copy:) == action || @selector(customAction:) == action) ? YES : NO;
    return result;
}

- (void)copy:(id)sender {
    /**Copys the messageString to the clipboard.*/
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:_messageLabel.text];
}

- (void)customAction:(id)sender {
    NSLog(@"Custom Action");
}

- (void)willHideEditMenu:(id)sender {
    [_messageLabel setBackgroundColor:[UIColor clearColor]];
}
@end