//
//  CASignInViewController.m
//  RoadTrip
//
//  Created by SICS on 16/08/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CASignUpViewController.h"
#import "CAUser.h"
#import "CAServiceManager.h"
#import "MFSideMenu.h"
#import "UIButton+WebCache.h"
#import "UIImage+Utilities.h"
#import "CAAppDelegate.h"
#import "CALoginViewController.h"
#import "KGModal.h"
#import "TPKeyboardAvoidingScrollView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "CAFacebookPicturesCollectionViewController.h"
#import "CAProtocol.h"
typedef NS_ENUM(NSInteger, ButtonSelection) {
    buttonCar1,
    buttonCar2,
    buttonCar3,
    profileButton
};

@interface CASignUpViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate, UITextViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIAlertViewDelegate,CAProtocolFacebookPicture>
{
    IBOutlet UIButton *buttonConnectWithFacebook;
    IBOutlet TPKeyboardAvoidingScrollView *scrollViewCar;
    IBOutletCollection(UITextField) NSArray *textFieldSignUp;
    UITextField *textFiledActive;
    IBOutlet UIButton *signUpButton;
    IBOutlet UIButton *profileImage;
    IBOutlet UITextView *textViewAboutMe;
    __weak IBOutlet UITableViewCell *cellCategory;
    __weak IBOutlet UITableViewCell *cellTMC;
    NSArray *category,*smokeStatus;
    __weak IBOutlet UIButton *btnTermsAndCondition;
    IBOutlet UIView *viewCar;
    IBOutletCollection(UIButton) NSArray *arrayButtonCar;
    IBOutletCollection (UITextField) NSArray *arrayTextFieldCarName;
    IBOutletCollection (UITextField) NSArray  *arrayTextFieldCarLicence;
    ButtonSelection carSelection;
    NSMutableDictionary * arrayCarDetails;
    BOOL isHaveCorrectSelection;
    IBOutlet UIButton *buttonSubmitCarDetails;
    UILabel *labelVisible;
     UIPickerView *pickerViewVehicle ;
    NSArray *arraycarMakes,*arraycarModels;
    NSString *stringCarMakes,*stringCarModels;
    UITextField *activeTextField;
    BOOL isFromFacebookProfilePicture;
}

@end

@implementation CASignUpViewController

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
    arrayCarDetails = [NSMutableDictionary new];
    [scrollViewCar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]] atIndex:0];

    [self pickerUI];
    [self setUpUi];
    [CAUser sharedUser].userId.length>0 ? [self hideTermsAndConditionCell]:[self addAttributedText];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [buttonConnectWithFacebook setTitle:[FBSDKAccessToken currentAccessToken] ? @"Connected With Facebook" : @"Connect With Facebook" forState:UIControlStateNormal];
}
-(void)pickerUI
{
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Cars" ofType:@"plist"]];
    arraycarMakes  = [[[dict valueForKey:@"CarMakes"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    arraycarModels =    [dict valueForKeyPath:[NSString stringWithFormat:@"CarMakes.%@",arraycarMakes[0]]];
    
    
    pickerViewVehicle  = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    pickerViewVehicle.delegate = self;
    
    UILabel *labelCarMakes = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, self.view.frame.size.width/2, 30)];
    labelCarMakes.text =@"Car Makes";
    labelCarMakes.textAlignment = NSTextAlignmentCenter;
    [pickerViewVehicle addSubview:labelCarMakes];
    UILabel *labelCarModels = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(labelCarMakes.frame)+5, 15, self.view.frame.size.width/2, 30)];
    labelCarModels.text =@"Car Models";
    labelCarModels.textAlignment = NSTextAlignmentCenter;
    [pickerViewVehicle addSubview:labelCarModels];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSLog(@"%@",[FBSDKAccessToken currentAccessToken]);
    
}

