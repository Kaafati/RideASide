//
//  CARateViewController.m
//  RoadTrip
//
//  Created by Bala on 30/10/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CARateViewController.h"
#import "DYRateView.h"
#import "CAUser.h"
#import "CAServiceManager.h"
#import "SVProgressHUD.h"

@interface CARateViewController ()<DYRateViewDelegate,UITextViewDelegate>
{
    IBOutlet UITextView *textView;
    NSInteger starRate;
    CGPoint originalCenter;
}

@end

@implementation CARateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUi];
    // Do any additional setup after loading the view.
    
    originalCenter = self.view.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setUpUi{
    starRate=0;
    DYRateView *rateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 150, self.view.bounds.size.width, 40) fullStar:[UIImage imageNamed:@"StarFullLarge.png"] emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
    
    rateView.padding = 20;
    rateView.alignment = RateViewAlignmentCenter;
    rateView.editable = YES;
    rateView.delegate = self;
    [self.view addSubview:rateView];
    textView.layer.borderWidth=1.0;
    textView.layer.borderColor=(__bridge CGColorRef)([UIColor whiteColor]);
    
}
- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate{
    starRate=rate.integerValue;
}
#pragma mark-Text View Delegate
- (BOOL) textViewShouldBeginEditing:(UITextView *)text_View
{
    textView.text=@"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}

-(BOOL) textViewShouldEndEditing:(UITextView *)text_View{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    return YES;
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    // Assign new frame to your view
    [self.view setFrame:CGRectMake(0,-110,320,460)]; //here taken -20 for example i.e. your view will be scrolled to -20. change its value according to your requirement.
    
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [self.view setFrame:CGRectMake(0,0,320,460)];
}


-(BOOL)textView:(UITextView *)text_View shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
       if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
    
}
-(IBAction)update:(id)sender{
    [SVProgressHUD showWithStatus:@"Updating..." maskType:SVProgressHUDMaskTypeBlack];
    [CAUser parseReviewingadRaringOfUseriD:_userId withReview:textView.text withRateValue:[NSString stringWithFormat:@"%zd",starRate] WithCompletionBlock:^(BOOL success, NSError *error) {
        [SVProgressHUD dismiss];
        if(success){
            [self.delegate updateUserDetails];
            [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Updated succesfully" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]show];
        }
        else
            [CAServiceManager handleError:error];
        
    }];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
