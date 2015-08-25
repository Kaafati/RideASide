//
//  CAProfileAndRatingViewController.m
//  RoadTrip
//
//  Created by Srishti Innovative on 31/12/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CAProfileAndRatingViewController.h"
#import "CARateViewController.h"
#import "CARatingTableViewCell.h"
#import "CAUser.h"
#import "MFSideMenu.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "DYRateView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "CAReviewTripsTableViewController.h"
@interface CAProfileAndRatingViewController ()<updateUserDetails,UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *tableArray;
    IBOutlet UIButton *profileImage;
    NSArray *profileDetails;
    CAUser *userDetails;
    IBOutlet UIView *userProfileView;
    IBOutlet UITableView *tabelViewRating;
    NSNumber *average;
    IBOutlet UIButton *buttonMutualFriends;
    IBOutlet UILabel *labelAge;
    IBOutlet UILabel *labelGender;
    IBOutlet UILabel *labelEducation;
    IBOutlet UILabel *labelWork;
    IBOutlet UILabel *labelFaceBookWarning;
    IBOutlet UIView *viewHeader;
    IBOutlet UILabel *labelMutualFriends;
}
@property(nonatomic,strong) IBOutletCollection(UITextField) NSArray *textFieldProfileDetails;
@end

@implementation CAProfileAndRatingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUi];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buttonMutualFriendsPressed:(UIButton *)sender {
}

