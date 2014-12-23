//
//  CAUser.h
//  RoadTrip
//
//  Created by SICS on 19/08/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAUser : NSObject
@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString *emailId;
@property(nonatomic,strong)NSString *password;
@property(nonatomic,strong)NSString *phoneNumber;
@property(nonatomic,strong)NSString *userId;
@property(nonatomic,strong)NSString *profile_ImageName;
@property(nonatomic,strong)UIImage *profile_Image;//set just for passing values
@property(nonatomic,strong)NSString *latitude;
@property(nonatomic,strong)NSString *longitude;
@property(nonatomic,strong)NSString *rateValue;
@property(nonatomic,strong)NSString *reviewNote;


+(CAUser *)sharedUser;
+(void)logout;
+(void)loginWithUsername:(NSString *)username password:(NSString *)password withCompletionBlock:(void (^)(BOOL, CAUser *, NSError*))completionBlock;
-(void)signUpwithCompletionBlock:(void (^)(BOOL, NSError*))completionBlock;
+(void)addUserLocationWithData:(NSData *)data withCompletionBlock:(void (^)(BOOL, NSError*))completionBlock;
-(void)updateUserProfileWithCompletionBlock:(void (^)(BOOL, NSError*))completionBlock;
-(void)fetchUsersAroundTripwithTripId:(NSString *)tripId  WithCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock;
-(void)fetchJoineesListInTripWithTripId:(NSString *)tripId WithCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock;
-(void)fetchProfileDetailsWithUserId:(NSString *)userId WithCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock;
+(void)parseLogoutwithCompletionBlock:(void (^)(BOOL, NSError*))completionBlock;
+(void)parsePaymentDetailsToBackEndWithTripId:(NSString *)tripId andTripName:(NSString *)tripName andAmount:(NSString *)tripAmount  WithCompletionBlock:(void (^)(BOOL, NSError*))completionBlock;
+(void)parseReviewingadRaringOfUseriD:(NSString *)userId withReview:(NSString *)review withRateValue:(NSString *)rateValue WithCompletionBlock:(void (^)(BOOL, NSError*))completionBlock;
-(void)viewRatingHistoryWithCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock;

+(CAUser *)userWithDetails:(NSDictionary *) userDetails;



//http://sicsglobal.com/projects/WebT1/roadtripapp/add_location.php?id=3&latitude=36.114646&longitude=-115.172816 -Adding Location
//http://sicsglobal.com/projects/WebT1/roadtripapp/signin.php?name=user1@gmail.com&password=pass  //Sign
//http://sicsglobal.com/projects/WebT1/roadtripapp/signup.php?name=user1&email=user@gmail.com&phone=12345&password=pass&file= //Sign up
//http://sicsglobal.com/projects/WebT1/roadtripapp/edit_profile.php?id=5&name=mm&email=jj@jdj.com&phone=1234&password=hai&file= //Updation Link
//http://sicsglobal.com/projects/WebT1/roadtripapp/users_around.php?tripid=90 -Users around the trip
//http://sicsglobal.com/projects/WebT1/roadtripapp/joineess.php?tripid=90 View trip joinees
//http://sicsglobal.com/projects/WebT1/roadtripapp/logout.php?userid=33 Logout
//http://sicsglobal.com/projects/WebT1/roadtripapp/payment.php?user_id=33&trip_id=2&trip_name=Longdrive&amount=100 -Trip PaymentDetails
//http://sicsglobal.com/projects/WebT1/roadtripapp/rating.php?user_id=53&rate_user=54&rating=4&review=good//Add Rating
//UserId=Looged in user and rate_user=user to be rated
////http://sicsglobal.com/projects/WebT1/roadtripapp/userdetails.php?user_id=53&rate_user=54-Profile Details
//http://sicsglobal.com/projects/WebT1/roadtripapp/rating.php?user_id=53&rate_user=54&rating=4&review=good Adding review and rating
//http://sicsglobal.com/projects/WebT1/roadtripapp/view_rating.php?user_id=54  View Ratingg


@end
