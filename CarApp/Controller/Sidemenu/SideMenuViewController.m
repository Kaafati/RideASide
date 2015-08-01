//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "CATabBarController.h"
#import "CATripDetailsTableViewController.h"
#import "CANavigationController.h"
#import "CASignUpViewController.h"
#import "CATripsViewController.h"
#import "UIImageView+WebCache.h"
#import "CAUser.h"
#import "CAAppDelegate.h"
#import "CAContainerViewController.h"
#import "CAServiceManager.h"
#import "CARequestsViewController.h"
@implementation SideMenuViewController{
    NSArray *arrayMenus;
    UIView *headerView ;
    UIImageView  *imageView;
}
-(void)viewDidLoad{
    arrayMenus=@[@"Home",@"Edit Profile",@"Requests",@"Review History",@"Logout"];
    self.tableView.backgroundColor=[UIColor darkGrayColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView)  name:
     @"updateProfileImage" object:nil];
    [self.menuContainerViewController setPanMode:MFSideMenuPanModeNone];
    
    
}

#pragma mark -
#pragma mark - UITableViewDataSource
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return section == 0 ? [self setupHeaderView] : nil;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return section == 0 ? 100 :0;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Section %ld", (long)section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrayMenus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.backgroundColor=[UIColor clearColor];
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    cell.textLabel.text = arrayMenus[indexPath.row];
    cell.textLabel.textColor=[UIColor whiteColor];
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CATabBarController *tabBarController = self.menuContainerViewController.centerViewController;
    CANavigationController *navigationController = (CANavigationController *)tabBarController.selectedViewController;
    NSMutableArray *controllers = [[NSMutableArray alloc ]initWithArray:navigationController.viewControllers];
    
    //NSArray *controllers;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:Nil];
    switch (indexPath.row) {
        case 0:{
            switch (tabBarController.selectedIndex) {
                case 0:{
                      CAContainerViewController *meViewController= [storyBoard instantiateViewControllerWithIdentifier:kContainerView];
                     [controllers addObject:meViewController];
                }
                    break;
                case 2:{
                    CATripDetailsTableViewController *tripDetails=[storyBoard instantiateViewControllerWithIdentifier:@"tripDetailsView"];
                    [controllers addObject:tripDetails];

                }
                    break;
                    
                default:{
                    CATripsViewController *meViewController= [storyBoard instantiateViewControllerWithIdentifier:@"tripView"];
                    [controllers addObject:meViewController];
                }
                    break;
            }
        }
            break;
        case 1:{
            CASignUpViewController *signInViewController=[storyBoard instantiateViewControllerWithIdentifier:@"signUpView"];
            [controllers addObject:signInViewController];
        }
            break;
        case 2:{
            CARequestsViewController *tripDetails=[storyBoard instantiateViewControllerWithIdentifier:@"requestsView"];
            [controllers addObject:tripDetails];

        }
            break;
        case 3:{
            CARequestsViewController *tripDetails=[storyBoard instantiateViewControllerWithIdentifier:@"requestsView"];
            [tripDetails setIsForReviewHistory:YES];
            [controllers addObject:tripDetails];
        }
            break;
        case 4:{
             [SVProgressHUD showWithStatus:@"Logging out..." maskType:SVProgressHUDMaskTypeBlack];
            [self parseLogout];
        }
            break;
        
            
        default:
            break;
    }
    
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    
    
}
-(void)parseLogout{
    [CAUser parseLogoutwithCompletionBlock:^(BOOL success, NSError *error) {
        [SVProgressHUD dismiss];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
        if(success){
            CAAppDelegate * appDelegate = (CAAppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate didLogout];
        }
        else
            [CAServiceManager handleError:error];
            
        
    }];
}



-(UIView *)setupHeaderView{
    if(!headerView){
        headerView = [[UIView alloc] init];
        imageView= [[UIImageView alloc] initWithFrame:CGRectMake(110, 0, 100, 100)];
    }
    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,[CAUser sharedUser].profile_ImageName]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    imageView.layer.cornerRadius = 50.0f;
    imageView.clipsToBounds=YES;
    [imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    imageView.layer.borderWidth=2;
    
    
    [headerView addSubview:imageView];
    return headerView;
    
}
-(void)updateTableView{
    [self.tableView reloadData];
}
@end
