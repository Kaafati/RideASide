//
//  CACarCollectionViewCell.h
//  RoadTrip
//
//  Created by Srishti Innovative on 21/07/15.
//  Copyright (c) 2015 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CACarCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIButton *buttonCar;
@property (strong, nonatomic) IBOutlet UITextField *textFieldcarName;
@property (strong, nonatomic) IBOutlet UITextField *textFieldCarLicencePlate;

@end
