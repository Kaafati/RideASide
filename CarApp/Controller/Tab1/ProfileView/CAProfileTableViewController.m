//
//  CAProfileTableViewController.m
//  RoadTrip
//
//  Created by SRISHTI INNOVATIVE on 04/10/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CAProfileTableViewController.h"
#import "CAUser.h"
#import "UIButton+WebCache.h"
#import "DYRateView.h"
#import "MFSideMenu.h"
#import "CARateViewController.h"
#import "SVProgressHUD.h"
#import "CAReviewTripsTableViewController.h"
@interface CAProfileTableViewController ()<updateUserDetails,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>{
    
    IBOutlet UIButton *profileImage;
    NSArray *profileDetails;
    IBOutlet UITableViewCell *cellForStarView;
    __weak IBOutlet UITableViewCell *cellAcceptDriver;
    IBOutletCollection(UITextField) NSArray *arrayTextFieldRating;
    NSNumber *average;
    UIPickerView *pickerViewRating;
    NSArray *arrayRatingPassengerOrDirver;
    UITextField *activeTextField;
    IBOutletCollection(UILabel) NSArray *arrayLabelRating;
    IBOutletCollection(UISegmentedControl) NSArray *arraySegmentedRating;

    IBOutletCollection(UITableViewCell) NSArray *arrayCellRating;
}
@property(nonatomic,strong) IBOutletCollection(UITextField) NSArray *textFieldProfileDetails;
@end

@implementation CAProfileTableViewController
@synthesize userDetails,trip;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    [self fetchTotalRating];
    [self setUpUi];
    [self setupMenuBarButtonItems];

    if ((userDetails.userId.integerValue == [CAUser sharedUser].userId.integerValue) || ![[trip.arrayJoinees valueForKey:@"userId"] containsObject:[CAUser sharedUser].userId]) {
        [arrayCellRating enumerateObjectsUsingBlock:^(UITableViewCell* obj, NSUInteger idx, BOOL *stop) {
            if (idx==0) {
            obj.hidden = NO;
                UILabel *label = arrayLabelRating[idx];
                label.hidden = YES;
                UITextField *textField = arrayTextFieldRating[idx];
                textField.hidden = YES;
                UIButton *buttonViewJoinees = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42)];
                [buttonViewJoinees setTitle:@"View Review" forState:UIControlStateNormal];
                [buttonViewJoinees setBackgroundColor:[UIColor colorWithRed:25/255.0 green:124/255.0 blue:204/255.0 alpha:1]];
                [buttonViewJoinees addTarget:self action:@selector(buttonViewReview:) forControlEvents:UIControlEventTouchUpInside];
                [obj.contentView addSubview:buttonViewJoinees];

            }
            else
            {
                obj.hidden = YES;
            }

            
            
        }];
        self.tableView.scrollEnabled = NO;
    }
    else
    {
        [arrayCellRating enumerateObjectsUsingBlock:^(UITableViewCell* obj, NSUInteger idx, BOOL *stop) {
            
            obj.hidden = NO;
            
        }];
      
        
//        if (![[trip.arrayJoinees valueForKey:@"userId"] containsObject:[CAUser sharedUser].userId]) {
//            self.tableView.tableFooterView.hidden = YES;
//        }
//        else
//        {
//            self.tableView.tableFooterView.hidden = NO;
//        }
        self.tableView.scrollEnabled = YES;

    }

    if ([trip.category isEqualToString:@"Passenger"]) {
        UIButton *btnAcceptDriver = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.view.frame)+CGRectGetWidth(self.view.frame)/4,CGRectGetMidY(cellAcceptDriver.frame) ,CGRectGetWidth(self.view.frame)/2, 40)];
        [btnAcceptDriver.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [btnAcceptDriver addTarget:self action:@selector(acceptDriverAction:) forControlEvents:UIControlEventTouchUpInside];
        [btnAcceptDriver setBackgroundColor:[UIColor colorWithRed:25/255.0 green:124/255.0 blue:204/255.0 alpha:1]];
        [btnAcceptDriver setTitle:@"Accept driver" forState:UIControlStateNormal];
        [cellAcceptDriver addSubview:btnAcceptDriver];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)setUpUi{
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    NSArray *images=@[@"username",@"emailId",@"mobile"];
    
    if(![_userId isEqualToString:[CAUser sharedUser].userId]){
        UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightbarbutton.frame =CGRectMake(0, 0, 80, 30) ;
        [rightbarbutton setTitle:@"Rate User" forState:UIControlStateNormal];
        [rightbarbutton addTarget:self action:@selector(goToRateUserPage) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightbarbutton];
    }
    
    [profileImage.layer setCornerRadius:50.0f];
    [profileImage setClipsToBounds:YES];
    [profileImage setUserInteractionEnabled:NO];
    
    
    [_textFieldProfileDetails enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
        textField.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"textField_bg"]];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0,18, 18)];
        [imgView setContentMode:UIViewContentModeScaleAspectFit];
        imgView.image = [UIImage imageNamed:images[idx]];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 22)];
        [paddingView addSubview:imgView];
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setLeftView:paddingView];
        [textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        
    }];
    
    //  [SVProgressHUD showWithStatus:@"Fetching user details..." maskType:SVProgressHUDMaskTypeBlack];
    [self setUserDetails:userDetails];
    
    
    pickerViewRating = [[UIPickerView alloc] init];
    pickerViewRating.delegate =self;
    [arrayTextFieldRating enumerateObjectsUsingBlock:^(UITextField * textField, NSUInteger idx, BOOL *stop) {
        textField.inputAccessoryView = [self setPickerToolBar];
        textField.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"textField_bg"]];
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 22)];
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setLeftView:paddingView];
    }];
    NSArray *arrayRatings1 = [userDetails.category isEqualToString:@"passenger"] ?  @[@"Was the passenger respectful?",@"Was it difficult to set up the trip with the passenger?",@"Did you have any Problems with receiving your payment from the passenger?",@"How was your RideAside experience with this Passenger?"] : @[@"Was the driver Respectful?",@"Was the Driver a Safe Driver?",@"Does the driver speed?",@"How was your RideAside experience with the Driver?"] ;
    
    arrayRatingPassengerOrDirver = [userDetails.category isEqualToString:@"passenger"] ? @[@[@"Always",@"For the most part",@"A Little Bit", @"Not at all"],@[@"Yes" ,@"No"],@[@"Not at all" ,@"A little difficult" ,@"Difficult", @"Very difficult"],@[@"Amazing" ,@"We had a good time" ,@"It was Okay" ,@"Not so good" ,@"Terrible"]]
                        :
    @[@[@"Always" ,@"Most of the time", @"Not really" ,@"Not at all"],@[@"Always" ,@"Most of the time" ,@"Sometimes" ,@"Not really" ,@"Not at all"],@[@"Yes" ,@"sometimes" ,@"No"],@[@"Amazing" ,@"We had a good time" ,@"It was Okay" ,@"Not so good" ,@"Terrible"]];
    
    [arrayLabelRating enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        label.text = arrayRatings1[idx];
    }];
    
    
        
    

    // [self fetchProfileDetails];
    
    
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    activeTextField.text = [arrayRatingPassengerOrDirver[activeTextField.tag] objectAtIndex:row];
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [arrayRatingPassengerOrDirver[activeTextField.tag] count];
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [arrayRatingPassengerOrDirver[activeTextField.tag] objectAtIndex:row];
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeTextField = textField;
    [pickerViewRating reloadAllComponents];
    textField.inputView = pickerViewRating;
    return YES;
}
-(UIToolbar *)setPickerToolBar{
    UIToolbar *toolBar = [[UIToolbar alloc]init];
    [toolBar sizeToFit];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
    [toolBar setItems:@[flexSpace,doneButton]];
    return toolBar;
}

