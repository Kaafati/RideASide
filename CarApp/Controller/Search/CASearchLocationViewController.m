//
//  CCSearchLocationViewController.m
//  ConnecxxionCarsCustomer
//
//  Created by Srishti on 11/09/14.
//  Copyright (c) 2014 chitra. All rights reserved.
//

#import "CASearchLocationViewController.h"
#import "SPGooglePlacesAutocomplete.h"

@class SPGooglePlacesAutocompleteQuery;

@interface CASearchLocationViewController ()<UITableViewDelegate>{
    SPGooglePlacesAutocompleteQuery *searchQuery;
    NSArray *searchResult;
    IBOutlet UITableView *tableView;
    IBOutlet UISearchBar *searchBars;
    
   
}

@end

@implementation CASearchLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(cancelAction)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    searchBars.tintColor=[UIColor whiteColor];
    searchBars.searchBarStyle = UISearchBarStyleMinimal;
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    searchBars.placeholder = @"street/city/state/zip code";
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] init];
}

#pragma mark - SearchBar Delegate Methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar showsCancelButton];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    searchQuery.input = searchBar.text;
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        
        if (error) {
            SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
        }
        else
        {
            searchResult = places;
        }
        [tableView reloadData];
    }];
    [searchBar resignFirstResponder];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    //searchBar.text =@"";
}
- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return [searchResult objectAtIndex:indexPath.row];
}

#pragma mark TableView delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return searchResult.count>0?searchResult.count:1;
}
-(UITableViewCell *)tableView:(UITableView *)tableViews cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableViews dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = (searchResult.count>0)?[self placeAtIndexPath:indexPath].name:_addressName;
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    cell.textLabel.font=[UIFont fontWithName:@"Arial" size:12];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(searchResult.count>0){
    [searchBars resignFirstResponder];
    NSDictionary *dict = [[NSDictionary alloc]initWithObjects:@[[self placeAtIndexPath:indexPath].name] forKeys:@[@"address"]];
    [self.delegates searchLocationWithAddress:dict withTextFieldTag:_textFieldTag];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
 
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)cancelAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
