//
//  CALoginViewController.m
//  RoadTrip
//
//  Created by SICS on 19/08/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CALoginViewController.h"
#import "CASignUpViewController.h"
#import "CAUser.h"
#import "CAServiceManager.h"
#import "CAAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>



@interface CALoginViewController ()<UITextFieldDelegate>
{
     IBOutletCollection(UITextField) NSArray *textFieldLogin;
    UITextField *textFieldActive;
}

@end

@implementation CALoginViewController

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

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpUi
{
    self.tableView.bounces = YES;
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    NSArray *images=@[@"username",@"password"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  [textFieldLogin enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
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
}

#pragma mark- Delegate
-(IBAction)login:(id)sender
{
    [textFieldActive resignFirstResponder];
    ([textFieldLogin[0] text].length>0&&[textFieldLogin[1] text].length>0)?[self parseLogin]:[self showAlert];
}
-(void)showAlert
{
    [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please fill all fields" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]show];
}
-(void)parseLogin
{
    [SVProgressHUD showWithStatus:@"Logging in..." maskType:SVProgressHUDMaskTypeBlack];
    [CAUser loginWithUsername:[textFieldLogin[0] text] password:[textFieldLogin[1] text] withCompletionBlock:^(BOOL success, CAUser *user, NSError *error) {
        [SVProgressHUD dismiss];
        if(success)
        {
            
            CAAppDelegate * appDelegate = (CAAppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate setHomePage];
        }
        else
        {
            [textFieldLogin enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
                textField.text=@"";
            }];
            [CAServiceManager handleError:error];
        }
        
    }];

}
-(IBAction)signUp:(id)sender
{
    CASignUpViewController *signInViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"signUpView"];
    [self.navigationController pushViewController:signInViewController animated:YES];
}

- (IBAction)facebookLogin:(id)sender {
    FBSession *session = [[FBSession alloc] initWithPermissions:@[@"public_profile", @"email"]];
    [FBSession setActiveSession:session];
    [session openWithBehavior:FBSessionLoginBehaviorForcingWebView
            completionHandler:^(FBSession *session,
                                FBSessionState status,
                                NSError *error) {
                if (FBSession.activeSession.isOpen) {
                    [[FBRequest requestForMe] startWithCompletionHandler:
                     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                         if (!error) {
                             NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [user objectID]];
                             [SVProgressHUD showWithStatus:@"Signing up..." maskType:SVProgressHUDMaskTypeBlack];
                             [CAUser signUpWithFB:user.objectID email:[user objectForKey:@"email"] name:user.name profileImg:userImageURL withCompletionBlock:^(BOOL success, CAUser *signUpUser, NSError *error) {
                                 [SVProgressHUD dismiss];
                                 if (success) {
                                     
                                     CAAppDelegate * appDelegate = (CAAppDelegate*)[UIApplication sharedApplication].delegate;
                                     [appDelegate setHomePage];
                                     
                                 }
                                 else{
                                     [CAServiceManager handleError:error];
                                 }
                             }];
                             
                         }
                     }];
                }
            }];
}



#pragma mark Textfield Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    textFieldActive = textField;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
