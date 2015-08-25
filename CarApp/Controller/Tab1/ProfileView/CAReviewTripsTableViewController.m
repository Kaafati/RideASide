//
//  CAReviewTripsTableViewController.m
//  RideAside
//
//  Created by Srishti Innovative on 18/08/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import "CAReviewTripsTableViewController.h"
#import "CATripCell.h"
#import "CATrip.h"
#import "UIButton+WebCache.h"
#import "CATripReview.h"
#import "CAReviewTableViewController.h"
@interface CAReviewTripsTableViewController ()

@end

@implementation CAReviewTripsTableViewController
@synthesize tableArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    self.tableView.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [SVProgressHUD show];
    [CATrip fetchReviewWithUserId:self.userId completion:^(BOOL success , id result, NSError *error) {
            [SVProgressHUD dismiss];
        if (success) {
            tableArray =result;
            [self.tableView reloadData];
        }
        else [[[UIAlertView alloc] initWithTitle:@"" message:@"No reviews Found" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        
    }];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    CATripReview *trip=tableArray[indexPath.row];
    cell.backgroundColor=[UIColor clearColor];
    cell.labelTrip.textColor=[UIColor whiteColor];
    [cell.imageUserPicture sd_setBackgroundImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,trip.trip_owner_image]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeholder"] ];
    
    //    [cell.imageUserPicture setBackgroundImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,trip.imageName]] placeholderImage:[UIImage imageNamed:@"placeholder"] ];
    //    [cell.imageUserPicture setImageWithURL:[NSURL  URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,trip.imageName]]];
    cell.imageUserPicture.layer.cornerRadius = 25.0f;
    cell.imageUserPicture.clipsToBounds=YES;
    cell.labelTrip.text=[NSString stringWithFormat:@"%@ got review from %@ trip.",self.userName,trip.trip_name];
    cell.imageUserPicture.tag=indexPath.row;
    cell.labelTrip.font=[UIFont fontWithName:@"Arial" size:12];
    [cell.imageUserPicture.layer setBorderColor:[UIColor whiteColor].CGColor];
    cell.imageUserPicture.layer.borderWidth=2;
  //  [cell.imageUserPicture addTarget:self action:@selector(goToProfilePage:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle=UITableViewCellEditingStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CAReviewTableViewController *review = [self.storyboard instantiateViewControllerWithIdentifier:@"CAReviewTableViewController"];
    CATripReview * tripReview = tableArray[indexPath.row];
    review.arrayReview = tripReview.arrayReviews.mutableCopy;
    [self.navigationController pushViewController:review animated:YES];
    
   
}

- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(backButtonPressed:)];
}
- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
