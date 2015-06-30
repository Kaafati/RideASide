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
@interface CASignUpViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate, UITextViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    IBOutletCollection(UITextField) NSArray *textFieldSignUp;
    UITextField *textFiledActive;
    IBOutlet UIButton *signUpButton;
    IBOutlet UIButton *profileImage;
    IBOutlet UITextView *textViewAboutMe;
    __weak IBOutlet UITableViewCell *cellCategory;
    __weak IBOutlet UITableViewCell *cellTMC;
    NSArray *category;
    __weak IBOutlet UIButton *btnTermsAndCondition;
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
    [self setUpUi];
    [CAUser sharedUser].userId.length>0 ? [self hideTermsAndConditionCell]:[self addAttributedText];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)hideTermsAndConditionCell{
    [cellTMC setHidden:YES];
}

-(void)addAttributedText{
    NSDictionary *attribute = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};
    NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:@"Terms And Condition" attributes:attribute];
    [btnTermsAndCondition.titleLabel setAttributedText:attributedString];
    
}

-(void)setUpUi
{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    NSArray *images=@[@"username",@"emailId",@"mobile",@"password",@"username"];
    category = @[@"Driver",@"Passenger"];
    [textFieldSignUp enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
        [textField setDelegate:self];
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
        [textFieldSignUp[0] setUserInteractionEnabled:NO];
         [textFieldSignUp[1] setUserInteractionEnabled:NO];
        
        [textFieldSignUp[4] setInputView:[self setPickerView]];
        [textFieldSignUp[4] setInputAccessoryView:[self setPickerToolBar]];
        
        [profileImage sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,[CAUser sharedUser].profile_ImageName]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
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
        self.title = @"Register";
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
    CAUser *user=[[CAUser alloc]init];
    user.userName=[textFieldSignUp[0] text];
    user.emailId=[textFieldSignUp[1] text];
    user.phoneNumber=[textFieldSignUp[2] text];
    user.password=[textFieldSignUp[3] text];
    user.category = [textFieldSignUp[4] text];
    user.about_me=[textViewAboutMe.text isEqualToString:@"Bio"]?@"":textViewAboutMe.text;
    user.profile_Image=[profileImage.currentBackgroundImage fixOrientation];
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
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return category.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return category[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [(UITextField *) textFieldSignUp[4] setText:category[row]];
}

#pragma mark Textfield Delegates

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    textFiledActive = textField;
}

-(void)showAlertMessage:(NSString *)message
{
    [[[UIAlertView alloc]initWithTitle:@"Message" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]show];
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
                                  initWithTitle:@"Share"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Camera",@"Gallery", nil];
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
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
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

#pragma UIImagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [profileImage setBackgroundImage:selectedImage forState:UIControlStateNormal];
    [profileImage setBackgroundImage:selectedImage forState:UIControlStateSelected];
    [profileImage setSelected:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
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
