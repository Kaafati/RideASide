//
//  CAViewJoineesViewController.m
//  RoadTrip
//
//  Created by SRISHTI INNOVATIVE on 04/10/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CAViewJoineesViewController.h"
#import "CAUser.h"
#import "CATripCell.h"
#import "UIImageView+WebCache.h"
#import "CAProfileTableViewController.h"
#import "MFSideMenu.h"
#import "UIButton+WebCache.h"
#import "PayPalMobile.h"

#define kPayPalEnvironment PayPalEnvironmentNoNetwork

@interface CAViewJoineesViewController ()<PayPalPaymentDelegate>{
    NSArray *tripUsers;
}

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;

@end

@implementation CAViewJoineesViewController

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
 
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId != %@",_trips.UserId];
    tripUsers =  [_trips.arrayJoinees filteredArrayUsingPredicate:predicate];
  //  [_trips.category isEqualToString:@"Passenger"] ? [self fetchDriversList]: [self fetchJoineesList];
    //[self fetchJoineesList];
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
-(void)setUpUi{
     self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    self.title=@"Joinees";
}
- (void)setupMenuBarButtonItems {
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
    //self.navigationItem.rightBarButtonItem = [_trips.category isEqualToString:@"Passenger"] ? [self rightBarButtonItem] : nil;
}

-(UIBarButtonItem *)rightBarButtonItem{

    return [[UIBarButtonItem alloc]initWithTitle:@"PayForTrip" style:UIBarButtonItemStylePlain target:self action:@selector(payForTripAction:)];
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

#pragma mark - UIBarButtonItem Callbacks

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

-(void)payForTripAction:(UIBarButtonItem*)sender{
    [self payPalPaymentProcess];
}

#pragma mark-Parsing
-(void)fetchJoineesList{
    CAUser *user=[[CAUser alloc]init];
    
    [user fetchJoineesListInTripWithTripId:_trips.tripId WithCompletionBlock:^(BOOL success, id result, NSError *error) {
        tripUsers=(NSArray *)result;
        [self.tableView reloadData];
        
    }];

}

-(void)fetchDriversList{
    NSLog(@"Details tripid %@,tripCategory=%@",_trips.tripId,_trips.category);
    CAUser *user = [[CAUser alloc]init];
    [user fetchDriverListAccepted:_trips.tripId withCategory:_trips.category withCompletion:^(bool success, id result, NSError *err) {
        tripUsers=(NSArray *)result;
        [self.tableView reloadData];
    }];
}

#pragma mark - PayPalPayment

-(void)payPalPaymentProcess{
    // Paypal configuration
    if (!_payPalConfig) {
        _payPalConfig = [[PayPalConfiguration alloc]init];
        _payPalConfig.acceptCreditCards = YES;
        _payPalConfig.languageOrLocale = @"en";
        _payPalConfig.merchantName = @"Awesome Shirts, Inc.";
        _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
        _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
        _payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
        [self goToPayPalPage];
    }
}

-(void)goToPayPalPage{
    PayPalItem *item = [PayPalItem itemWithName:_trips.tripName withQuantity:1 withPrice:[NSDecimalNumber decimalNumberWithString:@"10"] withCurrency:@"USD" withSku:@""];
    NSArray *items = @[item];
    NSDecimalNumber *subtotal= [PayPalItem totalPriceForItems:items];
    // Optional: include payment details
    NSDecimalNumber *shipping = [[NSDecimalNumber alloc]initWithString:@"10"];
    NSDecimalNumber *tax = [[NSDecimalNumber alloc]initWithString:@"10"];
    PayPalPaymentDetails *payPalDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subtotal withShipping:shipping withTax:tax];
    NSDecimalNumber *total = [[subtotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = total;
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Total Amount";
    payment.items = items;  // if not including multiple items, then leave payment.items as nil
    payment.paymentDetails = payPalDetails; // if not including payment details, then leave payment.paymentDetails as nil
    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
    }
    
    // Update payPalConfig re accepting credit cards.
    self.payPalConfig.acceptCreditCards = YES;
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                configuration:self.payPalConfig
                                                                                                     delegate:self];
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
   // [self.delegate actionAfterAcceptOrRejectTripwithIndexPathOfRowSelected:_indexPathOfRowSelected];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    // TODO: Send completedPayment.confirmation to server
    [SVProgressHUD showWithStatus:@"Sending payment details..." maskType:SVProgressHUDMaskTypeBlack];
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
    [self parsePaymentDetailsToBackEnd];
}

-(void)parsePaymentDetailsToBackEnd{
    [CAUser parsePaymentDetailsToBackEndWithTripId:_trips.tripId andTripName:_trips.tripName andAmount:_trips.cost WithCompletionBlock:^(BOOL success, NSError *error) {
        [SVProgressHUD dismiss];
        if(success){
           // if(_isFromRequestPage){
               // [self.delegate actionAfterAcceptOrRejectTripwithIndexPathOfRowSelected:_indexPathOfRowSelected];
                [self.navigationController popViewControllerAnimated:YES];
        } 

    }];
    
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [tripUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CATripCell *cell = (CATripCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[CATripCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    CAUser *user=tripUsers[indexPath.row];
    cell.backgroundColor=[UIColor clearColor];
    cell.labelTrip.textColor=[UIColor whiteColor];
    [cell.imageUserPicture sd_setBackgroundImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,user.profile_ImageName]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
//    [cell.imageUserPicture setBackgroundImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,user.profile_ImageName]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
//    [cell.imageUserPicture setImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,user.profile_ImageName]] placeholderImage:[UIImage imageNamed:@"placeholder"]];

    cell.imageUserPicture.layer.cornerRadius = 25.0f;
    cell.imageUserPicture.clipsToBounds=YES;
    
    cell.labelTrip.text=user.userName;
    cell.labelTrip.font=[UIFont fontWithName:@"Arial" size:12];
    [cell.imageUserPicture.layer setBorderColor:[UIColor whiteColor].CGColor];
    cell.imageUserPicture.layer.borderWidth=2;
    cell.selectionStyle=UITableViewCellEditingStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CAUser *user=tripUsers[indexPath.row];
    CAProfileTableViewController *profile=[self.storyboard instantiateViewControllerWithIdentifier:@"profileView"];
    [profile setTrip:_trips];

    [profile setUserId:user.userId];
    [profile setUserDetails:user];
    
    [self.navigationController pushViewController:profile animated:YES];
    
}


@end