-(void)hideTermsAndConditionCell{
    [cellTMC setHidden:YES];
}
- (IBAction)buttonConnectWithFaceBook:(UIButton *)sender {
    [SVProgressHUD show];
    FBSDKAccessToken *access = [FBSDKAccessToken currentAccessToken];
    if (access!=nil)
    {
        
        [CAUser connectWithFacebookWithUserId:[CAUser sharedUser].userId andFacebookId:access.userID WithCompletionBlock:^(BOOL success, NSError *error) {
            
        }];
        NSDictionary *params = @{
                                 @"fields": @"context.fields(mutual_friends),birthday,gender,education,work,albums,name,picture.width(100).height(100)",
                                 };
        //  /* make the API call */
        
        
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                      initWithGraphPath:@"me"
                                      parameters:params
                                      HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                              id result,
                                              NSError *error) {
            NSLog(@"result %@",result);
            NSArray *filtered = [[result valueForKeyPath:@"albums.data"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", @"Profile Pictures"]];
            
            
            
            NSDictionary *params2 = @{
                                     @"fields": @"gender,birthday",
                                     };
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                          initWithGraphPath: [[[result valueForKeyPath:@"context.mutual_friends"] valueForKeyPath:@"data.id"] objectAtIndex:0]
                                          parameters:params2
                                          HTTPMethod:@"GET"];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                  id result,
                                                  NSError *error) {
                [SVProgressHUD showSuccessWithStatus:@"Success"];
                [SVProgressHUD dismiss];
                NSLog(@"result %@",result);
                [buttonConnectWithFacebook setTitle:[FBSDKAccessToken currentAccessToken] ? @"Connected With Facebook" : @"Connect With Facebook" forState:UIControlStateNormal];
                
                
                FBSDKGraphRequest *requestFacebookAlbum = [[FBSDKGraphRequest alloc] initWithGraphPath:[filtered valueForKey:@"id"][0] parameters:@{@"fields":@"photos{picture.width(200).height(200)}"} HTTPMethod:@"GET"];
                
                [requestFacebookAlbum startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    
                    NSArray *arrayFaceBookProfilePictures = [result valueForKeyPath:@"photos.data.picture"];
                    [CAUser sharedUser].arrayFacebookProfilePicture = arrayFaceBookProfilePictures;

                    isFromFacebookProfilePicture ? (
                                                    {
                                                        CAFacebookPicturesCollectionViewController *facebookPictureViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CAFacebookPicturesCollectionViewController"];
                                                        facebookPictureViewController.arrayProfilePictures = [CAUser sharedUser].arrayFacebookProfilePicture;
                                                        facebookPictureViewController.delegateFacebookProfilePicture = (id<CAProtocolFacebookPicture>)self;
                                                        [self.navigationController pushViewController:facebookPictureViewController animated:YES];
                                                    }
                                                    ) : nil;
                    
                }];
                
               
                
                // Handle the result
            }];

            
            // Handle the result
        }];
    }
    else
    {
        
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        
        [login logInWithReadPermissions:@[@"public_profile", @"email",@"user_friends",@"user_about_me",@"user_work_history",@"user_birthday",@"user_education_history",@"user_photos"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
         
         
         {

            [SVProgressHUD showSuccessWithStatus:@"Success"];
             
             if (error)
             {
                 

                 // Process error
             }
             else if (result.isCancelled)
             {
                  [SVProgressHUD dismiss];
                 [buttonConnectWithFacebook setTitle:[FBSDKAccessToken currentAccessToken] ? @"Connected With Facebook" : @"Connect With Facebook" forState:UIControlStateNormal];

                 // Handle cancellations
             }
             else
             {
                 
                 ///me/mutualfriends/[OTHER ID]/?fields=name,picture
                 NSDictionary *params = @{
                                          @"fields": @"context.fields(mutual_friends)",@"fields":@"education,albums,name,picture.width(100).height(100)}",
                                          };
                 /* make the API call */
                 
                 FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                               initWithGraphPath:@"me"
                                               parameters:params
                                               HTTPMethod:@"GET"];
                 [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                       id result,
                                                       NSError *error) {
                                     [SVProgressHUD dismiss];
                     NSLog(@"result %@",result);
                     [buttonConnectWithFacebook setTitle:[FBSDKAccessToken currentAccessToken] ? @"Connected With Facebook" : @"Connect With Facebook" forState:UIControlStateNormal];
                     
                     NSArray *filtered = [[result valueForKeyPath:@"albums.data"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", @"Profile Pictures"]];
                     NSArray *arrayFaceBookProfilePictures = [[filtered valueForKeyPath:@"photos.data"] objectAtIndex:0];
                     
                     FBSDKGraphRequest *requestFacebookAlbum = [[FBSDKGraphRequest alloc] initWithGraphPath:[filtered valueForKey:@"id"][0] parameters:@{@"fields":@"photos{picture.width(200).height(200)}"} HTTPMethod:@"GET"];
                     
                     [requestFacebookAlbum startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                         
                         NSArray *arrayFaceBookProfilePictures = [result valueForKeyPath:@"photos.data.picture"];
                         [CAUser sharedUser].arrayFacebookProfilePicture = arrayFaceBookProfilePictures;
                         isFromFacebookProfilePicture ? (
                                                         {
                                                             CAFacebookPicturesCollectionViewController *facebookPictureViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CAFacebookPicturesCollectionViewController"];
                                                             facebookPictureViewController.arrayProfilePictures = [CAUser sharedUser].arrayFacebookProfilePicture;
                                                             facebookPictureViewController.delegateFacebookProfilePicture = (id<CAProtocolFacebookPicture>)self;
                                                             [self.navigationController pushViewController:facebookPictureViewController animated:YES];
                                                         }
                                                         ) : nil;
                         
                     }];

                     
                     
                     [CAUser sharedUser].arrayFacebookProfilePicture = arrayFaceBookProfilePictures;
                     
                     [CAUser connectWithFacebookWithUserId:[CAUser sharedUser].userId andFacebookId:[FBSDKAccessToken currentAccessToken].userID WithCompletionBlock:^(BOOL success, NSError *error) {
                         [SVProgressHUD dismiss];
                     }];
                     
                     
                     // Handle the result
                 }];
                 if ([result.grantedPermissions containsObject:@"email"])
                 {
                     NSLog(@"result is:%@",result);
                 }
             }
         }];
        
    }

}

