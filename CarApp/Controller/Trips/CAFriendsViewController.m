//
//  CAFriendsViewController.m
//  RoadTrip
//
//  Created by Srishti Innovative on 12/06/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import "CAFriendsViewController.h"
#import "CAContacts.h"
#import "MFSideMenu.h"
#import "CATripsViewController.h"
#import "CATripSelectionCell.h"
#import "CATripCell.h"
#import "CATrip.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "CAUser.h"
#import "CAContactCell.h"
#import "CATabBarController.h"
@import MessageUI;

@interface CAFriendsViewController ()<MFMessageComposeViewControllerDelegate,UISearchBarDelegate>
{
    NSArray *arrayContact,*arrSearchContacts;
    __weak IBOutlet UITableView *tableViewFriends;
    NSMutableArray *arraySelectedFriends;
    NSMutableArray *arrayTrip,*arrayAppUsers;
    IBOutlet UIImageView *imageViewBackGround;
    BOOL searchStatus;
    NSString *searchTxt;
    IBOutlet UIToolbar *toolBarDone;
    
}
@end

@implementation CAFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
       // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.title = @"Friends";
    arraySelectedFriends ? [arraySelectedFriends removeAllObjects] : ({arraySelectedFriends = [NSMutableArray new]; });
    
    arrayTrip ? [arrayTrip removeAllObjects] :({ arrayTrip  = [NSMutableArray new];});
    arrayAppUsers ? [arrayAppUsers removeAllObjects] : ({ arrayAppUsers = [NSMutableArray new];});
    [imageViewBackGround setImage:[UIImage imageNamed:@"background"]];
    //    [imageViewBackGround sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,[CAUser sharedUser].profile_ImageName]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    arrayContact = [[CAContacts getcontact] sortedArrayUsingDescriptors:@[sort]];
    
    [tableViewFriends reloadData];
    [self fetchtrip];
    // NSLog(@"%@",[CAContacts getcontact]);
    [self setupMenuBarButtonItems];

}

-(void)fetchtrip
{
    CATrip *trip=[[CATrip alloc]init];
   
    [SVProgressHUD show];
    [trip getTripDetailswithPath:@"view_trip.php" withSearchString:@"" withIndex:0 withMiles:40 withOptionForTripDetailIndex:0  withCompletionBlock:^(BOOL success, id result,id result2, NSError *error) {
        [self fetchAppUsers];
        NSArray *arrayDataList=(NSArray *)result;
        if (success) {
            
            [arrayDataList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [arrayTrip addObject:obj];
            }];
        }
        [tableViewFriends reloadData];
        
    }];
}

-(void)fetchAppUsers
{
       [CAUser listTheAppUserwithCompletionBlock:^(bool success, id result, NSError * error) {
        NSLog(@"result %@",result);

        [SVProgressHUD dismiss];
        NSArray *arrayDataList=(NSArray *)result;
        if (success) {
            
            [arrayDataList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [arrayAppUsers addObject:obj];
            }];
        }
        [tableViewFriends reloadData];
    }];
