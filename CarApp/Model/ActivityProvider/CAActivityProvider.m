//
//  CAActivityProvider.m
//  RoadTrip
//
//  Created by SICS on 23/09/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CAActivityProvider.h"

@implementation CAActivityProvider
//- (id) activityViewController:(UIActivityViewController *)activityViewController
//          itemForActivityType:(NSString *)activityType
//{
//    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] )
//        return @"";
//    if ( [activityType isEqualToString:UIActivityTypePostToFacebook] )
//        return @"";
//    if ( [activityType isEqualToString:UIActivityTypeMessage] )
//        return @"SMS message text";
//    if ( [activityType isEqualToString:UIActivityTypeMail] )
//        return @"Email text here!";
//    if ( [activityType isEqualToString:@"it.albertopasca.myApp"] )
//        return @"";
//    return nil;
//}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }
@end
@implementation APActivityIcon
- (NSString *)activityType:(NSString *)text { return text; }
//- (NSString *)activityTitle { return @"Open Maps"; }
- (UIImage *) activityImage { return [UIImage imageNamed:@"placeholder"]; }
- (BOOL) canPerformWithActivityItems:(NSArray *)activityItems { return YES; }
- (void) prepareWithActivityItems:(NSArray *)activityItems { }
- (UIViewController *) activityViewController { return nil; }
- (void) performActivity {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"maps://"]];
}
@end