#pragma mark - Side Menu BarButton

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
- (IBAction)callUser:(UIButton *)sender {

    UITextField *mobile = (UITextField *)_textFieldProfileDetails[2];
    
    if (!mobile.secureTextEntry) {
        NSURL *phoneurl=[NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@",userDetails.phoneNumber]];
        if ([[UIApplication sharedApplication]canOpenURL:phoneurl]) {
            [[UIApplication sharedApplication]openURL:phoneurl];
        }
    }


}

#pragma mark - UIBarButtonItem Callbacks

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

#pragma mark - Initial UISetup
-(void)setUpUi{
    
   
  //  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
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
        if (idx==2) {
            UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 22)];
            [textField setLeftViewMode:UITextFieldViewModeAlways];
            [textField setLeftView:paddingView];
            [textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
            
            return ;
        }
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
    [self fetchUserProfileDetails];
    [self fetchUserRatingDetails];
}
-(void)loginWithFaceBookForMutualFriends
{
    FBSDKAccessToken *access = [FBSDKAccessToken currentAccessToken];
    if (access!=nil)
    {
        NSDictionary *params = @{
                                 @"fields": @"context.fields(mutual_friends),birthday,gender,education,work",
                                 };
        //  /* make the API call */
        
        
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                      initWithGraphPath:userDetails.facebook_id
                                      parameters:params
                                      HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                              id result,
                                              NSError *error) {
            NSLog(@"result %@",result);
            labelEducation.text = [NSString stringWithFormat:@"Education : %@ %@",[result[@"education"] lastObject][@"school"][@"name"],[result[@"education"] lastObject][@"type"]];
            labelAge.text = [NSString stringWithFormat:@"DOB : %@",result[@"birthday"]] ;
            labelGender.text = [NSString stringWithFormat:@"Gender : %@",result[@"gender"]];
            labelWork.text  = [NSString stringWithFormat:@"Work : %@ in %@",[result valueForKeyPath:@"work.position.name"][0],[result valueForKeyPath:@"work.employer.name"][0]];
            [labelMutualFriends setText:[NSString stringWithFormat:@"%@ Mutual friends", [[result valueForKeyPath:@"context.mutual_friends"] valueForKeyPath:@"summary.total_count"]]];

            
             [SVProgressHUD dismiss];
            if (!error) {
                NSDictionary *params2 = @{
                                          @"fields": @"gender,birthday,education,work,picture.width(100).height(100)",
                                          };
                FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                              initWithGraphPath: [[[result valueForKeyPath:@"context.mutual_friends"] valueForKeyPath:@"data.id"] objectAtIndex:0]
                                              parameters:params2
                                              HTTPMethod:@"GET"];
                [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                      id result,
                                                      NSError *error) {
                    if (!error) {
                        //Here need to show the mutual friend profile pic details
                        [SVProgressHUD showSuccessWithStatus:@"Success"];
                        [SVProgressHUD dismiss];
                        NSLog(@"result %@",result);
                          [buttonMutualFriends sd_setBackgroundImageWithURL:[NSURL URLWithString:result[@"picture"][@"data"][@"url"]] forState:UIControlStateNormal];
                    }
                    
                    
                    // Handle the result
                }];

            }
            
            
            // Handle the result
        }];
    }
    else
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[@"public_profile", @"email",@"user_friends",@"user_about_me",@"user_work_history",@"user_birthday",@"user_education_history"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
         {
             
             [SVProgressHUD showSuccessWithStatus:@"Success"];
             [SVProgressHUD dismiss];
             if (error)
             {
                 // Process error
             }
             else if (result.isCancelled)
             {
                 // Handle cancellations
             }
             else
             {
                 
                 
                 
                 
                 NSDictionary *params = @{
                                          @"fields": @"context.fields(mutual_friends),birthday,gender,education,work",
                                          };
                 //  /* make the API call */
                 
                 
                 FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                               initWithGraphPath:userDetails.facebook_id
                                               parameters:params
                                               HTTPMethod:@"GET"];
                 [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                       id result,
                                                       NSError *error) {
                     NSLog(@"result %@",result);
                     
                     
                     if (!error) {
                         labelEducation.text = [NSString stringWithFormat:@"Education : %@ %@",[result[@"education"] lastObject][@"school"][@"name"],[result[@"education"] lastObject][@"type"]];
                         labelAge.text = [NSString stringWithFormat:@"DOB : %@",result[@"birthday"]] ;
                         labelGender.text = [NSString stringWithFormat:@"Gender : %@",result[@"gender"]];
                         labelWork.text  = [NSString stringWithFormat:@"Work : %@ in %@",[result valueForKeyPath:@"work.position.name"][0],[result valueForKeyPath:@"work.employer.name"][0]];
                          [labelMutualFriends setText:[NSString stringWithFormat:@"%@ Mutual friends", [[result valueForKeyPath:@"context.mutual_friends"] valueForKeyPath:@"summary.total_count"]]];
                         NSDictionary *params2 = @{
                                                   @"fields": @"gender,birthday,picture.width(100).height(100)",
                                                   };
                         FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                                       initWithGraphPath: [[[result valueForKeyPath:@"context.mutual_friends"] valueForKeyPath:@"data.id"] objectAtIndex:0]
                                                       parameters:params2
                                                       HTTPMethod:@"GET"];
                         [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                               id result,
                                                               NSError *error) {
                             if (!error) {
                                 //Here need to show the mutual friend profile pic details
                                 [SVProgressHUD showSuccessWithStatus:@"Success"];
                                 [SVProgressHUD dismiss];
                                 [buttonMutualFriends sd_setBackgroundImageWithURL:[NSURL URLWithString:result[@"picture"][@"data"][@"url"]] forState:UIControlStateNormal];
                                 [CAUser connectWithFacebookWithUserId:[CAUser sharedUser].userId andFacebookId:[FBSDKAccessToken currentAccessToken].userID WithCompletionBlock:^(BOOL success, NSError *error) {
                                     
                                 }];
                                 NSLog(@"result %@",result);
                             }
                             
                             
                             // Handle the result
                         }];
                         
                     }
                     
                     
                     // Handle the result
                 }];
             }
         }];
        
    }

}

