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

@interface CAProfileTableViewController ()<updateUserDetails>{
    
    IBOutlet UIButton *profileImage;
    NSArray *profileDetails;
    IBOutlet UILabel *labelReview;
    IBOutlet UITableViewCell *cellForReviewDetails,*cellForStarView;
    CAUser *userDetails;
}
@property(nonatomic,strong) IBOutletCollection(UITextField) NSArray *textFieldProfileDetails;
@end

@implementation CAProfileTableViewController

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
    [self setUpUi];
    [self setupMenuBarButtonItems];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
            initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)backBarButtonItem {
    
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStyleBordered
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

-(void)setUpUi{
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    NSArray *images=@[@"username",@"emailId",@"mobile"];
    cellForReviewDetails.hidden=YES;
    
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
    [SVProgressHUD showWithStatus:@"Fetching user details..." maskType:SVProgressHUDMaskTypeBlack];
    [self fetchProfileDetails];
    
}

#pragma mark-Parsing
-(void)fetchProfileDetails{
    CAUser *user=[[CAUser alloc]init];
    [user fetchProfileDetailsWithUserId:_userId WithCompletionBlock:^(BOOL success, id result, NSError *error) {
        [SVProgressHUD dismiss];
        CAUser *user_Detail=(CAUser *)result[0];
        [self setUserDetails:user_Detail];
    }];
    
}
-(void)setUserDetails:(CAUser *)user{
    userDetails=user;
    [_textFieldProfileDetails[0] setText:user.userName];
    [_textFieldProfileDetails[1] setText:user.emailId];
    [_textFieldProfileDetails[2] setText:user.phoneNumber];
  
    
    labelReview.text=user.reviewNote;
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:user.reviewNote
     attributes:@
     {
     NSFontAttributeName:[UIFont fontWithName:@"Arial" size:12]
     }];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(250,CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize contentsize = rect.size;
    
    
   labelReview.frame = CGRectMake(labelReview.frame.origin.x, labelReview.frame.origin.y, contentsize.width, contentsize.height);
   labelReview.textAlignment=NSTextAlignmentJustified;
    labelReview.lineBreakMode = NSLineBreakByWordWrapping;
   labelReview.numberOfLines = 0;

    
    [profileImage setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,user.profile_ImageName]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    if(![_userId isEqualToString:[CAUser sharedUser].userId]){
        DYRateView *rateView= [[DYRateView alloc] initWithFrame:CGRectMake(0, 5, self.view.bounds.size.width, 40)];
        rateView.rate =user.rateValue.integerValue ;
        rateView.alignment = RateViewAlignmentCenter;
        [cellForStarView  addSubview:rateView];
        cellForReviewDetails.hidden=(userDetails.reviewNote.length>0)?NO:YES;
    }
    else
        [cellForReviewDetails setHidden:YES];
    
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if(cell.hidden)
        return 0;
    else if(cell==cellForReviewDetails){
        [labelReview setText:userDetails.reviewNote];
        UIFont *cellFont = [UIFont fontWithName:@"Arial" size:12];
        CGSize constraintSize = CGSizeMake(250, CGFLOAT_MAX);
        
        NSAttributedString *attributedText =
        [[NSAttributedString alloc]
         initWithString:userDetails.reviewNote         attributes:@
         {
         NSFontAttributeName: cellFont
         }];
        CGRect rect = [attributedText boundingRectWithSize:constraintSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        CGSize labelSize = rect.size;
        return labelSize.height+64;
        
        
        
        
    }
    else
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
}

#pragma mark-delegate
-(void)updateUserDetails{
    [self fetchProfileDetails];
}
@end