-(void)addAttributedText{
    NSDictionary *attribute = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};
    NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:@"Terms And Condition" attributes:attribute];
    [btnTermsAndCondition.titleLabel setAttributedText:attributedString];
    
}

-(void)setUpUi
{

    
    [buttonConnectWithFacebook setTitle:[FBSDKAccessToken currentAccessToken] ? @"Connected With Facebook" : @"Connect With Facebook" forState:UIControlStateNormal];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    for (UIButton *object in arrayButtonCar) {
        object.layer.cornerRadius = object.frame.size.width / 2;
        object.clipsToBounds = YES;
        [object.layer setBorderColor:[UIColor whiteColor].CGColor];
        [object.layer setBorderWidth:2];
    }
    NSArray *images=@[@"username",@"emailId",@"mobile",@"password",@"username",@"smoke",@"nosmoke"];
    category = @[@"Driver",@"Passenger"];
    smokeStatus = @[@"Non-Smoker",@"Smoker"];
    [textFieldSignUp enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
        [textField setDelegate:self];
        textField.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"textField_bg"]];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0,18, 18)];
        [imgView setContentMode:UIViewContentModeScaleAspectFit];
        imgView.image = [UIImage imageNamed:idx==5 && [CAUser sharedUser].smoker.integerValue == 0 ?  images[idx+1] : images[idx]];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 22)];
        [paddingView addSubview:imgView];
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setLeftView:paddingView];
        [textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
       }];
    
    UITextField *textFieldMobile = (UITextField *)textFieldSignUp[2];
    labelVisible = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textFieldMobile.frame.size.width/4, 22)];
    [textFieldMobile setRightView:labelVisible];
    labelVisible.text = [CAUser sharedUser].visibility.integerValue == 0 ? @"Not Visible" : @"Visible";
    [labelVisible setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    [labelVisible setTextAlignment:NSTextAlignmentLeft];
    labelVisible.textColor = [UIColor whiteColor];
    [textFieldMobile setRightViewMode:UITextFieldViewModeAlways];
    
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    if([CAUser sharedUser].userId.length>0){//Edit Profile
        self.title = @"Edit Profile";
        [signUpButton setTitle:@"Update" forState:UIControlStateNormal];
        [self setupMenuBarButtonItems];
        [textFieldSignUp[0] setText:[CAUser sharedUser].userName];
        [textFieldSignUp[1] setText:[CAUser sharedUser].emailId];
        [textFieldSignUp[2] setText:[CAUser sharedUser].phoneNumber];
        [textFieldSignUp[3] setText:[CAUser sharedUser].password];
        [textFieldSignUp[4] setText:[CAUser sharedUser].category];
        [textViewAboutMe setText:[[[CAUser sharedUser] about_me] length] ? [[CAUser sharedUser] about_me] :@"Bio" ];
        [textFieldSignUp[5] setText:[CAUser sharedUser].smoker.integerValue == 0 ? @"Non-Smoker" :@"Smoker"];
        [textFieldSignUp[0] setUserInteractionEnabled:NO];
         [textFieldSignUp[1] setUserInteractionEnabled:NO];
        
        [textFieldSignUp[4] setInputView:[self setPickerView]];
        [textFieldSignUp[4] setInputAccessoryView:[self setPickerToolBar]];
        [textFieldSignUp[5] setInputView:[self setPickerView]];
        [textFieldSignUp[5] setInputAccessoryView:[self setPickerToolBar]];
        [profileImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,[CAUser sharedUser].profile_ImageName]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
        [arrayTextFieldCarName enumerateObjectsUsingBlock:^(UITextField* textField, NSUInteger idx, BOOL *stop) {
            textField.inputView = pickerViewVehicle;
            textField.inputAccessoryView = [self setPickerToolBar];
            
        }];
        [arrayButtonCar enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
            
            [obj sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",carUrl,[[CAUser sharedUser] valueForKey:[NSString stringWithFormat:@"car_image%d",idx+1]]]] forState:UIControlStateNormal];

            [obj setTitle:[[[CAUser sharedUser] valueForKey:[NSString stringWithFormat:@"car_image%d",idx+1]] length] ? @"" :[NSString stringWithFormat:@"Car%d",idx+1] forState:UIControlStateNormal];
            [arrayTextFieldCarName[idx] setText:[[CAUser sharedUser] valueForKey:[NSString stringWithFormat:@"car_name%d",idx+1]]];
            [arrayTextFieldCarLicence[idx] setText:[[CAUser sharedUser] valueForKey:[NSString stringWithFormat:@"car_licence_num%d",idx+1]]];
            NSLog(@"1 %@  2 %@ 3 %@",[arrayButtonCar[idx] backgroundImageForState:UIControlStateNormal],[(UITextField *)arrayTextFieldCarName[idx] text],[(UITextField *)arrayTextFieldCarLicence[idx] text]);
            
            [[(UITextField *)arrayTextFieldCarName[idx] text] length] ? [arrayCarDetails setObject:@[[[CAUser sharedUser] valueForKey:[NSString stringWithFormat:@"car_image%d",idx+1]],[(UITextField *)arrayTextFieldCarName[idx] text],[(UITextField *)arrayTextFieldCarLicence[idx] text]] forKey:[NSString stringWithFormat:@"car%dDetails",idx+1]] : nil;
            
        }];
//        [profileImage setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,[CAUser sharedUser].profile_ImageName]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        [profileImage setSelected:YES];
       // [profileImage setTitle:@"Change" forState:UIControlStateSelected];
        [profileImage addTarget:self action:@selector(profileImageButtonAction) forControlEvents:UIControlEventTouchUpInside];
        textViewAboutMe.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"textField_bg"]];
        [textViewAboutMe setTextAlignment:NSTextAlignmentJustified];
        [textViewAboutMe setTextColor:[UIColor whiteColor]];
        [self ressignKeyboardForTextView];
        
    }
    else{ //Sign Up
        [textFieldSignUp[4] setHidden:YES];
        [textFieldSignUp[4] setInputView:[self setPickerView]];
        [textFieldSignUp[4] setInputAccessoryView:[self setPickerToolBar]];
        [textFieldSignUp[5] setInputView:[self setPickerView]];
        [textFieldSignUp[5] setInputAccessoryView:[self setPickerToolBar]];
        self.title = @"Register";
        [arrayTextFieldCarName enumerateObjectsUsingBlock:^(UITextField* textField, NSUInteger idx, BOOL *stop) {
            textField.inputView = pickerViewVehicle;
            textField.inputAccessoryView = [self setPickerToolBar];
            
        }];
        [profileImage setBackgroundImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
        [profileImage setBackgroundImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateSelected];
        //        [profileImage setTitle:@"Add" forState:UIControlStateNormal];
        //        [profileImage setTitle:@"Change" forState:UIControlStateSelected];
        [profileImage addTarget:self action:@selector(profileImageButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [profileImage setContentMode:UIViewContentModeScaleAspectFit];
    }
    [profileImage setTitleEdgeInsets:UIEdgeInsetsMake(70, 0, 0, 0)];
    [profileImage.layer setCornerRadius:50.0f];
    [profileImage setClipsToBounds:YES];
    
}

-(UIPickerView *)setPickerView{
    UIPickerView *pickerVw = [[UIPickerView alloc]init];
    pickerVw.delegate=self;
    pickerVw.dataSource = self;
    pickerVw.showsSelectionIndicator = YES;
    return pickerVw;
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
    [textFiledActive resignFirstResponder];
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

#pragma mark - UIBarButtonItem Callbacks

- (IBAction)buttonDeletePressed:(id)sender {
    if ([sender tag]==0) {
        [sender setTag:1];
        [arrayButtonCar enumerateObjectsUsingBlock:^(UIButton * obj, NSUInteger idx, BOOL *stop) {
            
            UIButton *buttonDelete = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(obj.frame)-3, CGRectGetMinY(obj.frame)-10, 20, 20)];
            [buttonDelete setTitle:/*—*/@"-" forState:UIControlStateNormal];
            [buttonDelete setBackgroundColor:[UIColor redColor]];
            [buttonDelete.layer setCornerRadius:10];
            [buttonDelete.layer setBorderColor:[UIColor whiteColor].CGColor];
            [buttonDelete.layer setBorderWidth:2];
            [buttonDelete addTarget:self action:@selector(buttonDeleteImageWithIndex:) forControlEvents:UIControlEventTouchUpInside];
            [buttonDelete setTag:idx];
            [scrollViewCar addSubview:buttonDelete];
        }];
    }
    else
    {
        [[scrollViewCar subviews] enumerateObjectsUsingBlock:^(UIButton * obj, NSUInteger idx, BOOL *stop) {
            
            if (obj.frame.size.width == 20) {
                [obj removeFromSuperview];
            }
        }];
         [sender setTag:0];
    }
    
}
- (IBAction)buttonDeleteImageWithIndex:(UIButton *)sender {
    
    [arrayButtonCar[sender.tag] setBackgroundImage:nil forState:UIControlStateNormal];
    [arrayButtonCar[sender.tag] setTitle:[NSString stringWithFormat:@"Car%d",sender.tag+1] forState:UIControlStateNormal];
    [(UITextField *)arrayTextFieldCarLicence[sender.tag] setText:@""];
    [(UITextField *)arrayTextFieldCarName[sender.tag] setText:@""];

    }
- (IBAction)buttonKgModalDismiss:(UIButton *)sender {
    __block BOOL isClear;
    if (sender.tag == 0) {
        
        [arrayButtonCar enumerateObjectsUsingBlock:^(UIButton * obj, NSUInteger idx, BOOL *stop) {
           
            if ([obj backgroundImageForState:UIControlStateNormal] && [[(UITextField *)arrayTextFieldCarName[idx] text] length] && [[(UITextField *)arrayTextFieldCarLicence[idx] text] length])
            {
                [arrayCarDetails setObject:@[[arrayButtonCar[idx] backgroundImageForState:UIControlStateNormal],[(UITextField *)arrayTextFieldCarName[idx] text],[(UITextField *)arrayTextFieldCarLicence[idx] text]] forKey:[NSString stringWithFormat:@"car%dDetails",idx+1]];
                isClear=  YES;
            }
            else if (![obj backgroundImageForState:UIControlStateNormal] && ![[(UITextField *)arrayTextFieldCarName[idx] text] length] && ![[(UITextField *)arrayTextFieldCarLicence[idx] text] length])
            {
                isClear=  YES;
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Please fill all the field" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil] show];
                isClear = NO;
                *stop = YES;
                return;
                
            }
            if (idx == 2) {
                
                isClear ? [[arrayCarDetails allKeys] count] ? [[CAUser sharedUser] setArrayCar:[[CAUser sharedUser] setArrayCarFromUpdate:arrayCarDetails]] :[[[UIAlertView alloc] initWithTitle:@"" message:@"Please give car details" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show] : nil;
                isClear ? [[arrayCarDetails allKeys] count] ? [[KGModal sharedInstance] hideAnimated:YES] : nil : nil;
            }
            
        }];
        
      }
    else
    {
        [[KGModal sharedInstance] hideAnimated:YES];
    }
    
    

}


- (IBAction)buttonAddCar:(UIButton *)sender {
    [[KGModal sharedInstance] showWithContentView:scrollViewCar andAnimated:YES];
}
- (IBAction)buttonCarPressed:(UIButton *)sender {
    
    switch (sender.tag) {
        case 0:
            carSelection = buttonCar1;
            break;
        case 1:
            carSelection = buttonCar2;
            if (![[arrayCarDetails allKeys] containsObject:@"car1Details"]) {
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Give car1 details to fill car2 details" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                return;
            }

            break;
        case 2:
            carSelection = buttonCar3;
            if (![[arrayCarDetails allKeys] containsObject:@"car2Details"]) {
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Give car2 details to fill car3 details" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                return;
            }
            break;
        default:
            break;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Car Photos"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Camera",@"Gallery", nil];
    
     [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)signUp:(id)sender
{
    [textFiledActive resignFirstResponder];
    if([CAUser sharedUser].userId.length>0){
        [textFieldSignUp[3] text].length>0?[self parseUpdateProfile]:[self showAlertMessage:@"Please enter password"];
    }
    
    else{
        BOOL validateEmail=[self validateEmail:[textFieldSignUp[1] text]];
        validateEmail?(([textFieldSignUp[0] text].length>0&&[textFieldSignUp[1] text].length>0&&[textFieldSignUp[2] text].length>0&&[textFieldSignUp[3] text].length>0)?[self parseSignUp]:[self showAlertMessage:@"Please fill all fields"]):[self showAlertMessage:@"Please enter a valid email"];
    }
}

-(void)parseSignUp
{
    [SVProgressHUD showWithStatus:@"Signing up..." maskType:SVProgressHUDMaskTypeClear];
    CAUser *user=[[CAUser alloc]init];
    user.userName=[textFieldSignUp[0] text];
    user.emailId=[textFieldSignUp[1] text];
    user.phoneNumber=[textFieldSignUp[2] text];
    user.password=[textFieldSignUp[3] text];
    user.about_me = [textViewAboutMe.text isEqualToString:@"Bio"]?@"":textViewAboutMe.text;
    user.smoker = [[textFieldSignUp[5] text] isEqualToString:@"Smoker"] ? @"1" : @"0";
    [arrayButtonCar enumerateObjectsUsingBlock:^(UIButton * obj, NSUInteger idx, BOOL *stop) {
        
        [user setValue:[obj backgroundImageForState:UIControlStateNormal] forKey:[NSString stringWithFormat:@"car_image%d",idx+1]];
        
        [user setValue:[arrayTextFieldCarName[idx] text]  forKey:[NSString stringWithFormat:@"car_name%d",idx+1]];
        [user setValue:[arrayTextFieldCarLicence[idx] text]  forKey:[NSString stringWithFormat:@"car_licence_num%d",idx+1]];
        
    }];
    
    user.profile_Image=[profileImage.currentBackgroundImage fixOrientation];
    [user signUpwithCompletionBlock:^(BOOL success, NSError *error) {
        [SVProgressHUD dismiss];
        if(success)
        {
           
            [self performSelector:@selector(showStatus) withObject:nil afterDelay:0.5];
            [self.navigationController popViewControllerAnimated:YES];
            
           
        }
        else
            [CAServiceManager handleError:error];
    }];
}

-(void)showStatus
{
    
    [SVProgressHUD showSuccessWithStatus:@"Check your email for Verification"];
}

-(void)parseUpdateProfile{
    [SVProgressHUD showWithStatus:@"Updating profile..." maskType:SVProgressHUDMaskTypeClear];
    
   // NSArray *arrayCar = [[[CAUser sharedUser] arrayCar] mutableCopy];
    CAUser *user=[[CAUser alloc]init];
    user.userName=[textFieldSignUp[0] text];
    user.emailId=[textFieldSignUp[1] text];
    user.phoneNumber=[textFieldSignUp[2] text];
    user.password=[textFieldSignUp[3] text];
    user.category = [textFieldSignUp[4] text];
    user.about_me=[textViewAboutMe.text isEqualToString:@"Bio"]?@"":textViewAboutMe.text;
    user.smoker = [[textFieldSignUp[5] text] isEqualToString:@"Smoker"] ? @"1" : @"0";
    user.profile_Image=[profileImage.currentBackgroundImage fixOrientation];
    user.visibility = [CAUser sharedUser].visibility;
    [arrayButtonCar enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        
        [user setValue:[obj backgroundImageForState:UIControlStateNormal] forKey:[NSString stringWithFormat:@"car_image%d",idx+1]];
        [user setValue:[arrayTextFieldCarName[idx] text] forKey:[NSString stringWithFormat:@"car_name%d",idx+1]];
        [user setValue:[arrayTextFieldCarLicence[idx] text] forKey:[NSString stringWithFormat:@"car_licence_num%d",idx+1]];
    }];
/*    [(NSDictionary *)arrayCar enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        if (arrayCar.count==1) {
//            user.car_image1 = obj[0];
//            user.car_name1 =  obj[1];
//            user.car_licence_num1 = obj[2];
//            
//        }
//        else if(arrayCar.count==2)
//        {
//            user.car_image1 = obj[0];
//            user.car_name1 =  obj[1];
//            user.car_licence_num1 = obj[2];
//            user.car_image2 = obj[0];
//            user.car_name2=  obj[1];
//            user.car_licence_num2 = obj[2];
//        }
//        else if(arrayCar.count == 3)
//        {
//            user.car_image1 = obj[0];
//            user.car_name1 =  obj[1];
//            user.car_licence_num1 = obj[2];
//            user.car_image2 = obj[0];
//            user.car_name2=  obj[1];
//            user.car_licence_num2 = obj[2];
//            user.car_image3 = obj[0];
//            user.car_name3 =  obj[1];
//            user.car_licence_num3 = obj[2];
//        }
//        else
//        {
//            user.car_image1 = @"";
//            user.car_name1 =  @"";
//            user.car_licence_num1 = @"";
//            user.car_image2 = @"";
//            user.car_name2=  @"";
//            user.car_licence_num2 = @"";
//            user.car_image3 = @"";
//            user.car_name3 =  @"";
//            user.car_licence_num3 = @"";
//        }
        
    }];
*/
    [user updateUserProfileWithCompletionBlock:^(BOOL success, NSError *error){
        if(success)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProfileImage"
                                                                object:self
                                                              userInfo:nil];
            
            [SVProgressHUD showSuccessWithStatus:@"Updated Successfully"];
        }
        else
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

#pragma mark PickerView Delegates

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return pickerView== pickerViewVehicle ? 2 : 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView == pickerViewVehicle) {
        return component == 0 ? arraycarMakes.count : arraycarModels.count;
    }
    else return [textFieldSignUp[5] isFirstResponder] ? smokeStatus.count : category.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (pickerView == pickerViewVehicle) {
//        component == 0 ? ({
//            
//            
//            stringCarMakes = arraycarMakes[row];
//        }) :({stringCarModels =arraycarModels[row];
//});
//       
//        textFiledActive.text = [NSString stringWithFormat:@"%@-%@",stringCarMakes,stringCarModels] ;
        return component==0 ? arraycarMakes[row] : arraycarModels[row];

    }
    else
   
    
   
    return [textFieldSignUp[5] isFirstResponder] ? smokeStatus[row] : category[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (pickerView == pickerViewVehicle) {
        if (component==0) {
            arraycarModels  =[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Cars" ofType:@"plist"]] valueForKeyPath:[NSString stringWithFormat:@"CarMakes.%@",arraycarMakes[row]]];
            [pickerView reloadAllComponents];
            
        }
         textFiledActive.text = [NSString stringWithFormat:@"%@-%@",[arraycarMakes objectAtIndex:[pickerView selectedRowInComponent:0]],[arraycarModels objectAtIndex:[pickerView selectedRowInComponent:1]]] ;
    }
    else
    {
    [textFieldSignUp[5] isFirstResponder] ?  [(UITextField *) textFieldSignUp[5] setText:smokeStatus[row]] : [(UITextField *) textFieldSignUp[4] setText:category[row]];
    [textFieldSignUp[5] isFirstResponder] && row == 0 ? [(UIImageView *)[[(UITextField *) textFieldSignUp[5] leftView] subviews][0] setImage:[UIImage imageNamed:@"nosmoke"]] : [textFieldSignUp[5] isFirstResponder] && row == 1 ? [(UIImageView *)[[(UITextField *) textFieldSignUp[5] leftView] subviews][0] setImage:[UIImage imageNamed:@"smoke"]] : nil;
    }
    
}

#pragma mark Textfield Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag ==111) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"You want disclose your number or not" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        [alert setTag:111];
        [alert show];
    }
    
    if ([arrayTextFieldCarLicence containsObject:textField] || [arrayTextFieldCarName containsObject:textField] ) {
        [arrayButtonCar enumerateObjectsUsingBlock:^(UIButton * obj, NSUInteger idx, BOOL *stop) {
            
            if ([obj backgroundImageForState:UIControlStateNormal] && [[(UITextField *)arrayTextFieldCarName[idx] text] length] && [[(UITextField *)arrayTextFieldCarLicence[idx] text] length])
            {
                [arrayCarDetails setObject:@[[arrayButtonCar[idx] backgroundImageForState:UIControlStateNormal],[(UITextField *)arrayTextFieldCarName[idx] text],[(UITextField *)arrayTextFieldCarLicence[idx] text]] forKey:[NSString stringWithFormat:@"car%dDetails",idx+1]];
            }
            else if (![obj backgroundImageForState:UIControlStateNormal] && ![[(UITextField *)arrayTextFieldCarName[idx] text] length] && ![[(UITextField *)arrayTextFieldCarLicence[idx] text] length])
            {
            }
            else
            {
               
                *stop = YES;
                return;
                
            }
            
        }];
        
    }


}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    textFiledActive = textField;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==111) {
        
        buttonIndex == 0 ? [[CAUser sharedUser] setVisibility:@"1"] : [[CAUser sharedUser] setVisibility:@"0"];
        labelVisible.text = [CAUser sharedUser].visibility.integerValue == 0 ? @"Not Visible" : @"Visible";

    }
}

