//
//  CARequestsViewController.m
//  RoadTrip
//
//  Created by Bala on 28/10/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CARequestsViewController.h"
#import "MFSideMenu.h"
#import "SVProgressHUD.h"
#import "CATrip.h"
#import "CATripCell.h"
#import "UIButton+WebCache.h"
#import "CATripDetailsTableViewController.h"
#import "CAUser.h"
#import "DYRateView.h"

@interface CARequestsViewController ()<acceprOrRejectTripDelegate>{
    NSMutableArray *tableArray;
    NSInteger startCount;
    BOOL isLoadMoreData;
    UIActivityIndicatorView *_activityIndicatorView;;
    UILabel *labelLoading;
    UIRefreshControl *refreshControl;
    BOOL ISPullToRefresh;
    
}

@end

@implementation CARequestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self intializeValues];
    [self setupMenuBarButtonItems];
    
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


-(void)intializeValues{
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    
    tableArray=[NSMutableArray new];
    
    isLoadMoreData=YES;
    startCount=0;
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor whiteColor];
    [self.tableView addSubview:refreshControl];
    
    [SVProgressHUD showWithStatus:@"Fetching Requests..." maskType:SVProgressHUDMaskTypeBlack];
    (_isForReviewHistory)?[self fetchRequestHistory]:[self parseFetchSendRequests];
}
#pragma mark-Parsing
-(void)parseFetchSendRequests{
    CATrip *trip=[[CATrip alloc]init];
    NSString *pathName;
    pathName=@"PendingTrip.php?";
    
    [trip fetchRequestsWithIndex:[NSString stringWithFormat:@"%d",startCount] withPath:pathName CompletionBlock:^(BOOL success, id result, NSError *error) {
        [SVProgressHUD dismiss];
        [_activityIndicatorView stopAnimating];
        [labelLoading setHidden:YES];
        (startCount==0)?[tableArray removeAllObjects]:nil;
        NSArray *arrayDataList=(NSArray *)result;
        if (success) {
            
            [arrayDataList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
-(void)fetchRequestHistory{
    CAUser *user=[[CAUser alloc]init];
    [user viewRatingHistoryWithCompletionBlock:^(BOOL success, id result, NSError *error) {
        [SVProgressHUD dismiss];
        [_activityIndicatorView stopAnimating];
        [labelLoading setHidden:YES];
        (startCount==0)?[tableArray removeAllObjects]:nil;
        NSArray *arrayDataList=(NSArray *)result;
        if (success) {
            
            [arrayDataList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tableArray addObject:obj];
            }];
        }
        isLoadMoreData=(arrayDataList.count%10==0)?YES:NO;
        ISPullToRefresh=NO;
        [refreshControl endRefreshing];
        [self.tableView reloadData];
        
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark-Actions
- (void)handleRefresh : (UIRefreshControl*)sender{
    [self.view setUserInteractionEnabled:NO];
    isLoadMoreData=YES;
    startCount=0;
    (_isForReviewHistory)?[self fetchRequestHistory]:[self parseFetchSendRequests];
    ISPullToRefresh=YES;
    
    
}
#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height=0;
    if(_isForReviewHistory){
        CAUser *user=tableArray[indexPath.row];
        UIFont *cellFont = [UIFont fontWithName:@"Arial" size:12];
        CGSize constraintSize = CGSizeMake(230, CGFLOAT_MAX);
        NSAttributedString *attributedText =
        [[NSAttributedString alloc]
         initWithString:user.reviewNote         attributes:@
         {
         NSFontAttributeName: cellFont
         }];
        CGRect rect = [attributedText boundingRectWithSize:constraintSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        CGSize labelSize = rect.size;
        return labelSize.height+80;

        }
    else
        height=80;
    return height;
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
    CATripCell *activeCell;
    if(!_isForReviewHistory){
        static NSString *CellIdentifier = @"Cell";
        CATripCell *cell = (CATripCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[CATripCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [self configureCellWithRequestsWithIndexPath:indexPath withTableViewCell:cell];
        activeCell=cell;
    }
    else{
        static NSString *CellIdentifier = @"rateCell";
        CATripCell *cell = (CATripCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[CATripCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [self configureCellWithRatingWithIndexPath:indexPath withTableViewCell:cell];
        activeCell=cell;
    }
    return activeCell;
}

-(void)configureCellWithRequestsWithIndexPath:(NSIndexPath *)indexPath withTableViewCell:(CATripCell *)cell{
    
    CATrip *trip=tableArray[indexPath.row];
    cell.backgroundColor=[UIColor clearColor];
    cell.labelTrip.textColor=[UIColor whiteColor];
    cell.imageUserPicture.layer.cornerRadius = 25.0f;
    cell.imageUserPicture.clipsToBounds=YES;
    [cell.imageUserPicture sd_setBackgroundImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,trip.imageName]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
//    [cell.imageUserPicture sd_setBackgroundImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,trip.imageName]] placeholderImage:[UIImage imageNamed:@"placeholder"] ];
    cell.labelTrip.text=[NSString stringWithFormat:@"%@ posted %@.",trip.name,trip.tripName];
    cell.labelTrip.font=[UIFont fontWithName:@"Arial" size:12];
    [cell.imageUserPicture.layer setBorderColor:[UIColor whiteColor].CGColor];
    cell.imageUserPicture.layer.borderWidth=2;
    cell.selectionStyle=UITableViewCellEditingStyleNone;
    
    
}
-(void)configureCellWithRatingWithIndexPath:(NSIndexPath *)indexPath withTableViewCell:(CATripCell *)cell{
    CAUser *user=tableArray[indexPath.row];
    cell.backgroundColor=[UIColor clearColor];
    cell.labelTrip.textColor=[UIColor whiteColor];
    cell.imageUserPicture.layer.cornerRadius = 25.0f;
    cell.imageUserPicture.clipsToBounds=YES;
    [cell.imageUserPicture sd_setBackgroundImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,user.profile_ImageName]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"]];
//    [cell.imageUserPicture setBackgroundImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,user.profile_ImageName]] placeholderImage:[UIImage imageNamed:@"placeholder"] ];
    cell.labelTrip.text=user.reviewNote;
    [cell.imageUserPicture.layer setBorderColor:[UIColor whiteColor].CGColor];
    cell.imageUserPicture.layer.borderWidth=2;
    
    DYRateView *rateView= [[DYRateView alloc] initWithFrame:CGRectMake(70, 20, self.view.bounds.size.width, 60)];
    rateView.rate =user.rateValue.integerValue ;
    rateView.alignment = RateViewAlignmentLeft;
    [cell.contentView  addSubview:rateView];
    
    
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:user.reviewNote
     attributes:@
     {
     NSFontAttributeName:[UIFont fontWithName:@"Arial" size:12]
     }];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(230,CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize contentsize = rect.size;


    cell.labelTrip.frame = CGRectMake(cell.labelTrip.frame.origin.x, cell.labelTrip.frame.origin.y, contentsize.width, contentsize.height);
    cell.labelTrip.textAlignment=NSTextAlignmentJustified;
    cell.labelTrip.lineBreakMode = NSLineBreakByWordWrapping;
    cell.labelTrip.numberOfLines = 0;
    cell.selectionStyle=UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_isForReviewHistory){
        
    }
    else{
        CATrip *trip=tableArray[indexPath.row];
        CATripDetailsTableViewController *tripDetails=[self.storyboard instantiateViewControllerWithIdentifier:@"tripDetailsView"];
        tripDetails.delegate=self;
        tripDetails.isFromRequestPage=YES;
        tripDetails.indexPathOfRowSelected=indexPath;
        tripDetails.trip=trip;
        [self.navigationController pushViewController:tripDetails animated:YES];
    }
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
        [self parseFetchSendRequests];
        [self setLoadingFooter];
    }
}
#pragma  mark-Actions
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
-(NSInteger)countToParseNextData:(NSArray *)array
{
    NSInteger count;
    count=(array.count/10);
    return count;
}
-(void)actionAfterAcceptOrRejectTripwithIndexPathOfRowSelected:(NSIndexPath *)indexPath{
    [tableArray removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}

@end
