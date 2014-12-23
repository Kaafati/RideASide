//
//  UIView+HierarchyAdditions.h
//  LoginDemo
//
//  Created by Siju karunakaran on 9/17/13.
//  Copyright (c) 2013 Srishti Innovative. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef void (^VisitSubviewBlock)(UIView *subview );

@interface UIView(HierarchyAdditions)

-(NSArray *) allSubviews;	// recursive

-(void) visitAllSubviewsWithBlock: (VisitSubviewBlock) visitSubviewBlock;

@end
