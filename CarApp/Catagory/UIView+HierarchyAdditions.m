//
//  UIView+HierarchyAdditions.m
//  LoginDemo
//
//  Created by Siju karunakaran on 9/17/13.
//  Copyright (c) 2013 Srishti Innovative. All rights reserved.
//
#import "UIView+HierarchyAdditions.h"

@implementation UIView(HierarchyAdditions)

-(NSArray *) allSubviewsForView: (UIView *) view
{
	NSMutableArray *subviews = [NSMutableArray array];
	[subviews addObject: view];
	for( UIView *subview in view.subviews )
	{
		[subviews addObjectsFromArray: [self allSubviewsForView: subview]];
	}
	return [NSArray arrayWithArray: subviews];
}

-(NSArray *) allSubviews
{
	return [self allSubviewsForView: self];
}

-(void) visitSubviewsForView: (UIView *) view
				   withBlock: (VisitSubviewBlock) visitBlock
{
	visitBlock(view);
	for( UIView *subview in view.subviews )
	{
		visitBlock(subview);
	}
}

-(void) visitAllSubviewsWithBlock: (VisitSubviewBlock) visitSubviewBlock
{
	for( UIView *subview in [self allSubviews] )
	{
		visitSubviewBlock(subview);
	}
}


@end