-(void)doneButtonAction:(UIBarButtonItem *)sender{
    [self.view endEditing:YES];
}
- (IBAction)buttonSubmitReview:(UIButton *)sender {
    
    [arrayTextFieldRating enumerateObjectsUsingBlock:^(UITextField * textField, NSUInteger idx, BOOL *stop) {
        
        if (!textField.text.length) {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Please fill all the field" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            *stop = YES;

        }
        else if(idx == arrayTextFieldRating.count-1)
        {
            [self submitReview];
        }
        
    }];
    
}
- (IBAction)buttonViewReview:(UIButton *)sender
{
    CAReviewTripsTableViewController *review = [self.storyboard instantiateViewControllerWithIdentifier:@"CAReviewTripsTableViewController"];
        review.userId  = self.userDetails.userId;
        review.userName  = self.userDetails.userName;
    
    [self.navigationController pushViewController:review animated:YES];
}
-(void)submitReview
{
    [SVProgressHUD show];
    [CATrip submitReviewWithRatedUserId:userDetails.userId withtripId:trip.tripId answer:[[arrayTextFieldRating valueForKey:@"text"] componentsJoinedByString:@","] completion:^(BOOL success, id result, NSError *error) {
        if (success) {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Success" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        }
    [SVProgressHUD dismiss];
    }];
}
- (void)setupMenuBarButtonItems {
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)backBarButtonItem {
    
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(backButtonPressed:)];
}

#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

-(void)acceptDriverAction:(UIButton *)sender{

    [CATrip selectDriverForTrip:trip completion:^(BOOL success, NSError *error) {
        if (success) {
            [[[UIAlertView alloc]initWithTitle:@"Message" message:@"You have successfully added this driver" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]show];
        }
     }];
    
}


