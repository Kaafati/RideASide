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
#import "CAInitialMapViewController.h"
#import "CAViewJoineesViewController.h"
#import "CAUser.h"
#import "CAAppDelegate.h"
#import "CASearchLocationViewController.h"
#import "CANavigationController.h"
#import "PayPalMobile.h"
#import <CoreLocation/CoreLocation.h>
#import "CAMapViewController.h"
#import "CAChatViewController.h"
#import "CACarCollectionViewCell.h"
#import "UIButton+WebCache.h"
#import "CAContainerViewController.h"
#import "CATripsViewController.h"

#define kPayPalEnvironment PayPalEnvironmentNoNetwork
#define alertTripAdd 324
@interface CATripDetailsTableViewController ()<UITextFieldDelegate,UIAlertViewDelegate,searchLocationDelegate,PayPalPaymentDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    IBOutletCollection(UITextField) NSArray *textFieldTripDetails;
    IBOutletCollection(UITableViewCell) NSArray *cellArray;
    __weak IBOutlet UIDatePicker *datePicker;
    __weak IBOutlet UIToolbar *toolBar;
    NSString *dateOfTrip,*dateForPushNotification;
    UITextField *activeTextField;
    IBOutlet UIButton *addTripOrViewJoiness;
    IBOutlet UIButton *acceptTrip;
    UIImage *imageCar;
    IBOutletCollection(UIButton) NSArray *buttonsInfoArray;
    __weak IBOutlet UIButton *buttonChatOrEdit;
    __weak IBOutlet UIButton *rejectButton;
    IBOutlet UIStepper *stepper;
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UICollectionView *collectionCar;
    NSInteger milegae;
    float startLat, startLng, destLat, destLng ,costPerHead;;
    NSArray *arraycarMakes,*arraycarModels;
    UIPickerView *pickerViewVehicle ;
    NSString *stringCarMakes,*stringCarModels;
    NSArray *information;
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
     information=@[@"Trip name",@"Starting place",@"Destination",@"Distance",@"Vehicle",@"Vehicle Number",@"Cost",@"Number of seats",@"Trip date"];
    [super viewDidLoad];

    [self pickerUI];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
   
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
   
      [collectionCar reloadData];
    (_trip.tripPostedById.length>0&&!_isFromRequestPage)?[self leftSideNavigationBar]: [self setupMenuBarButtonItems];
    [self setUI];

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    UIView *viewRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightbarbutton.frame =CGRectMake(30, 0, 80, 30) ;
    [rightbarbutton setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
    [rightbarbutton addTarget:self action:@selector(goToMapPage) forControlEvents:UIControlEventTouchUpInside];
    [viewRight addSubview:rightbarbutton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:viewRight];
}
- (IBAction)showView:(UIButton *)sender {
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:information[[buttonsInfoArray indexOfObject:sender]] action:@selector(menuItemClicked:)];
    menuController.arrowDirection = UIMenuControllerArrowUp;
    [menuController setMenuItems:@[resetMenuItem]];
    [menuController setTargetRect:CGRectZero inView:sender.viewForBaselineLayout];
    [menuController setMenuVisible:YES animated:YES];
}
-(void)menuItemClicked:(id)sender
{
   
}
-(BOOL)canBecomeFirstResponder
{
    return YES;
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
            initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)backBarButtonItem {
    [activeTextField resignFirstResponder];
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

-(void)setUI{
    /*Removed the fuel field and toll field on 6 jun -15 and modified the textField arrayPositions */

   
    
    
    
    milegae=0;
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    NSArray *images=@[@"tripName",@"startingplace",@"end",@"distance",@"vehicle",@"vehicleNumber",@"cost",@"seats",@"date"];
    if(_trip)
    {
        self.title=@"Trip Details";
        if (_trip.UserId.integerValue == [CAUser sharedUser].userId.integerValue) {
            
           
            acceptTrip.frame = CGRectMake(buttonChatOrEdit.frame.origin.x, acceptTrip.frame.origin.y, buttonChatOrEdit.frame.size.width, acceptTrip.frame.size.height);
            [acceptTrip setTitle:@"Edit Trip Detail" forState:UIControlStateNormal];
            rejectButton.hidden = YES;

            acceptTrip.autoresizingMask = buttonChatOrEdit.autoresizingMask;
            
        }
        else
        {

            acceptTrip.hidden = NO;
            rejectButton.hidden = NO;
            
        }
        
        [buttonChatOrEdit setTitle:@"Chat" forState:UIControlStateNormal];
        [addTripOrViewJoiness setTitle:@"View Joinees" forState:UIControlStateNormal];

//        if ([_trip.category isEqualToString:@"Passenger"]) {
//            [addTripOrViewJoiness setTitle:@"View Drivers" forState:UIControlStateNormal];
//            
//            
//            
//        }else{
//        [addTripOrViewJoiness setTitle:@"View Joinees" forState:UIControlStateNormal];
//        }
//        [addTripOrViewJoiness setFrame:CGRectMake(35, 0, 115, 40)];
//        UIButton *btnViewDrivers = [[UIButton alloc]initWithFrame:CGRectMake(170, 0, 115, 40)];
//        [btnViewDrivers setTitle:@"View Drivers" forState:UIControlStateNormal];
//        [btnViewDrivers.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:15]];
//        [btnViewDrivers setBackgroundColor:[UIColor colorWithRed:25/255.0 green:124/255.0 blue:204/255.0 alpha:1]];
//        [btnViewDrivers addTarget:self action:@selector(addTripOrViewJoinees:) forControlEvents:UIControlEventTouchUpInside];
//        [cellArray[0] addSubview:btnViewDrivers];
    }
    else
    {
        self.title=@"Add Trip";
        [addTripOrViewJoiness setTitle:@"Add Trip" forState:UIControlStateNormal];
    }
//    [textFieldTripDetails[3] setInputAccessoryView:toolBar];
    [textFieldTripDetails[3] setInputAccessoryView:toolBar];
    [textFieldTripDetails[4] setInputAccessoryView:toolBar];
    [textFieldTripDetails[5] setInputAccessoryView:toolBar];
    [textFieldTripDetails[6] setInputAccessoryView:toolBar];

    [(UITextField *)textFieldTripDetails[4] setInputView:collectionCar];
    [(UITextField *)textFieldTripDetails[5] setInputView:collectionCar];
    [textFieldTripDetails enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
        
        if(_trip){
            textField.userInteractionEnabled= NO;
            
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
    
    if(_trip)//View Trip
    {
        
        [textFieldTripDetails[0] setText:_trip.tripName];
        [textFieldTripDetails[1] setText:_trip.StartingPlace];
        [textFieldTripDetails[2] setText:_trip.EndPlace];
       
        [textFieldTripDetails[3] setText:_trip.TotalKilometer];
        [textFieldTripDetails[4] setText:_trip.Vehicle];
        [textFieldTripDetails[5] setText:_trip.vehicleNumber];
        [textFieldTripDetails[6] setText:[NSString stringWithFormat:@"%@ per seat",_trip.cost]];
        [textFieldTripDetails[7] setText:_trip.SeatsAvailable];
        [textFieldTripDetails[8] setText:_trip.alertDate.length ? _trip.alertDate : _trip.date];
        [stepper setHidden:YES];
        [segmentControl setHidden:YES];
        [acceptTrip setEnabled:YES];
       

        if(_trip.tripPostedById.length>0){
            [cellArray[0] setHidden:YES];
        }
        else{
           
            

         //   [acceptTrip setFrame:CGRectMake(addTripOrViewJoiness.frame.origin.x,10, addTripOrViewJoiness.bounds.size.width , addTripOrViewJoiness.frame.size.height)];
//            [acceptTrip setTitle:@"Pay For Trip" forState:UIControlStateNormal];
//            [rejectButton setHidden:YES];
            //[cellArray[1] setHidden:YES];
        }
        
         UIView *viewRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightbarbutton.frame =CGRectMake(30, 0, 80, 30) ;
        [rightbarbutton setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
        [rightbarbutton addTarget:self action:@selector(goToMapPage) forControlEvents:UIControlEventTouchUpInside];
        [viewRight addSubview:rightbarbutton];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:viewRight];
        
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
        [textFieldTripDetails[4] setInputAccessoryView:toolBar];
        [textFieldTripDetails[6] setInputAccessoryView:toolBar];
        [textFieldTripDetails[7] setText:@"1"];
        stepper.minimumValue = 1;
        stepper.maximumValue = 6;
        stepper.stepValue = 1;
        
        UITextField *textField=textFieldTripDetails[8];
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

#pragma mark - Actions

-(IBAction)addTripOrViewJoinees:(UIButton *)sender
{
    [activeTextField resignFirstResponder];
    if(_trip){
        [self viewJoinees];
    }
    else{
        [self addTripDetails];
    }
}
- (IBAction)buttonChatOrEditPressed:(UIButton *)sender {
    
    if ([[sender titleForState:UIControlStateNormal]  isEqual: @"Chat"]) {
        CAChatViewController *chatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CAChatViewController"];
        chatViewController.tripId = _trip.tripId;
        [self.navigationController pushViewController:chatViewController animated:true];
    }
    else{
     
        if (sender.tag == 0) {
            sender.tag = 1;
            [self enableInteration:YES];
           [sender setTitle:@"Update Trip Detail" forState:UIControlStateNormal];
        }
        else{
            sender.tag = 0;
            [self enableInteration:NO];
            [SVProgressHUD show];
            [self updateTripDetail];
        }
    }
}
-(void)updateTripDetail
{
    CATrip *trip = [[CATrip alloc]init];
    trip.tripName=[textFieldTripDetails[0] text];
    trip.StartingPlace=[textFieldTripDetails[1] text];
    trip.EndPlace=[textFieldTripDetails[2] text];
    //   trip.FuelExpenses=[NSString stringWithFormat:@"%d",milegae];
  
    trip.TotalKilometer=[textFieldTripDetails[3] text];
    trip.Vehicle=[textFieldTripDetails[4] text];
    trip.vehicleNumber=[textFieldTripDetails[5] text];
    trip.cost=[NSString stringWithFormat:@"%.02f",costPerHead];
    trip.SeatsAvailable=[textFieldTripDetails[7] text];
    trip.date=[textFieldTripDetails[8] text];
    [self performSelector:@selector(doneSelectingDate:) withObject:nil];
    trip.tripStartTimeForNotification=dateForPushNotification;
    trip.tripId = _trip.tripId;
    trip.imageCar = imageCar;
    [acceptTrip setTitle:@"Edit Trip Detail" forState:UIControlStateNormal];
    [CATrip editTrip:trip completion:^(BOOL success, id result, NSError *error) {
        [SVProgressHUD dismiss];

        if (success==true) {
            
            [self.changedTripDelegate changedTrip:(CATrip *)result inIndex:_row];
            NSLog(@"result %@",[result valueForKey:@"tripName"]);
        }
    }];
}
-(void)enableInteration:(BOOL)interaction
{
        [textFieldTripDetails enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
        
        if(interaction == true){
            textField.userInteractionEnabled= YES ;
            
            textField.delegate=self;
            
        }
        else{
            textField.userInteractionEnabled= NO ;

        }
        
       
        
    }];
    
    if(interaction==false)
    {
        
//        [textFieldTripDetails[0] setText:_trip.tripName];
//        [textFieldTripDetails[1] setText:_trip.StartingPlace];
//        [textFieldTripDetails[2] setText:_trip.EndPlace];
//        [textFieldTripDetails[3] setText:[NSString stringWithFormat:@"%@ in litres",_trip.FuelExpenses]];
//        [textFieldTripDetails[4] setText:_trip.TollBooth];
//        [textFieldTripDetails[5] setText:_trip.TotalKilometer];
//        [textFieldTripDetails[6] setText:_trip.Vehicle];
//        [textFieldTripDetails[7] setText:_trip.vehicleNumber];
//        [textFieldTripDetails[8] setText:[NSString stringWithFormat:@"%@ per seat",_trip.cost]];
//        [textFieldTripDetails[9] setText:_trip.SeatsAvailable];
//        [textFieldTripDetails[10] setText:_trip.date];
        [stepper setHidden:YES];
        [segmentControl setHidden:YES];
       // [acceptTrip setEnabled:YES];
        
       
    }
    else
    {

        [textFieldTripDetails[3] setInputAccessoryView:toolBar];
        [textFieldTripDetails[6] setInputAccessoryView:toolBar];
        
        UITextField *textField=textFieldTripDetails[8];
        textField.inputView=datePicker;
        textField.inputAccessoryView=toolBar;
        datePicker.minimumDate=[NSDate date];
        
        textField.delegate=self;
        [stepper setHidden:NO];
        [segmentControl setHidden:NO];
      //  [acceptTrip setEnabled:NO];
        
        
    }
   
    
}

#pragma mark-Add Trip Details

- (IBAction)stepperChanged:(UIStepper *)sender {
    NSUInteger value = sender.value;
    
    [textFieldTripDetails[7] setText:[NSString stringWithFormat:@"%zd",value]];
}

-(IBAction)segmentValueChanged:(UISegmentedControl *)sender{
//    [textFieldTripDetails[4] setText:[sender titleForSegmentAtIndex:sender.selectedSegmentIndex]];
}

-(IBAction)doneSelectingDate:(id)sender{
    [activeTextField resignFirstResponder];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [textFieldTripDetails[8] setText:[NSString stringWithFormat:@"%@",
                                       [dateFormatter stringFromDate:datePicker.date]]];
    dateOfTrip=[[NSDate alloc]changeLocalTimeZoneToServerForDate:[NSString stringWithFormat:@"%@",
                                                                  [dateFormatter stringFromDate:datePicker.date]]];
    
    NSDate *dateOfSelected=[datePicker.date dateByAddingTimeInterval:-300];
    dateForPushNotification=[[NSDate alloc]changeLocalTimeZoneToServerForDate:[NSString stringWithFormat:@"%@",
                                                                               [dateFormatter stringFromDate:dateOfSelected]]];
    
}

-(void)addTripDetails{
//    if( [textFieldTripDetails[0] text].length>0&&[textFieldTripDetails[1] text].length>0&&[textFieldTripDetails[2] text].length>0&&[textFieldTripDetails[3] text].length>0&&[textFieldTripDetails[4] text].length>0&&[textFieldTripDetails[6] text].length>0&&[textFieldTripDetails[7] text].length>0&&[textFieldTripDetails[8] text].length>0&&[textFieldTripDetails[9] text].length>0&&[textFieldTripDetails[10] text].length>0)
//    {
//        [SVProgressHUD showWithStatus:@"Adding Trip Details..."];
//        [self parseAddTrip];
//    }
//    else
//        [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please fill all fields" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]show];
   [textFieldTripDetails[3] setText:@"1"];
  
if( [textFieldTripDetails[0] text].length>0&&[textFieldTripDetails[1] text].length>0&&[textFieldTripDetails[2] text].length>0&&[textFieldTripDetails[4] text].length>0&&[textFieldTripDetails[5] text].length>0&&[textFieldTripDetails[6] text].length>0&&[textFieldTripDetails[8] text].length>0)
            {
                [self parseAddTrip];
            }
    else
    {
        [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please fill all fields" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]show];
[textFieldTripDetails enumerateObjectsUsingBlock:^(UITextField * obj, NSUInteger idx, BOOL *stop) {
    
    
    if (!obj.text.length  /*|| idx!=3 MilageTextField(Cause hiding the cell for some )*/) {
        
        NSMutableAttributedString *text =[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",[obj.placeholder hasPrefix:@"!"] ? @"" : @"! ",obj.placeholder]];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(obj.attributedText.length, 1)];
        [obj setAttributedPlaceholder:text];
        
    }
    
}];
    }

    
}


-(void)goToMapPage{
    [activeTextField resignFirstResponder];
    CAMapViewController *mapViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"mapView"];
    mapViewController.trips=_trip;
    mapViewController.isFromTripDetails = YES;
    [self.navigationController pushViewController:mapViewController animated:YES];
}

-(void)parseAddTrip{
   if([[textFieldTripDetails[6] text] intValue] == 0)
   {
       [textFieldTripDetails[6] setText:@""];
       [[[UIAlertView alloc] initWithTitle:@"" message:@"Please give a valid amount" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil] show];
       return;
   }
    [SVProgressHUD showWithStatus:@"Adding Trip Details..."];

    CATrip *trip=[[CATrip alloc]init];
    trip.tripName=[textFieldTripDetails[0] text];
    trip.StartingPlace=[textFieldTripDetails[1] text];
    trip.EndPlace=[textFieldTripDetails[2] text];
    //   trip.FuelExpenses=[NSString stringWithFormat:@"%d",milegae];
//    trip.FuelExpenses=[textFieldTripDetails[3] text];
//    trip.TollBooth=[textFieldTripDetails[4] text];
    trip.TotalKilometer=[textFieldTripDetails[3] text];
    trip.Vehicle=[textFieldTripDetails[4] text];
    trip.vehicleNumber=[textFieldTripDetails[5] text];
  //  trip.cost=[NSString stringWithFormat:@"%.02f",costPerHead];
   trip.cost= [textFieldTripDetails[6] text]; 
    trip.SeatsAvailable=[textFieldTripDetails[7] text];
    trip.date=dateOfTrip;
    trip.tripStartTimeForNotification=dateForPushNotification;
    trip.addedBy = [CAUser sharedUser].category;
    trip.imageCar = imageCar;

    [trip addTripWithDataWithTrip:trip
                  CompletionBlock:^(BOOL success, id result, NSError *error) {
                      [SVProgressHUD dismiss];
                      if(success){
                         UIAlertView *alertTripAdded =  [[UIAlertView alloc] initWithTitle:@"" message:@"Trip Created Successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] ;
                          alertTripAdded.tag = alertTripAdd;
                          [alertTripAdded show];
                          
                          
                          
                          
                          [self.tabBarController setSelectedIndex:0];
                          
//
//                          UINavigationController *navigation = (UINavigationController *)self.tabBarController.viewControllers[0];
//                          
//                          CAContainerViewController *container = (CAContainerViewController *)[navigation. viewControllers objectAtIndex:0];
//                          [container performSelector:@selector(SwitchToViewController:) withObject:[NSNumber numberWithInt:1]];
                         
                          
                          [textFieldTripDetails enumerateObjectsUsingBlock:^(UITextField *obj, NSUInteger idx, BOOL *stop) {
                              
                              NSMutableAttributedString *text =[[NSMutableAttributedString alloc] initWithString:[obj.placeholder stringByReplacingOccurrencesOfString:@"! " withString:@""]];
                              [obj setAttributedPlaceholder:text];
                              obj.text= idx == 7 ? @"1" : @"";

                          }];
                          
//                          [textFieldTripDetails[4] setText:@"Yes"];
//                          segmentControl.selectedSegmentIndex=0;
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
    
   if ([textField.text isEqualToString:@"!"]) textField.text = @"";
       
    if(textField.tag==1500||textField.tag==1501){
        
        textField.text=@"";
    }
    activeTextField=textField;
    if (activeTextField.tag==777 || textField == textFieldTripDetails[4]) {
        if ([[[CAUser sharedUser] arrayCar] count]) {
                       textField.inputView = collectionCar;

        }
        else
        {
            [textField resignFirstResponder];
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Please add your car in your profile" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
//            activeTextField.inputView = pickerViewVehicle;

        }
    }
//    if ((textField == textFieldTripDetails[5]) && ([[[CAUser sharedUser] arrayCar] count])) {
//        textField.inputView = collectionCar;
//    }
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
    
    if(textField.tag==1500 && textField.text.intValue == 0){
        
        
    }
    if(textField.tag==1501){
        milegae=textField.text.intValue;
        [textField setText:[NSString stringWithFormat:@"%zd in litres",milegae]];
        [self getLocationLatLong:[textFieldTripDetails[1] text]];
        [self getLocationLatLong:[textFieldTripDetails[2] text]];
    }
    
    //    else if(textField.tag==1001){
    //        [self getLocationLatLong:textField.text];
    //    }
    
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
            NSLog(@"_trip.category %@",_trip.category);
            //          [self parseAcceptTrip:@"Accept"];
            if ([acceptTrip.titleLabel.text isEqualToString:@"Accept"]) {
                [self parseAcceptTrip:@"Accept"];
               // [self performPaymentPage];
            }
            else if ([acceptTrip.titleLabel.text isEqualToString:@"Reject"])
            {
                 [self parseAcceptTrip:@"Decline"];
            }
            else if ([acceptTrip.titleLabel.text isEqualToString:@"Edit Trip Detail"])
            {
                
                [self enableInteration:YES];
                [sender setTitle:@"Update Trip Detail" forState:UIControlStateNormal];
                
                

                
                
            }
            else if ([acceptTrip.titleLabel.text isEqualToString:@"Update Trip Detail"])
            {
                [self enableInteration:NO];
                [SVProgressHUD show];
                [self updateTripDetail];
            }
        /*    else{
                [_trip.category isEqualToString:@"Passenger"] ? [self parseAcceptDriverOnTrip:@"Added"] :[self parseAcceptTrip:@"Pending"];
            }*/
            break;
        case 1002:
            NSLog(@"_trip.category %@",_trip.category);
            [self parseAcceptTrip:@"Decline"];
         //   [_trip.category isEqualToString:@"Passenger"] ? [self parseAcceptDriverOnTrip:@"reject"] :[self parseAcceptTrip:@"Reject"];
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
                //              [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Trip request accepted" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]show];
              //  [self performPaymentPage];
            }
            else{
                if(_isFromRequestPage){
                    [self.delegate actionAfterAcceptOrRejectTripwithIndexPathOfRowSelected:_indexPathOfRowSelected];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else{
                    [[[UIAlertView alloc]initWithTitle:@"Message" message:@"You have added in the trip" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]show];
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

-(void)parseAcceptDriverOnTrip:(NSString *)status{
    
    [CATrip acceptOrRejectTripForDriver:_trip withStatus:status completion:^(bool success, NSError *error) {
        if(success){
            if([status isEqualToString:@"Added"]){
                [acceptTrip setEnabled:NO];
                [self goToHomePage];
            }else{
                [[[UIAlertView alloc]initWithTitle:@"Message" message:@"Trip request rejected" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil]show];
                [self goToHomePage];
            }
        }else{
            [CAServiceManager handleError:error];
            [self goToHomePage];
        }
        
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (alertView.tag != alertTripAdd) {
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
    
    if(_trip.cost.integerValue < 1)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please give the valid amount" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil] show];
        return;
    }
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
    NSInteger cost = [_trip.cost integerValue];
    PayPalItem *item;
    if (cost==0) {
        item = [PayPalItem itemWithName:_trip.tripName
                           withQuantity:1
                              withPrice:[NSDecimalNumber decimalNumberWithString:@"10"]
                           withCurrency:@"USD"
                                withSku:@""];
    }else{
               item = [PayPalItem itemWithName:_trip.tripName
                                  withQuantity:1
                                     withPrice:[NSDecimalNumber decimalNumberWithString:_trip.cost]
                                  withCurrency:@"USD"
                                       withSku:@""];

    }
    
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

#pragma mark - Table View Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if(cell.tag == 500)
    {
        [cell setHidden:YES];
        return 0; //HIDE MILEAGE CELL SESSION as per CLIENT;
    }
    else
    {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
       
        
        
    }
}



#pragma mark pickerDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if (component==0) {
        stringCarMakes = arraycarMakes[row];
        
    }
    else
    {
        stringCarModels =arraycarModels[row];
        
    }
    
    activeTextField.text = [NSString stringWithFormat:@"%@-%@",stringCarMakes,stringCarModels] ;
    return component==0 ? arraycarMakes[row] : arraycarModels[row];
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return component == 0 ? arraycarMakes.count : arraycarModels.count;
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (component==0) {
        arraycarModels  =[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Cars" ofType:@"plist"]] valueForKeyPath:[NSString stringWithFormat:@"CarMakes.%@",arraycarMakes[row]]];
        [pickerView reloadAllComponents];
    }
    
    
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
    return 2;
}



#pragma mark CollectionViewDelegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CACarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CACarCollectionViewCell" forIndexPath:indexPath];
    NSLog(@"Url %@",[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",carUrl,[[[[CAUser sharedUser] arrayCar]  valueForKey:[NSString stringWithFormat:@"car%dDetails",indexPath.row+1]] objectAtIndex:0]]]);
    if ([[[[[CAUser sharedUser] arrayCar] valueForKey:@"car1Details"] objectAtIndex:0] isKindOfClass:[UIImage class]]) {
        [cell.buttonCar setBackgroundImage:[[[CAUser sharedUser] arrayCar] valueForKey:[NSString stringWithFormat:@"car%dDetails",indexPath.row+1]][0] forState:UIControlStateNormal];
    }
    else
    {
    [cell.buttonCar sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",carUrl,[[[[CAUser sharedUser] arrayCar]  valueForKey:[NSString stringWithFormat:@"car%dDetails",indexPath.row+1]] objectAtIndex:0]]] forState:UIControlStateNormal];
    }
   // [cell.buttonCar setBackgroundImage:[[[[CAUser sharedUser] arrayCar] valueForKey:@"car1Details"] objectAtIndex:0] forState:UIControlStateNormal];
    cell.textFieldcarName.text = [[[[CAUser sharedUser] arrayCar]  valueForKey:[NSString stringWithFormat:@"car%dDetails",indexPath.row+1]] objectAtIndex:1];
    cell.textFieldCarLicencePlate.text = [[[[CAUser sharedUser] arrayCar]  valueForKey:[NSString stringWithFormat:@"car%dDetails",indexPath.row+1]]  objectAtIndex:2];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    

    CACarCollectionViewCell *cell = (CACarCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [(UITextField *)textFieldTripDetails[4] setText:cell.textFieldcarName.text];
        [(UITextField *)textFieldTripDetails[5] setText:cell.textFieldCarLicencePlate.text];
    imageCar = [cell.buttonCar backgroundImageForState:UIControlStateNormal];
    [self.view endEditing:YES];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [(NSDictionary *)[[CAUser sharedUser] arrayCar] allKeys].count;
}


@end
