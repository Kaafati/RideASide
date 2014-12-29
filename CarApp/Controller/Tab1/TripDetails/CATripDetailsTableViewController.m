//
//  CATripDetailsTableViewController.m
//  RoadTrip
//
//  Created by SICS on 21/08/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CATripDetailsTableViewController.h"
#import "CAServiceManager.h"
#import "SVProgressHUD.h"
#import "MFSideMenu.h"
#import "NSDate+TimeZone.h"
#import "GeoCoder.h"
#import "CAMapViewController.h"
#import "CAViewJoineesViewController.h"
#import "CAUser.h"
#import "CAAppDelegate.h"
#import "CASearchLocationViewController.h"
#import "CANavigationController.h"
#import "PayPalMobile.h"
#import <CoreLocation/CoreLocation.h>

#define kPayPalEnvironment PayPalEnvironmentNoNetwork
@interface CATripDetailsTableViewController ()<UITextFieldDelegate,UIAlertViewDelegate,searchLocationDelegate,PayPalPaymentDelegate>
{
    IBOutletCollection(UITextField) NSArray *textFieldTripDetails;
       IBOutletCollection(UITableViewCell) NSArray *cellArray;
    __weak IBOutlet UIDatePicker *datePicker;
    __weak IBOutlet UIToolbar *toolBar;
    NSString *dateOfTrip,*dateForPushNotification;
    UITextField *activeTextField;
    IBOutlet UIButton *addTripOrViewJoiness;
    IBOutlet UIButton *acceptTrip;
    IBOutlet UIStepper *stepper;
    IBOutlet UISegmentedControl *segmentControl;
    NSInteger milegae;
    float startLat, startLng, destLat, destLng ,costPerHead;;
    
    
    
}
@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@end