#pragma mark-Parsing
-(void)fetchProfileDetails{
    CAUser *user=[[CAUser alloc]init];
    [user fetchProfileDetailsWithUserId:_userId WithCompletionBlock:^(BOOL success, id result, NSError *error) {
        [SVProgressHUD dismiss];
        CAUser *user_Detail=(CAUser *)result[0];
        //[self calculateAndSetAvgRating];
        [self setUserDetails:user_Detail];
    }];
    
}

-(void)fetchTotalRating{
    [CAUser fetchUsersTotalRatingCountWithCompletion:^(bool success, id result, NSError *error) {
        if (success) {
            NSString *strCount = result;
            strCount ? [self calculateAndSetAvgRating:strCount] : nil;

        }
    }];
}

-(void)updateRatingCount:(NSString *)rateValue{
    
    if(![_userId isEqualToString:[CAUser sharedUser].userId]){
        DYRateView *rateView= [[DYRateView alloc] initWithFrame:CGRectMake(0, 5, self.view.bounds.size.width, 40)];
        rateView.rate = rateValue.integerValue;
        rateView.alignment = RateViewAlignmentCenter;
        rateView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        [cellForStarView  addSubview:rateView];
    }
    else
    {
        
    }
}

-(void)calculateAndSetAvgRating:(NSString *)rateValue{
    NSMutableArray *myArray = [NSMutableArray new];
    [myArray addObject:[NSNumber numberWithInt:rateValue.intValue]];
   
    average = [myArray valueForKeyPath:@"@avg.self"];
    
    if(![_userId isEqualToString:[CAUser sharedUser].userId]){
        DYRateView *rateView= [[DYRateView alloc] initWithFrame:CGRectMake(0, 5, self.view.bounds.size.width, 40)];
        rateView.rate = [average integerValue];
        rateView.alignment = RateViewAlignmentCenter;
        [cellForStarView addSubview:rateView];
    }
    [self.tableView reloadData];
}
- (IBAction)callUser:(UIButton *)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[[_textFieldProfileDetails objectAtIndex:2] textLabel] text]]];
}

-(void)setUserDetails:(CAUser *)user{
    userDetails=user;
    [_textFieldProfileDetails[0] setText:user.userName];
    [_textFieldProfileDetails[1] setText:user.emailId];
    [_textFieldProfileDetails[2] setText:user.phoneNumber];
    [profileImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,user.profile_ImageName]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];

//    labelReview.text=user.reviewNote;
//    NSAttributedString *attributedText =
//    [[NSAttributedString alloc]
//     initWithString:user.reviewNote
//     attributes:@
//     {
//     NSFontAttributeName:[UIFont fontWithName:@"Arial" size:12]
//     }];
//    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(250,CGFLOAT_MAX)
//                                               options:NSStringDrawingUsesLineFragmentOrigin
//                                               context:nil];
//    CGSize contentsize = rect.size;
//    
//    
//   labelReview.frame = CGRectMake(labelReview.frame.origin.x, labelReview.frame.origin.y, contentsize.width, contentsize.height);
//   labelReview.textAlignment=NSTextAlignmentJustified;
//    labelReview.lineBreakMode = NSLineBreakByWordWrapping;
//   labelReview.numberOfLines = 0;

      ////////////////////////////////////////////////////////////
//    if(![_userId isEqualToString:[CAUser sharedUser].userId]){
//        DYRateView *rateView= [[DYRateView alloc] initWithFrame:CGRectMake(0, 5, self.view.bounds.size.width, 40)];
//        rateView.rate =user.rateValue.integerValue;
//        rateView.alignment = RateViewAlignmentCenter;
//        [cellForStarView  addSubview:rateView];
//    }
//    else
//    {
//        
//    }
    ////////////////////////////////////////////////////////////

    [self.tableView reloadData];
}

#pragma mark-Rate Page
-(void)goToRateUserPage{
    CARateViewController *rateViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"rateView"];
    [rateViewController setUserId:_userId];
    [rateViewController setDelegate:self];
    [self.navigationController pushViewController:rateViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
//    if(cell.hidden)
//        return 0;
//    else if(cell==cellForReviewDetails){
//        [labelReview setText:userDetails.reviewNote];
//        UIFont *cellFont = [UIFont fontWithName:@"Arial" size:12];
//        CGSize constraintSize = CGSizeMake(250, CGFLOAT_MAX);
//        
//        NSAttributedString *attributedText =
//        [[NSAttributedString alloc]
//         initWithString:userDetails.reviewNote         attributes:@
//         {
//         NSFontAttributeName: cellFont
//         }];
//        CGRect rect = [attributedText boundingRectWithSize:constraintSize
//                                                   options:NSStringDrawingUsesLineFragmentOrigin
//                                                   context:nil];
//        CGSize labelSize = rect.size;
//        return labelSize.height+64;
//    }
//    else
//        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
//}


#pragma mark-delegate
-(void)updateUserDetails{
    [self fetchProfileDetails];
    [self fetchTotalRating];
}


@end