-(BOOL)showAlertMessage:(NSString *)message
{
    [[[UIAlertView alloc]initWithTitle:@"Message" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]show];
    return true;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textViewAboutMe.text isEqualToString:@"Bio"]) {
        [textViewAboutMe setText: @""];
    }
    
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if ([textViewAboutMe.text isEqualToString:@""]) {
        [textViewAboutMe setText: @"Bio"];
    }
}

-(void)ressignKeyboardForTextView{
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    textViewAboutMe.inputAccessoryView = keyboardDoneButtonView;
}

- (IBAction)doneClicked:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - header view creation and actions

-(void)profileImageButtonAction{
    [textFiledActive resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Profile Picture"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Camera",@"Gallery",@"Facebook Profile Pictures", nil];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    carSelection = profileButton;
 }

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = indexPath.section==0 ? [super tableView:tableView cellForRowAtIndexPath:indexPath] : nil;
    
    if (cell.tag==5 &&cell==cellCategory) {
        return (!([CAUser sharedUser].userId.length>0)) ? 0 : CGRectGetHeight(cell.frame);
    }else if (cell.tag==0){
        return 78;
    }
        return CGRectGetHeight(cell.frame);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    switch (buttonIndex)
    {
        case 0:
            [self showCamera:buttonIndex];
            break;
        case 1:
            [self showCamera:buttonIndex];
            break;
        case 2:
        {
            if ([actionSheet.title isEqualToString:@"Profile Picture"] ) {
                if ([CAUser sharedUser].arrayFacebookProfilePicture) {
                    CAFacebookPicturesCollectionViewController *facebookPictureViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CAFacebookPicturesCollectionViewController"];
                    facebookPictureViewController.arrayProfilePictures = [CAUser sharedUser].arrayFacebookProfilePicture;
                    facebookPictureViewController.delegateFacebookProfilePicture = (id<CAProtocolFacebookPicture>)self;
                    [self.navigationController pushViewController:facebookPictureViewController animated:YES];
                }
                
                
                else
                {
                    isFromFacebookProfilePicture = YES;
                    [self performSelector:@selector(buttonConnectWithFaceBook:) withObject:nil];
                }

            }
            
            
            
        }
            break;
            
        default:
            break;
    }
}