@implementation CATripDetailsTableViewController

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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    (_trip.tripPostedById.length>0&&!_isFromRequestPage)?[self leftSideNavigationBar]: [self setupMenuBarButtonItems];
    [self setUI];
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
    [activeTextField resignFirstResponder];
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)backBarButtonItem {
    [activeTextField resignFirstResponder];
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

-(void)setUI{
    
    milegae=0;
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    NSArray *images=@[@"tripName",@"startingplace",@"end",@"fuel",@"toll",@"distance",@"vehicle",@"vehicleNumber",@"cost",@"seats",@"date"];
    if(_trip.TollBooth.length>0){
        self.title=@"Trip Details";
        [addTripOrViewJoiness setTitle:@"View Joinees" forState:UIControlStateNormal];
    }
    else{
        self.title=@"Add Trip";
        [addTripOrViewJoiness setTitle:@"Add Trip" forState:UIControlStateNormal];
    }
    
    
    [textFieldTripDetails enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
        if(_trip.TollBooth.length>0){
            textField.userInteractionEnabled=NO;
            
        }
        else{
            textField.delegate=self;
        }
        
        
        
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
    if(_trip.TollBooth.length>0)//View Trip
    {
        
        
        [textFieldTripDetails[0] setText:_trip.tripName];
        [textFieldTripDetails[1] setText:_trip.StartingPlace];
        [textFieldTripDetails[2] setText:_trip.EndPlace];
        [textFieldTripDetails[3] setText:[NSString stringWithFormat:@"%@ in litres",_trip.FuelExpenses]];
        [textFieldTripDetails[4] setText:_trip.TollBooth];
        [textFieldTripDetails[5] setText:_trip.TotalKilometer];
        [textFieldTripDetails[6] setText:_trip.Vehicle];
        [textFieldTripDetails[7] setText:_trip.vehicleNumber];
        [textFieldTripDetails[8] setText:[NSString stringWithFormat:@"%@ per seat",_trip.cost]];
        [textFieldTripDetails[9] setText:_trip.SeatsAvailable];
        [textFieldTripDetails[10] setText:_trip.date];
        [stepper setHidden:YES];
        [segmentControl setHidden:YES];
        [acceptTrip setEnabled:YES];
        
        if(_trip.tripPostedById.length>0){
            [cellArray[0] setHidden:YES];
        }
        else{
              [cellArray[1] setHidden:YES];
        }
        
        
        
        UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightbarbutton.frame =CGRectMake(0, 0, 80, 30) ;
        [rightbarbutton setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
        [rightbarbutton addTarget:self action:@selector(goToMapPage) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightbarbutton];
        
        GeoCoder *geoCoderStartPlace=[[GeoCoder alloc]init];
        [geoCoderStartPlace geoCodeAddress:_trip.StartingPlace inBlock:^(CLLocation *location) {
            _trip.startPlaceLocation=location;
        }];
        GeoCoder *geoCoderEndPlace=[[GeoCoder alloc]init];
        [geoCoderEndPlace geoCodeAddress:_trip.EndPlace inBlock:^(CLLocation *location) {
            _trip.endPlaceLocation=location;
        }];
        
    }
    else//Add Trip
    {
        
        [textFieldTripDetails[3] setInputAccessoryView:toolBar];
        [textFieldTripDetails[5] setInputAccessoryView:toolBar];
        [textFieldTripDetails[8] setInputAccessoryView:toolBar];
        [textFieldTripDetails[9] setText:@"1"];
        
        stepper.minimumValue = 1;
        stepper.maximumValue = 6;
        stepper.stepValue = 1;
        
        UITextField *textField=textFieldTripDetails[10];
        textField.inputView=datePicker;
        textField.inputAccessoryView=toolBar;
        datePicker.minimumDate=[NSDate date];
        [cellArray[1] setHidden:YES];
    }
    
}
-(void)leftSideNavigationBar{
    UIButton *leftbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftbarbutton.frame =CGRectMake(0, 0, 30, 30) ;
    [leftbarbutton setImage:[UIImage imageNamed:@"home"] forState:UIControlStateNormal];
    [leftbarbutton addTarget:self action:@selector(goToHomePage) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftbarbutton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark-Actions
-(IBAction)addTripOrViewJoinees:(UIButton *)sender
{
    [activeTextField resignFirstResponder];
    if(_trip.TollBooth.length>0){
        [self viewJoinees];
    }
    else{
        [self addTripDetails];
    }
    
}

#pragma mark-Add Trip Details
- (IBAction)stepperChanged:(UIStepper *)sender {
    NSUInteger value = sender.value;
    [textFieldTripDetails[9] setText:[NSString stringWithFormat:@"%lu",value]];
}
-(IBAction)segmentValueChanged:(UISegmentedControl *)sender{
    [textFieldTripDetails[4] setText:[sender titleForSegmentAtIndex:sender.selectedSegmentIndex]];
     }
-(IBAction)doneSelectingDate:(id)sender{
    [activeTextField resignFirstResponder];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [textFieldTripDetails[10] setText:[NSString stringWithFormat:@"%@",
                                       [dateFormatter stringFromDate:datePicker.date]]];
    dateOfTrip=[[NSDate alloc]changeLocalTimeZoneToServerForDate:[NSString stringWithFormat:@"%@",
                                                                  [dateFormatter stringFromDate:datePicker.date]]];
    
    NSDate *dateOfSelected=[datePicker.date dateByAddingTimeInterval:-300];
    dateForPushNotification=[[NSDate alloc]changeLocalTimeZoneToServerForDate:[NSString stringWithFormat:@"%@",
                                                                               [dateFormatter stringFromDate:dateOfSelected]]];
    
}
-(void)addTripDetails{
    if( [textFieldTripDetails[0] text].length>0&&[textFieldTripDetails[1] text].length>0&&[textFieldTripDetails[2] text].length>0&&[textFieldTripDetails[3] text].length>0&&[textFieldTripDetails[4] text].length>0&&[textFieldTripDetails[5] text].length>0&&[textFieldTripDetails[6] text].length>0&&[textFieldTripDetails[7] text].length>0&&[textFieldTripDetails[8] text].length>0&&[textFieldTripDetails[9] text].length>0&&[textFieldTripDetails[10] text].length>0)
    {
        [SVProgressHUD showWithStatus:@"Adding Trip Details..."];
        [self parseAddTrip];
    }
    else
        [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please fill all fields" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]show];
    
}

-(void)goToMapPage{
    [activeTextField resignFirstResponder];
    CAMapViewController *mapViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"mapView"];
    mapViewController.trips=_trip;
    [self.navigationController pushViewController:mapViewController animated:YES];
}

-(void)parseAddTrip{
    CATrip *trip=[[CATrip alloc]init];
    trip.tripName=[textFieldTripDetails[0] text];
    trip.StartingPlace=[textFieldTripDetails[1] text];
    trip.EndPlace=[textFieldTripDetails[2] text];
//   trip.FuelExpenses=[NSString stringWithFormat:@"%d",milegae];
    trip.FuelExpenses=[textFieldTripDetails[3] text];
    trip.TollBooth=[textFieldTripDetails[4] text];
    trip.TotalKilometer=[textFieldTripDetails[5] text];
    trip.Vehicle=[textFieldTripDetails[6] text];
    trip.vehicleNumber=[textFieldTripDetails[7] text];
    trip.cost=[NSString stringWithFormat:@"%.02f",costPerHead];
    trip.SeatsAvailable=[textFieldTripDetails[9] text];
    trip.date=dateOfTrip;
    trip.tripStartTimeForNotification=dateForPushNotification;
    
    [trip addTripWithDataWithTrip:trip
                  CompletionBlock:^(BOOL success, id result, NSError *error) {
                      [SVProgressHUD dismiss];
                      if(success){
                          [textFieldTripDetails enumerateObjectsUsingBlock:^(UITextField *obj, NSUInteger idx, BOOL *stop) {
                              obj.text=@"";
                          }];
                          [textFieldTripDetails[9] setText:@"1"];
                          [textFieldTripDetails[4] setText:@"Yes"];
                          segmentControl.selectedSegmentIndex=0;
                          stepper.value=1;
                          milegae=0;;
                          
                      }
                      else
                          [CAServiceManager handleError:error];
                      [self.navigationController popViewControllerAnimated:YES];
                  }];
}

-(void)presentSearchViewControllerWithTag:(NSInteger)textFieldTag withText:(NSString *)addressText{
    CASearchLocationViewController *searchLocation=[self.storyboard instantiateViewControllerWithIdentifier:@"searchView"];
    searchLocation.textFieldTag=textFieldTag;
    [searchLocation setDelegates:self];
    searchLocation.addressName=addressText;
    CANavigationController *navigationController=[[CANavigationController alloc]initWithRootViewController:searchLocation];
    [self presentViewController:navigationController animated:YES completion:nil];
}
#pragma mark-Text Field Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField.tag==1500||textField.tag==1501){
        
        textField.text=@"";
    }
    activeTextField=textField;
    if(activeTextField.tag==1001||activeTextField.tag==1002){
        [self presentSearchViewControllerWithTag:activeTextField.tag withText:activeTextField.text];
        [activeTextField resignFirstResponder];
        return  NO;
    }
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
  
//    if(textField.tag==1500){
//    cost=textField.text.intValue;
//    [textField setText:[NSString stringWithFormat:@"%d perseat",cost]];
//    }
//    else
    if(textField.tag==1501){
        milegae=textField.text.intValue;
        [textField setText:[NSString stringWithFormat:@"%d in litres",milegae]];
        [self getLocationLatLong:[textFieldTripDetails[1] text]];
        [self getLocationLatLong:[textFieldTripDetails[2] text]];
    }
    
    else if(textField.tag==1001){
        [self getLocationLatLong:textField.text];
    }
    
    return YES;
}
-(void)dismissKeyboard{
    [activeTextField resignFirstResponder];
}

#pragma mark-View Joinees
-(void)viewJoinees{
    CAViewJoineesViewController *viewJoinees=[self.storyboard instantiateViewControllerWithIdentifier:@"viewJoinees"];
    viewJoinees.trips=_trip;
    [self.navigationController pushViewController:viewJoinees animated:YES];
    
}
#pragma  mark-Accept RejectTrip
-(IBAction)acceptTrip:(UIButton *)sender{
  switch (sender.tag) {
      case 1001:
//          [self parseAcceptTrip:@"Accept"];
          [self parseAcceptTrip:@"Pending"];
          break;
      case 1002:
          [self parseAcceptTrip:@"Reject"];
          break;
          
      default:
          break;
  }
}
-(void)parseAcceptTrip:(NSString *)status{
    [CATrip acceptOrRejectTrip:_trip withStatus:status CompletionBlock:^(BOOL success, NSError *error) {
        if(success){
            if([status isEqualToString:@"Pending"]){
                
                [acceptTrip setEnabled:NO];
//                 [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Trip request accepted" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]show];
                [self performPaymentPage];
            }
            else{
                if(_isFromRequestPage){
                       [self.delegate actionAfterAcceptOrRejectTripwithIndexPathOfRowSelected:_indexPathOfRowSelected];
                       [self.navigationController popViewControllerAnimated:YES];
                }
                else{
                   [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Trip request rejected" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]show];
                 [self goToHomePage];
                }
            }
        }
        else{
            [CAServiceManager handleError:error];
             [self goToHomePage];
        }
       
    }];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self goToHomePage];

            break;
        case 1:{
            NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%@&saddr=Current+Location",_trip.StartingPlace];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            [self goToHomePage];

        }
            break;
            
        default:
            break;
    }
}
-(void)goToHomePage{
    CAAppDelegate * appDelegate = (CAAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate setHomePage];
}
#pragma mark-delegate
-(void)searchLocationWithAddress:(NSDictionary*)address withTextFieldTag:(NSUInteger)textFieldTag{
    UITextField *textField=(textFieldTag==1001)?textFieldTripDetails[1]:textFieldTripDetails[2];
    [textField setText:address[@"address"]];
}
#pragma mark-Paypal
-(void)performPaymentPage{
    // Paypal configuration
    if(!_payPalConfig)
    _payPalConfig = [[PayPalConfiguration alloc] init];
    _payPalConfig.acceptCreditCards = YES;
    _payPalConfig.languageOrLocale = @"en";
    _payPalConfig.merchantName = @"Awesome Shirts, Inc.";
    _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    _payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
    
    NSLog(@"PayPal iOS SDK version: %@", [PayPalMobile libraryVersion]);
    [self goToPayPalPage];

}

-(void)goToPayPalPage{
    
    PayPalItem *item = [PayPalItem itemWithName:_trip.tripName
                                       withQuantity:1
                                          withPrice:[NSDecimalNumber decimalNumberWithString:_trip.cost]
                                       withCurrency:@"USD"
                                            withSku:@""];
    
    NSArray *items = @[item];
    NSDecimalNumber *subtotal = [PayPalItem totalPriceForItems:items];
    
    // Optional: include payment details
    NSDecimalNumber *shipping = [[NSDecimalNumber alloc] initWithString:@"0"];
    NSDecimalNumber *tax = [[NSDecimalNumber alloc] initWithString:@"0"];
    PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subtotal
                                                                               withShipping:shipping
                                                                                    withTax:tax];
    
    NSDecimalNumber *total = [[subtotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = total;
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Total Amount";
    payment.items = items;  // if not including multiple items, then leave payment.items as nil
    payment.paymentDetails = paymentDetails; // if not including payment details, then leave payment.paymentDetails as nil
    
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
    [self.delegate actionAfterAcceptOrRejectTripwithIndexPathOfRowSelected:_indexPathOfRowSelected];
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
    [CAUser parsePaymentDetailsToBackEndWithTripId:_trip.tripId andTripName:_trip.tripName andAmount:_trip.cost WithCompletionBlock:^(BOOL success, NSError *error) {
        [SVProgressHUD dismiss];
        if(success){
                      if(_isFromRequestPage){
                          [self.delegate actionAfterAcceptOrRejectTripwithIndexPathOfRowSelected:_indexPathOfRowSelected];
                          [self.navigationController popViewControllerAnimated:YES];
       
                      }
                      else{
                      [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Trip Accepted" delegate:self cancelButtonTitle:@"Home Page" otherButtonTitles:@"Directions", nil]show];
                      }
        }
        else
            [CAServiceManager handleError:error];
        
    }];
    
}

#pragma mark - Calculate TripDistance And Cost
-(void)getLocationLatLong:(NSString *)string
{
    [SVProgressHUD showWithStatus:@"Estimating Cost Per Head..."];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:string completionHandler:^(NSArray *placemarks, NSError *error) {
        if([placemarks count]) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
            CLLocationCoordinate2D coordinate = location.coordinate;
            NSLog(@"coordinate = (%f, %f)", coordinate.latitude, coordinate.longitude);
            if([string isEqualToString:[textFieldTripDetails[1] text]])
            {
                startLat = coordinate.latitude;
                startLng = coordinate.longitude;
                
            }
            else if([string  isEqualToString:[textFieldTripDetails[2] text]])
            {
                destLat = coordinate.latitude;
                destLng = coordinate.longitude;
                
            }
        }
        [self getTheDistanceBetweenStartAndEndPointWith:startLat and:startLng and:destLat and:destLng];
    }];
}

-(void)getTheDistanceBetweenStartAndEndPointWith:(float)startLati and:(float)startLongi and:(float)destLati and:(float)destLongi{
    
    if(!startLati == 0 && !startLongi == 0 && !destLati ==0 && !destLongi == 0){
        
        NSString* sourcePoint = [NSString stringWithFormat:@"%f,%f",startLati, startLongi];
        NSString* destinationPoint = [NSString stringWithFormat:@"%f,%f", destLati, destLongi];
        NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", sourcePoint, destinationPoint];
        NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
        NSError *error;
        NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error];
        NSRegularExpression *distRegEx=[NSRegularExpression regularExpressionWithPattern:@"tooltipHtml:\"([^\"]*)\""options:0 error:NULL];
        NSTextCheckingResult *distmatch = [distRegEx firstMatchInString:apiResponse options:0 range:NSMakeRange(0, [apiResponse length])];
        NSString *dist= [apiResponse substringWithRange:[distmatch rangeAtIndex:0]];
        
        NSString *actualDistance;
        NSString *myString = dist;
        NSRange start = [myString rangeOfString:@"("];
        NSRange end = [myString rangeOfString:@")"];
        if (start.location != NSNotFound && end.location != NSNotFound && end.location > start.location) {
            actualDistance = [myString substringWithRange:NSMakeRange(start.location+1, end.location-(start.location+1))];
        }
        NSString *distComponent = [[actualDistance componentsSeparatedByString:@"/"] objectAtIndex:0];
        NSString *strKilometer = [distComponent stringByReplacingOccurrencesOfString:@" km" withString:@""];
        float miles = [strKilometer floatValue]*0.6214;
        [self calculateCostPerSeatUsing:miles];
   }

}

-(void)calculateCostPerSeatUsing:(float)totalMiles{
    
   if (totalMiles >= 1 && totalMiles < 25 ) {
        costPerHead = totalMiles * .50;
    }else if (totalMiles >= 25 && totalMiles < 50){
        costPerHead = totalMiles * .35;
    }else if (totalMiles >= 50 && totalMiles < 100){
        costPerHead = totalMiles * .28;
    }else if (totalMiles >= 100 && totalMiles < 200){
        costPerHead = totalMiles * .20;
    }else if (totalMiles >= 200){
        costPerHead = totalMiles * .15;
    }
    
    
    [textFieldTripDetails[8] setText:[NSString stringWithFormat:@"%.02f per seat",costPerHead]];
    [SVProgressHUD dismiss];
   
}

@end
