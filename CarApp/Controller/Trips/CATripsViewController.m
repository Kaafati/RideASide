//
//  CATripsViewController.m
//  RoadTrip
//
//  Created by SICS on 17/09/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CATripsViewController.h"
#import "CATrip.h"
#import "CAServiceManager.h"
#import "SVProgressHUD.h"
#import "CATripsViewController.h"
#import "CATripDetailsTableViewController.h"
#import "NSDate+TimeZone.h"
#import "MFSideMenu.h"
#import "CATripCell.h"
#import "UIImageView+WebCache.h"
#import "CAUser.h"
#import "UIButton+WebCache.h"
#import "CAProfileTableViewController.h"
#import "CAProfileAndRatingViewController.h"

@interface CATripsViewController ()<UISearchBarDelegate,delgateTripChanges>{
    NSMutableArray *tableArray;
    NSInteger startCount;
    BOOL isLoadMoreData;
    UIActivityIndicatorView *_activityIndicatorView;;
    UILabel *labelLoading;
    UIRefreshControl *refreshControl;
    BOOL ISPullToRefresh;
    NSInteger segmentIndex,segmentMilesIndex;
    NSString *searchString;
}

@end

@implementation CATripsViewController

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
    [self setupMenuBarButtonItems];
    [self setUI];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    tableArray=[NSMutableArray new];
    segmentIndex=0;
    segmentMilesIndex=3;
    
    isLoadMoreData=YES;
    startCount=0;
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor whiteColor];
    [self.tableView addSubview:refreshControl];
    
    UIView *headerView=[self setUpHeaderView];
    CGRect newFrame = headerView.frame;
    headerView.frame = newFrame;
    self.tableView.tableHeaderView = headerView;
    
    
