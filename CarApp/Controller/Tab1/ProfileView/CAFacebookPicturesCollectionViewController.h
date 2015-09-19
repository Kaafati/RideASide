//
//  CAFacebookPicturesCollectionViewController.h
//  RideAside
//
//  Created by Srishti Innovative on 31/08/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAProtocol.h"
@interface CAFacebookPicturesCollectionViewController : UICollectionViewController
@property(nonatomic,strong) NSArray *arrayFacebookFriends,*arrayMutualFacebookFriends,*arrayProfilePictures;
@property (strong, nonatomic) id <CAProtocolFacebookPicture> delegateFacebookProfilePicture;

@end
