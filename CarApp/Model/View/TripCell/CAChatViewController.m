//
//  CAChatViewController.m
//  SampleChat
//
//  Created by Aswin on 01/06/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "CAChatViewController.h"
#import "CAChatCell.h"
#import "HPGrowingTextView.h"
#import "CAMessage.h"
#import "CAUser.h"
#define kDefaultComposerHeight 40.0

@interface CAChatViewController ()<UITableViewDataSource, UITableViewDelegate, ChatCellDelegate, HPGrowingTextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate, UIGestureRecognizerDelegate>

@end

@implementation CAChatViewController
{
    __weak IBOutlet UITableView *tableChat;
    HPGrowingTextView *messageTextView;
    UIImageView *messageImage;
    UIRefreshControl *refreshControl;
    UIView *containerView;
    int indexCount;
    UIButton *messageImageButton;
    UIButton *sendButton;
    NSTimer *timer;
    UIProgressView *progressView;
    BOOL isLoaded;
    NSMutableArray *arrayChat;
}

- (void)loadView
{
    [super loadView];
    indexCount = 0;
    containerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinY(self.view.frame), CGRectGetHeight(self.view.frame) - kDefaultComposerHeight, CGRectGetWidth(self.view.frame), kDefaultComposerHeight)];
    [containerView setTintColor:[UIColor blackColor]];
    self.title = @"Chat" ;
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkForNewChat) userInfo:nil repeats:YES];
    
    refreshControl = [[UIRefreshControl alloc]init];
   
    [refreshControl addTarget:self action:@selector(refreshMessage) forControlEvents:UIControlEventValueChanged];
    messageTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake( CGRectGetMinX(containerView.frame) + 36.0, 6.0, CGRectGetWidth(containerView.frame) - 69.0, 34.0)];
    messageTextView.isScrollable = NO;
    messageTextView.contentInset = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0);
	messageTextView.minNumberOfLines = 1;
	messageTextView.maxNumberOfLines = 6;
	messageTextView.font = [UIFont systemFontOfSize:15.0f];
	messageTextView.delegate = self;
    messageTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0);
    messageTextView.backgroundColor = [UIColor clearColor];
    messageTextView.placeholder = @"Enter message here";
    messageTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    messageTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13.0 topCapHeight:22.0];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(CGRectGetMinX(containerView.frame) + 34.0, 0.0, CGRectGetWidth(containerView.frame) - 67.0 , kDefaultComposerHeight);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13.0 topCapHeight:22.0];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(containerView.frame), CGRectGetHeight(containerView.frame));
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
	sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	sendButton.frame = CGRectMake(CGRectGetWidth(containerView.frame) - 33.0, 8.0, 27.0, 27.0);
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [sendButton setImage:[UIImage imageNamed:@"SendButton"] forState:UIControlStateNormal];
    
    messageImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	messageImageButton.frame = CGRectMake(CGRectGetMinX(containerView.frame) + 4.0, 12.0, 27.0, 22.0);
    messageImageButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[messageImageButton addTarget:self action:@selector(addPhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [messageImageButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [messageImageButton setImage:[UIImage imageNamed:@"CameraIcon"] forState:UIControlStateNormal];
    
    messageImage = [[UIImageView alloc] init];
    [messageImage setFrame:CGRectMake(CGRectGetMinX(containerView.frame) + 11.0 + CGRectGetWidth(messageImageButton.frame), 9.0, 22.0, 22.0)];
    [messageImage setContentMode:UIViewContentModeScaleAspectFit];
	[messageImage setHidden:YES];
    
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    //View Hierarchy
    [containerView addSubview:imageView];
    [containerView addSubview:entryImageView];
    [containerView addSubview:sendButton];
    [containerView addSubview:messageImageButton];
    [containerView addSubview:messageImage];
    [containerView addSubview:messageTextView];
    [self.view addSubview:containerView];
    [self.view bringSubviewToFront:containerView];
     [tableChat addSubview:refreshControl];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    arrayChat = [NSMutableArray new];
    [self setUI];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    /* Listen for keyboard */
   	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	/* No longer listen for keyboard */
    [timer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Chat
-(void)listMessageWithIndex:(int)index
{
    [SVProgressHUD show];

    [CAMessage listTheChatWithtripId:_tripId index:indexCount completion:^(BOOL success, id result, NSError *error) {
        if (success) {
            isLoaded = YES;
            if (arrayChat.count) {
                [arrayChat removeAllObjects];
            }
            [arrayChat addObjectsFromArray:result];
            [tableChat reloadData];

        }
        
        [refreshControl endRefreshing];
        [SVProgressHUD dismiss];
    }];
}
-(void)refreshMessage
{
    
    indexCount = indexCount + 10;
    [self listMessageWithIndex:indexCount];
    
    
        
   
}
-(void)insertChatWithMessageId:(CAMessage *)message
{
    [CAMessage insertChatWIthSenderId:message.sender_id tripId:_tripId chatMessage:message.messageText completion:^(BOOL success , id result , NSError *error) {
        
        if (success && !isLoaded) {
            [self listMessageWithIndex:0];
        }
    }];

}
-(void)checkForNewChat
{
    CAMessage *message = (CAMessage *)arrayChat.lastObject;
  
    if (![message.chat_id isEqualToString:@"new"]) {
        
        [CAMessage checkForNewChatWithTripId:_tripId chatId:message.chat_id completion:^(BOOL success, id result, NSError *error) {
          
            if (success == true) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chat_id == %@",@"new"];
                NSArray *array = [arrayChat filteredArrayUsingPredicate:predicate];
                if (array.count) {
                    [arrayChat removeObjectsInArray:array];
                    [arrayChat addObjectsFromArray:result];
                }
                else
                {
                    [arrayChat addObjectsFromArray:result];
                }
                
                [tableChat reloadData];
            }
            
        }];
    }
    
}
#pragma mark SetUI
- (void)setUI
{
    progressView = [[UIProgressView alloc] init];
    [progressView setProgress:0.0];
    [progressView setProgressViewStyle:UIProgressViewStyleBar];
    [self listMessageWithIndex:indexCount];
}

#pragma mark ButtonActions
-(void)addPhotoButtonAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose Photo", nil];
    [actionSheet showInView:self.view];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
}

- (void)sendButtonAction:(id)sender
{
    if ([messageTextView.text length] == 0 && messageImage.image == nil) return;
    
    [self.view insertSubview:progressView aboveSubview:containerView];
    [self.view bringSubviewToFront:progressView];
    progressView.progress = 0.1;
    CAMessage *message = [CAMessage new];
    message.messageText = messageTextView.text;
    message.messageImage = messageImage ? messageImage.image : nil;
    message.messageTime = [NSDate date];
    message.sender_id = [CAUser sharedUser].userId;
    [sendButton setEnabled:NO];
    [messageTextView resignFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^{ progressView.progress = 1.0; } completion:^(BOOL finished) { [self addMessage:message]; }];
    
}

- (void)addMessage:(CAMessage *)newMessage
{
    newMessage.chat_id = @"new";
    [arrayChat addObject:newMessage];
    [tableChat reloadData];
    [progressView removeFromSuperview];
    [self insertChatWithMessageId:newMessage];
        [sendButton setEnabled:YES];
    [messageTextView setText:nil];
    [messageImage setImage:nil];
    [messageImage setHidden:YES];
    [messageTextView setFrame:CGRectMake(CGRectGetMinX(containerView.frame) + 36.0, 6.0, CGRectGetWidth(containerView.frame) - 69.0, 34.0)];
    [tableChat setFrame:CGRectMake(CGRectGetMinX(self.view.bounds), CGRectGetMinY(self.view.bounds) + 20.0f, CGRectGetWidth(self.view.bounds), (CGRectGetMinY(containerView.frame) - 3.0))];
    [self tableScrollToBottom];

}

#pragma mark TableScroll
- (void)tableScrollToBottom
{
    
    [tableChat scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(arrayChat.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
   
}

#pragma mark ChatCellDelegate
- (void)didTapImage:(UIImage *)messageAttachedImage
{
    UIView *contentView = [[UIView alloc] initWithFrame:self.view.frame];
    [contentView setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0.75]];
    if (messageAttachedImage)
    {
        UIImageView *imageViewModal = [[UIImageView alloc] initWithFrame:contentView.frame];
        [imageViewModal setContentMode:UIViewContentModeScaleAspectFit];
        
        [imageViewModal setImage:messageAttachedImage];
        [contentView addSubview:imageViewModal];
        [UIView transitionWithView:self.view duration:0.50 options:UIViewAnimationOptionTransitionNone animations:^ { [self.view addSubview:contentView]; } completion:nil];
        
        [self.view bringSubviewToFront:imageViewModal];
        UITapGestureRecognizer *tapGesture= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setUpTapGesture:)];
        [tapGesture setNumberOfTouchesRequired:1];
        [tapGesture setNumberOfTapsRequired:1];
        [contentView addGestureRecognizer:tapGesture];
        [tapGesture setDelegate:self];
    }
}

#pragma mark TapGesture
- (void)setUpTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    [UIView transitionWithView:self.view duration:0.50 options:UIViewAnimationOptionTransitionNone animations:^ { [gestureRecognizer.view removeFromSuperview];}
                    completion:^(BOOL finished) {
                    }];
}
#pragma mark - TableView
#pragma mark TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayChat.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *labelHeader = [UILabel new];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    [labelHeader setText:[NSString stringWithFormat:@"---------------%@---------------" ,[dateFormatter stringFromDate:[NSDate date]]]];
    [labelHeader setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]];
    [labelHeader setTextAlignment:NSTextAlignmentCenter];
    [labelHeader setTextColor:[UIColor lightGrayColor]];
    [labelHeader setBackgroundColor:[UIColor clearColor]];
    [labelHeader setFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 20.0)];
    return labelHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellIdentifier";
    CAChatCell *chatCell = (CAChatCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (!chatCell)
    {
        chatCell = [[CAChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [chatCell setCellDelegate:self];
    }
    
    [self configureCell:chatCell atIndexPath:indexPath];
    return chatCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float margin = (15.0 + (2 * 12.5f));
    CAMessage *message = (CAMessage *)arrayChat[indexPath.row];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSString *messageTime = [NSString stringWithFormat:@"Delivered %@",[dateFormatter stringFromDate:message.messageTime]];
    float totalTextHeight = [CAChatCell messageSize:message.messageText withFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f] withWidth:[CAChatCell maxTextWidth]].height + [CAChatCell messageSize:messageTime withFont:[UIFont boldSystemFontOfSize:12.0f] withWidth:([CAChatCell maxTextWidth] + (2 * 17.5f))].height;
    float imageHeight = message.messageTime ? 115.0f : 0.0f;
    float totalCalculatedHeight = margin + totalTextHeight ;// + imageHeight;
    
    return totalCalculatedHeight > 70.0f  ? totalCalculatedHeight : 70.0f;
}

-(void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath
{
    CAChatCell* chatCell = (CAChatCell*)cell;
    CAMessage *message = arrayChat[indexPath.row];
    chatCell.isSent = [message.sender_id isEqualToString:[CAUser sharedUser].userId] ? YES : NO ;
    [chatCell.messageStatusLabel setTextAlignment:chatCell.isSent ? NSTextAlignmentLeft : NSTextAlignmentRight];
    [chatCell.messageLabel setTextColor:chatCell.isSent ? [UIColor blueColor] : [UIColor brownColor]];
    [chatCell setMessage:(CAMessage *)arrayChat[indexPath.row]];
}


#pragma mark ActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker=[[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    switch (buttonIndex)
    {
        case 0:
        {
            if (![UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceRear])
                [[[UIAlertView alloc] initWithTitle: @"No Camera Available" message: @"This Feature requires camera." delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
            else{
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
            break;
        case 1:
        {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}


#pragma mark ImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [messageImage setImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    [messageImage setHidden:NO];
    CGRect frame = messageTextView.frame;
    [messageTextView setFrame:CGRectMake(CGRectGetMinX(containerView.frame) + 58.0, 3.0, CGRectGetWidth(containerView.frame) - 91.0, CGRectGetHeight(frame))];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark HPGrowingTextView Delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (CGRectGetHeight(growingTextView.frame) - height);
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
}

#pragma mark KeyboardNotifications
-(void) keyboardWillShow:(NSNotification *)note
{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = CGRectGetHeight(self.view.bounds) - (CGRectGetHeight(keyboardBounds) + CGRectGetHeight(containerFrame)) + 50;
    
    [UIView animateWithDuration:[[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] - 0.01 delay:0.0 options:[[note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue] animations:^{
        containerView.frame = containerFrame;
        [progressView setFrame:CGRectMake(0.0, CGRectGetMinY(containerView.frame) - 3.0, CGRectGetWidth(self.view.frame), 3.0)];
        [tableChat setFrame:CGRectMake(CGRectGetMinX(self.view.bounds), CGRectGetMinY(self.view.bounds) + 50.0f, CGRectGetWidth(self.view.bounds), CGRectGetMinY(progressView.frame)-50)];
    } completion:nil];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(containerFrame);
    
    [UIView animateWithDuration:[[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue] delay:0.0 options:[[note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue] animations:^{
        containerView.frame = containerFrame;
        [progressView setFrame:CGRectMake(0.0, CGRectGetMinY(containerView.frame) - 3.0, CGRectGetWidth(self.view.frame), 3.0)];
        [tableChat setFrame:CGRectMake(CGRectGetMinX(self.view.bounds), CGRectGetMinY(self.view.bounds) + 20.0f, CGRectGetWidth(self.view.bounds), CGRectGetMinY(progressView.bounds))];
    } completion:nil];
}

@end