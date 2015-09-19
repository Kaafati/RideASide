//
//  CAFacebookPicturesCollectionViewController.m
//  RideAside
//
//  Created by Srishti Innovative on 31/08/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import "CAFacebookPicturesCollectionViewController.h"
#import "CAFacebookCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "CAProfileAndRatingViewController.h"
@interface CAFacebookPicturesCollectionViewController ()

@end

@implementation CAFacebookPicturesCollectionViewController
@synthesize arrayFacebookFriends,arrayMutualFacebookFriends,arrayProfilePictures;
static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]]];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (arrayProfilePictures) return arrayProfilePictures.count;
    
    else if (arrayFacebookFriends) return [[arrayFacebookFriends valueForKeyPath:@"data.picture.data.url"] count];
        else return [arrayMutualFacebookFriends  count];
    
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CAFacebookCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
   
    
    if (arrayMutualFacebookFriends) {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[arrayMutualFacebookFriends valueForKeyPath:@"picture.data.url"][indexPath.row]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        cell.labelName.text =[arrayMutualFacebookFriends valueForKey:@"name"][indexPath.row];

    }
    else if(arrayFacebookFriends)
    {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[arrayFacebookFriends valueForKeyPath:@"data.picture.data.url"][indexPath.row]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        cell.labelName.text =[arrayFacebookFriends valueForKeyPath:@"data.name"][indexPath.row]
        ;
    }
    
    else
    {
        
        
       [cell.imageView sd_setImageWithURL:[NSURL URLWithString:arrayProfilePictures[indexPath.row]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        cell.labelName.hidden = YES;

      
    }

    // Configure the cell
    return cell;
}


#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (arrayProfilePictures) {
     
        CAFacebookCollectionViewCell *cell = (CAFacebookCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [self.delegateFacebookProfilePicture facebookPicturesDidFinishPickingImage:cell.imageView.image];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
    CAProfileAndRatingViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"profileAndRatingView"];
    profile.faceBookIDFromCollection = arrayFacebookFriends ? [arrayFacebookFriends valueForKeyPath:@"data.id"][indexPath.row] : [arrayMutualFacebookFriends valueForKey:@"id"][indexPath.row];
    [self.navigationController pushViewController:profile animated:YES];
    }
}
/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