//    [SVProgressHUD showWithStatus:@"Fetching Posts..." maskType:SVProgressHUDMaskTypeBlack];
    [self parseMyTrips:self.tabBarController.selectedIndex WithSearchString:@"" WithrideIndex:segmentIndex WithMilesIndex:segmentMilesIndex*10+10];
    
    
    
}
-(void)parseMyTrips:(NSInteger)indexOfTab WithSearchString:(NSString *)searchText WithrideIndex:(NSInteger)rideIndex WithMilesIndex:(NSInteger)milesIndex
{
    NSString *pathName;
    switch (self.tabBarController.selectedIndex) {
        case 0:
            pathName=@"view_trip.php";
            break;
        case 1:
             pathName=@"trip_details.php";
            break;
        case 3:
             pathName=@"view_all_trip.php";
            break;
        default:
            break;
    }
    CATrip *trip=[[CATrip alloc]init];
    NSLog(@"PathName =%@",pathName);
    [SVProgressHUD showWithStatus:@"Fetching Posts..." maskType:SVProgressHUDMaskTypeBlack];
    [trip getTripDetailswithPath:pathName withSearchString:[searchText isKindOfClass:[NSNull class]]?@"":searchText withIndex:startCount withMiles:milesIndex withOptionForTripDetailIndex:rideIndex withCompletionBlock:^(BOOL success, id result,id result2, NSError *error) {
        [SVProgressHUD dismiss];
        [_activityIndicatorView stopAnimating];
        [labelLoading setHidden:YES];
        (startCount==0)?[tableArray removeAllObjects]:nil;
        NSArray *arrayDataList=(NSArray *)result;
        if (success) {
            
            [arrayDataList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tableArray addObject:obj];
            }];
            [(NSArray *)result2 enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
               
                [tableArray addObject:obj];
            }];
        }
        isLoadMoreData=(arrayDataList.count%10==0)?YES:NO;
        ISPullToRefresh=NO;
        [refreshControl endRefreshing];
        [self.view setUserInteractionEnabled:YES];
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    return [tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CATripCell *cell = (CATripCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[CATripCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    CATrip *trip=tableArray[indexPath.row];
    cell.backgroundColor=[UIColor clearColor];
    cell.labelTrip.textColor=[UIColor whiteColor];
    [cell.imageUserPicture sd_setBackgroundImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,[CAUser sharedUser].userId.integerValue != trip.UserId.integerValue ? trip.imageName : [CAUser sharedUser].profile_ImageName]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"] ];
    
//    [cell.imageUserPicture setBackgroundImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,trip.imageName]] placeholderImage:[UIImage imageNamed:@"placeholder"] ];
//    [cell.imageUserPicture setImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,trip.imageName]]];
    cell.imageUserPicture.layer.cornerRadius = 25.0f;
    cell.imageUserPicture.clipsToBounds=YES;
    cell.labelTrip.text=[NSString stringWithFormat:@"%@ posted %@.",[CAUser sharedUser].userId.integerValue != trip.UserId.integerValue ? trip.name : [CAUser sharedUser].userName,trip.tripName];
    cell.imageUserPicture.tag=indexPath.row;
    cell.labelTrip.font=[UIFont fontWithName:@"Arial" size:12];
    [cell.imageUserPicture.layer setBorderColor:[UIColor whiteColor].CGColor];
    cell.imageUserPicture.layer.borderWidth=2;
    [cell.imageUserPicture addTarget:self action:@selector(goToProfilePage:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle=UITableViewCellEditingStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CATrip *trip=tableArray[indexPath.row];
    CATripDetailsTableViewController *tripDetails=[self.storyboard instantiateViewControllerWithIdentifier:@"tripDetailsView"];
    tripDetails.trip=trip;
    tripDetails.changedTripDelegate = (id<delgateTripChanges>)self;
    tripDetails.row = indexPath.row;
    [self.navigationController pushViewController:tripDetails animated:YES];
}


-(void)changedTrip:(CATrip *)trip inIndex:(NSUInteger)row
{
    trip.name = [CAUser sharedUser].userName;
    [tableArray replaceObjectAtIndex:row withObject:trip];
    [self.tableView reloadData];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView
                  willDecelerate:(BOOL)decelerate
{
    if(self.tableView.contentOffset.y<0)/* scroll from top */
    {
    }
    else if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height -self.tableView.bounds.size.height)&&tableArray.count>0&&isLoadMoreData)/* scroll from end*/
    {
        [self.view setUserInteractionEnabled:NO];
        startCount=[self countToParseNextData:tableArray];
        [self parseMyTrips:self.tabBarController.selectedIndex WithSearchString:searchString WithrideIndex:segmentIndex WithMilesIndex:segmentMilesIndex];
        [self setLoadingFooter];
    }
}
#pragma mark-Actions
-(void)goToProfilePage:(UIButton *)sender{
    CATrip *trip=tableArray[sender .tag];
//    CAProfileTableViewController *profile=[self.storyboard instantiateViewControllerWithIdentifier:@"profileView"];
    if(trip.UserId.integerValue != [CAUser sharedUser].userId.integerValue)
    {
    CAProfileAndRatingViewController *profile=[self.storyboard instantiateViewControllerWithIdentifier:@"profileAndRatingView"];
    [profile setUserId:trip.UserId];
    [profile setUserName:trip.name];
    [self.navigationController pushViewController:profile animated:YES];
    }
    else
    {
        [self.tabBarController setSelectedIndex:0];
    }
}
- (void)handleRefresh : (UIRefreshControl*)sender{
    [self.view setUserInteractionEnabled:NO];
    isLoadMoreData=YES;
    startCount=0;
    [self parseMyTrips:self.tabBarController.selectedIndex WithSearchString:searchString WithrideIndex:segmentIndex WithMilesIndex:segmentMilesIndex*10+10];
    ISPullToRefresh=YES;
    
    
}

-(void)setLoadingFooter
{
    CGRect frame= CGRectMake(0, 0, 320, 30);
    CGRect actframe= CGRectMake(100, 15, 5, 5);
    UIView *loadingView = [[UIView alloc] initWithFrame:frame];
    labelLoading=[[UILabel alloc]initWithFrame:CGRectMake(120, 5, 100, 20)];
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:actframe];
    [_activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [_activityIndicatorView setColor:[UIColor whiteColor]];
    [_activityIndicatorView startAnimating];
    [labelLoading setText:@"Loading..."];
    [labelLoading setFont:[UIFont fontWithName:@"Arial" size:12]];
    [labelLoading setTextColor:[UIColor whiteColor]];
    [loadingView addSubview:labelLoading];
    [loadingView addSubview:_activityIndicatorView];
    [self.tableView setTableFooterView:loadingView];
    
}
-(void)goToTripDetailsPage
{
    CATripDetailsTableViewController *tripDetails=[self.storyboard instantiateViewControllerWithIdentifier:@"tripDetailsView"];
    [self.navigationController pushViewController:tripDetails animated:YES];
}


-(NSInteger)countToParseNextData:(NSArray *)array
{
    NSInteger count;
    count=(array.count/10);
    return count;
}
#pragma mark-Delegate
-(void)addTrip:(CATrip *)trip{
    isLoadMoreData=YES;
    startCount=0;
    [self parseMyTrips:self.tabBarController.selectedIndex WithSearchString:searchString WithrideIndex:segmentIndex WithMilesIndex:segmentMilesIndex];
}

-(UIView *)setUpHeaderView{
    UIView *headerView;
    switch (self.tabBarController.selectedIndex) {
        case 0:
            break;
        case 1:
            headerView=[self setUpSecondTabBarHeaderView];
            break;
        case 3:
            headerView=[self setUpThirdTabBarHeaderView];
            break;
        default:
            break;
    }
    
    return headerView;
}

#pragma mark-Creating Header View

-(UIView *)setUpSecondTabBarHeaderView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 100)];
    NSArray *itemArray = [NSArray arrayWithObjects: @"Rides Near Me",  @"Finished Rides", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    segmentedControl.frame = CGRectMake(10, 10, headerView.frame.size.width-20, 30);
    [segmentedControl addTarget:self action:@selector(segmentControlAction:) forControlEvents: UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.tintColor=[UIColor whiteColor];
    
    UISegmentedControl *segmentedControl2 = [[UISegmentedControl alloc] initWithItems:@[@"10 Miles",@"20 Miles",@"30 Miles",@"40 Miles"]];
    segmentedControl2.frame = CGRectMake(10, CGRectGetMaxY(segmentedControl.frame)+10, headerView.frame.size.width-20, 30);
    [segmentedControl2 addTarget:self action:@selector(segmentControlMiles:) forControlEvents: UIControlEventValueChanged];
    segmentedControl2.selectedSegmentIndex = 3;
    segmentedControl2.tintColor=[UIColor whiteColor];
    [headerView addSubview:segmentedControl];
    [headerView addSubview:segmentedControl2];
    
    
    UISearchBar *search_Bar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(segmentedControl2.frame)+10,headerView.frame.size.width, 44)];
    search_Bar.autocorrectionType = UITextAutocorrectionTypeNo;
    search_Bar.placeholder = @"Enter the place to search";
    search_Bar.delegate = self;
    search_Bar.tintColor=[UIColor whiteColor];
    search_Bar.searchBarStyle = UISearchBarStyleMinimal;
      [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    

    [headerView addSubview:search_Bar];
   
    return headerView;
    
}

-(UIView *)setUpThirdTabBarHeaderView{
      UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 100)];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"10 Miles",@"20 Miles",@"30 Miles",@"40 Miles"]];
    segmentedControl.frame = CGRectMake(10, 0, headerView.frame.size.width-20, 30);
    [segmentedControl addTarget:self action:@selector(segmentControlMiles:) forControlEvents: UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 3;
    segmentedControl.tintColor=[UIColor whiteColor];

    UISearchBar *searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(segmentedControl.frame)+10,headerView.frame.size.width, 44)];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.placeholder = @"Enter the place to search";
    searchBar.delegate = self;
    searchBar.tintColor=[UIColor whiteColor];
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [headerView addSubview:segmentedControl];
    [headerView addSubview:searchBar];
    return headerView;
    
}