-(void)showCamera:(NSInteger)actionSheetIndex{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    [imagePickerController setDelegate:self];
    imagePickerController.sourceType = (actionSheetIndex==0)?UIImagePickerControllerSourceTypeCamera:UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing=YES;
    [[KGModal sharedInstance] hideAnimated:carSelection != profileButton ? YES : NO];
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

#pragma mark-facebookImagePickerDelegate

-(void)facebookPicturesDidFinishPickingImage:(UIImage *)image
{
    [profileImage setBackgroundImage:image forState:UIControlStateNormal];
    
}

#pragma mark -UIImagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];

    switch (carSelection) {
        case 0:
        {
            [arrayButtonCar[carSelection] setBackgroundImage:selectedImage forState:UIControlStateNormal];
            [(UIButton *)arrayButtonCar[carSelection] setTitle:@"" forState:UIControlStateNormal];
        }
            break;
        case 1:
        {
            [arrayButtonCar[carSelection] setBackgroundImage:selectedImage forState:UIControlStateNormal];
            [(UIButton *)arrayButtonCar[carSelection] setTitle:@"" forState:UIControlStateNormal];
            
        }
            break;
        case 2:
        {
            [arrayButtonCar[carSelection] setBackgroundImage:selectedImage forState:UIControlStateNormal];
            [(UIButton *)arrayButtonCar[carSelection] setTitle:@"" forState:UIControlStateNormal];
        }
            break;
            case 3:
        {
            [profileImage setBackgroundImage:selectedImage forState:UIControlStateNormal];
            [profileImage setBackgroundImage:selectedImage forState:UIControlStateSelected];
            [profileImage setSelected:YES];

        }
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    carSelection != profileButton ? [[KGModal sharedInstance] showWithContentView:scrollViewCar] : nil;
    
   }

-(void)dismissKeyboard{
    [textFiledActive resignFirstResponder];
}

#pragma mark-Mail Validation
- (BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegEx =
    @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [emailTest evaluateWithObject:email];
}



@end