//    [trip getTripDetailswithPath:@"view_all_trip.php" withSearchString:@"" withIndex:0 withOptionForTripDetailIndex:0 withCompletionBlock:^(BOOL success, id result,id  result2, NSError *error) {
//        
//        [SVProgressHUD dismiss];
//        NSArray *arrayDataList=(NSArray *)result;
//        if (success) {
//            
//            [arrayDataList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                [arrayAppUsers addObject:obj];
//            }];
//        }
//        [tableViewFriends reloadData];
//        
//    }];

}
- (void)setupMenuBarButtonItems {
    
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
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
                                           action:@selector(popViewController)];
}
-(void)popViewController
{
     UINavigationController *navigation = self.tabBarController.moreNavigationController;
    [navigation popViewControllerAnimated:NO];
    
}
- (UIBarButtonItem *)rightMenuBarButtonItem {
    return  [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStyleBordered target:self action:@selector(inviteuser:)];
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

#pragma mark -
#pragma mark - UIBarButtonItem Callbacks
-(void)inviteuser:(id)sender {
    [arraySelectedFriends removeAllObjects];
    NSPredicate *predicateTrip = [NSPredicate predicateWithFormat:@"isSelected == YES"];
    NSPredicate *predicateContact = [NSPredicate predicateWithFormat:@"isContactSelected == YES"];
    NSPredicate *predicateAppUser = [NSPredicate predicateWithFormat:@"isSelected == YES"];
    
    if (![arrayTrip filteredArrayUsingPredicate:predicateTrip].count) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please select the ride" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    [arraySelectedFriends addObjectsFromArray:@[[arrayTrip filteredArrayUsingPredicate:predicateTrip],[arrayContact filteredArrayUsingPredicate:predicateContact],[arrayAppUsers filteredArrayUsingPredicate:predicateAppUser]]];
   // NSLog(@"Selected %@",arraySelectedFriends);
//    if (![arrayContact filteredArrayUsingPredicate:predicateContact].count) {
//        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please select the contacts" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
//        return;
//    }
    
    if ([arraySelectedFriends count] && [arraySelectedFriends[1] count] && ![arraySelectedFriends[2] count] ) {
       
         [self showSMS:[[arrayContact filteredArrayUsingPredicate:predicateContact] valueForKey:@"phoneNumber"]];
    }
    else if ([arraySelectedFriends count] && ![arraySelectedFriends[1] count] && [arraySelectedFriends[2] count]) {
        
        CATrip *numberOfSeats = (CATrip *)arraySelectedFriends[0][0];
        NSLog(@"%@",[[arraySelectedFriends[2] valueForKey:@"userId"] componentsJoinedByString:@","]);
        if(numberOfSeats.SeatsAvailable.integerValue ==0)
        {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Seats not available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            
            return;
        }
        else
        {
           
            numberOfSeats.SeatsAvailable.integerValue >= [arraySelectedFriends[2] count] ? [self inviteAppUserWithTripId:numberOfSeats.tripId andAppUserId:[[arraySelectedFriends[2] valueForKey:@"userId"] componentsJoinedByString:@","]] : [[UIAlertView alloc] initWithTitle:@"" message:numberOfSeats.SeatsAvailable.integerValue >1 ? [NSString stringWithFormat:@"%lu seats are not available \n Please select %@ person",(unsigned long)[arraySelectedFriends[2] count],numberOfSeats.SeatsAvailable] : [NSString stringWithFormat:@"%lu seat is not available \n Please select %@ person",(unsigned long)[arraySelectedFriends[2] count],numberOfSeats.SeatsAvailable]  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil].show;
        }
    }
    else if (![arraySelectedFriends[1] count] && ![arraySelectedFriends[2] count])
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please Select the User from contact or app user" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
 
    }
   else
   {
       [[[UIAlertView alloc] initWithTitle:@"" message:@"Can not send invites to multiple groups" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
       return;
   }
  
}

-(void)inviteAppUserWithTripId:(NSString *)tripId andAppUserId:(NSString *)appsuerId
{
    [SVProgressHUD show];
    [CATrip inviteTripWithTripId:tripId andAppuserId:appsuerId completion:^(BOOL success, id result, NSError *error) {
        [SVProgressHUD dismiss];
        if (success) {
        }
    }];
}

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {

    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return section == 0 ? arrayTrip.count : section==1 ? arrayAppUsers.count : (searchStatus == true) ? arrSearchContacts.count : arrayContact.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2){
        return 100;
    }else{
        return 50;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerVw = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 100)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 50)];
    label.text=section == 0 ?  @"Rides" : section ==1 ? @"App User" : @"Contacts";
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor whiteColor];
    label.textAlignment= NSTextAlignmentCenter;
    [headerVw addSubview:label];
    [label setBackgroundColor:[UIColor colorWithRed:25.0/255 green:124.0/255 blue:204.0/255 alpha:1]];
    if (section == 2){
        UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, label.frame.size.height,CGRectGetWidth(self.view.frame), 40)];
        searchBar.delegate = self;
        