-(void)segmentControlAction:(UISegmentedControl *)segmentedControl{
    segmentIndex=segmentedControl.selectedSegmentIndex;
    startCount=0;
    [self parseMyTrips:self.tabBarController.selectedIndex WithSearchString:searchString WithrideIndex:segmentIndex == 0 ? segmentIndex : segmentIndex+1 WithMilesIndex:segmentMilesIndex];//It's for we removed the upcoming rides so to fetch the finished result we set the status 2
    
}
-(void)segmentControlMiles:(UISegmentedControl *)segmentedControl
{
    segmentMilesIndex=segmentedControl.selectedSegmentIndex*10+10;
    NSLog(@"segment %d",segmentMilesIndex);
    startCount=0;
    [self parseMyTrips:self.tabBarController.selectedIndex WithSearchString:searchString WithrideIndex:segmentIndex == 0 ? segmentIndex : segmentIndex+1 WithMilesIndex:segmentMilesIndex];//It's for we removed the upcoming rides so to fetch the finished result we set the status 2
}
#pragma mark-Search Bar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    searchString=@"";
    [searchBar setShowsCancelButton:NO animated:YES];
    startCount=0;
     [SVProgressHUD showWithStatus:@"Fetching" maskType:SVProgressHUDMaskTypeBlack];
    [self parseMyTrips:self.tabBarController.selectedIndex WithSearchString:searchString WithrideIndex:segmentIndex WithMilesIndex:segmentMilesIndex];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    searchString=searchBar.text;
    [searchBar setShowsCancelButton:NO animated:YES];
    [SVProgressHUD showWithStatus:@"Searching" maskType:SVProgressHUDMaskTypeBlack];
    startCount=0;
    [self parseMyTrips:self.tabBarController.selectedIndex WithSearchString:searchString WithrideIndex:segmentIndex WithMilesIndex:segmentMilesIndex];
    [searchBar resignFirstResponder];
}


@end
