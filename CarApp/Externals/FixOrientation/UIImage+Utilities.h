//
//  UIImage+Utilities.h
//  iRemember
//
//  Created by Vignesh R on 10/08/12.
//  Copyright (c) 2012 SICS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utilities)
- (UIImage *)fixOrientation;
- (UIImage*)scaleToSize:(CGSize)size;

@end