//        if (![searchTxt isEqualToString:@""] && searchTxt != nil){
//            [searchBar becomeFirstResponder];
//        }
        [searchBar setText:searchTxt];
        [searchBar setInputAccessoryView:toolBarDone];
        [headerVw addSubview:searchBar];
    }
    return headerVw;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0) {
        CATrip *trip = arrayTrip[indexPath.row];
        CATripSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CATripSelectionCell"];
        
        cell.labelTrip.text = trip.tripName;
        [cell.imageUserPicture sd_setBackgroundImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,trip.imageName]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"] ];
        cell.backgroundColor = [UIColor clearColor];
        cell.imageUserPicture.layer.cornerRadius = cell.imageUserPicture.frame.size.height / 2;
        cell.imageUserPicture.clipsToBounds=YES;
        [cell.imageUserPicture.layer setBorderColor:[UIColor whiteColor].CGColor];
        cell.imageUserPicture.layer.borderWidth=2;
        cell.accessoryType =  trip.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
        return cell;
    }
    else if(indexPath.section ==1)
    {
        CATripCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellAppUser"];
        CAUser *appUsers = arrayAppUsers[indexPath.row];
        
        cell.labelTrip.text = appUsers.userName;
        [cell.imageUserPicture sd_setBackgroundImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,appUsers.profile_ImageName]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"] ];
        cell.imageUserPicture.layer.cornerRadius = cell.imageUserPicture.frame.size.height / 2;
        cell.imageUserPicture.clipsToBounds=YES;
        [cell.imageUserPicture.layer setBorderColor:[UIColor whiteColor].CGColor];
        cell.imageUserPicture.layer.borderWidth=2;
        cell.accessoryType =  appUsers.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
        return cell;
       
    }
    else
    {
        CAContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CAContactCell"];
        CAContacts *contact;
        if (searchStatus == true){
            contact = arrSearchContacts[indexPath.row];
        }else{
            contact = arrayContact[indexPath.row];
        }
        
        cell.labelContactName.text = [NSString stringWithFormat:@"Name : %@",contact.fullName];
        
        cell.labelContactPhoneNumber.text = [NSString stringWithFormat:@"Phone Number : %@",contact.phoneNumber];
        cell.accessoryType =  contact.isContactSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        // Configure the cell...
        
        cell.imageViewContact.image = (UIImage *)contact.image;
        cell.imageViewContact.layer.cornerRadius = cell.imageViewContact.frame.size.height / 2;
        cell.imageViewContact.clipsToBounds = YES;
        [cell.imageViewContact.layer setBorderColor:[UIColor whiteColor].CGColor];
        cell.imageViewContact.layer.borderWidth=2;
        
        return cell;

    }
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        
        CATripSelectionCell *cell = (CATripSelectionCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType =  cell.accessoryType == UITableViewCellAccessoryCheckmark  ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
        CATrip *trip = arrayTrip[indexPath.row];
        
        trip.isSelected =  cell.accessoryType == UITableViewCellAccessoryCheckmark  ? YES : NO;
        
        NSPredicate *predicateAppUser = [NSPredicate predicateWithFormat:@"isSelected == YES"];
        ;
        [[arrayTrip filteredArrayUsingPredicate:predicateAppUser] count] ? [[arrayTrip filteredArrayUsingPredicate:predicateAppUser] enumerateObjectsUsingBlock:^(CATrip * obj, NSUInteger idx, BOOL *stop) {
            cell.accessoryType = obj == trip ?  UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            if (obj !=trip) {
                obj.isSelected = false;
            }
            
        }] : nil;
        
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if(indexPath.section==1)
    {
        CATripCell *cell = (CATripCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType =  cell.accessoryType == UITableViewCellAccessoryCheckmark  ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
        CAUser *trip = arrayAppUsers[indexPath.row];
        
        trip.isSelected =  cell.accessoryType == UITableViewCellAccessoryCheckmark  ? YES : NO;

    }
    else
    {
        CAContactCell *cell = (CAContactCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType =  cell.accessoryType == UITableViewCellAccessoryCheckmark  ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
        CAContacts *contact;
        if (searchStatus == true){
            contact = arrSearchContacts[indexPath.row];
        }else{
            contact = arrayContact[indexPath.row];
        }
        contact.isContactSelected =  cell.accessoryType == UITableViewCellAccessoryCheckmark  ? YES : NO;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            [arrayTrip setValue:[NSNumber numberWithBool:false] forKey:@"isSelected"];
            [arrayContact setValue:[NSNumber numberWithBool:false] forKey:@"isContactSelected"];
            [tableViewFriends reloadData];

            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    

}
- (void)showSMS:(NSArray*)contacts {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    
    NSArray *recipents = contacts;
    NSString *message = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/ride-aside-car-pooling/id995927527?ls=1&mt=8"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

#pragma mark - SearchBarDelegate and Methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    searchStatus = true;
    searchTxt = searchText;
    [self searchContactsAction:searchText];
    if ([searchText length] == 0)
    {
        [self performSelector:@selector(doneSearchAction:) withObject:nil afterDelay:0];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
}

-(void)searchContactsAction:(NSString *)searchText{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS [c] %@",@"fullName",searchText];
    arrSearchContacts = [arrayContact filteredArrayUsingPredicate:predicate];
    [tableViewFriends reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];


}

- (IBAction)doneSearchAction:(UIBarButtonItem *)sender {
    searchStatus = false;
    searchTxt = @"";
    [tableViewFriends reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    
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