#pragma mark-Parsing
-(void)fetchUserProfileDetails{
    CAUser *user=[[CAUser alloc]init];
    [user fetchProfileDetailsWithUserId:_userId WithCompletionBlock:^(BOOL success, id result, NSError *error) {
       
        CAUser *user_Detail=(CAUser *)result[0];
        [self setUserDetails:user_Detail];
        userDetails.facebook_id.length ? [self loginWithFaceBookForMutualFriends] :  ({
             [SVProgressHUD dismiss];
            buttonMutualFriends.hidden = YES;
            labelMutualFriends.hidden = YES;
            labelAge.hidden = YES;
            labelGender.hidden = YES;
            labelWork.hidden = YES;
            labelEducation.hidden = YES;
            labelFaceBookWarning.hidden = NO;
            labelFaceBookWarning.text = [NSString stringWithFormat:@"%@ is not connected in facebook",userDetails.userName];
            
        });

    }];
    
}

-(void)fetchUserRatingDetails{
    tableArray=[NSMutableArray new];
    CAUser *user=[[CAUser alloc]init];
    [tableArray removeAllObjects];
    [user fetchRatingAndReviewWithUserId:_userId WithCompletionBlock:^(BOOL success, id result, NSError *error) {
        NSArray *arrayDataList=(NSArray *)result;
        if (success) {
            [arrayDataList enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
                [tableArray addObject:obj];
                [self calculateAndSetAvgRating];
                [tabelViewRating reloadData];
            }];
        }
    }];
}

-(void)setUserDetails:(CAUser *)user{
    userDetails=user;
    [_textFieldProfileDetails[0] setText:user.userName];
    [_textFieldProfileDetails[1] setText:user.emailId];
    [_textFieldProfileDetails[2] setSecureTextEntry: user.visibility.integerValue == 1 ?  YES: NO];
    [_textFieldProfileDetails[2] setText:user.phoneNumber];
    [profileImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,user.profile_ImageName]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
}

-(void)calculateAndSetAvgRating{
    
    NSMutableArray *myArray = [NSMutableArray array];
    NSString *ratingValue;
    
    for (int value=0; value < tableArray.count; value++) {
        ratingValue = tableArray[value][@"rating"];
        [myArray addObject:[NSNumber numberWithInt:ratingValue.intValue]];
    }
    average = [myArray valueForKeyPath:@"@avg.self"];
    
    if(![_userId isEqualToString:[CAUser sharedUser].userId]){
        DYRateView *rateView= [[DYRateView alloc] initWithFrame:CGRectMake(0, 280, self.view.bounds.size.width, 40)];
        rateView.rate = [average integerValue];
        rateView.alignment = RateViewAlignmentCenter;
        [userProfileView addSubview:rateView];
    }
    
}


#pragma mark-Rate Page
-(void)goToRateUserPage{
    CARateViewController *rateViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"rateView"];
    [rateViewController setUserId:_userId];
    [rateViewController setDelegate:self];
    [self.navigationController pushViewController:rateViewController animated:YES];
}

#pragma mark-delegate
-(void)updateUserDetails{
    [self fetchUserRatingDetails];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return tableArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CARatingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ratingCell"];

    cell.img_profilePic.layer.cornerRadius = 25.0f;
    cell.img_profilePic.clipsToBounds=YES;
    [cell.img_profilePic sd_setBackgroundImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,tableArray[indexPath.row][@"image"]]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
  //  [cell.img_profilePic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,tableArray[indexPath.row][@"image"]]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.labelName.text = tableArray[indexPath.row][@"Name"];
    cell.labelReview.text = tableArray[indexPath.row][@"review"];
    
    
    DYRateView *rateView= [[DYRateView alloc] initWithFrame:CGRectMake(80, 42, self.view.bounds.size.width, 40)];
    rateView.rate =[tableArray[indexPath.row][@"rating"] integerValue];
    rateView.alignment = RateViewAlignmentLeft;
    [cell.contentView addSubview:rateView];
    
    
    return cell;
}
- (IBAction)buttonViewReview:(UIButton *)sender
{
    CAReviewTripsTableViewController *review = [self.storyboard instantiateViewControllerWithIdentifier:@"CAReviewTripsTableViewController"];
    review.userId  = self.userId;
    review.userName = self.userName;
    [self.navigationController pushViewController:review animated:YES];
}

@end
