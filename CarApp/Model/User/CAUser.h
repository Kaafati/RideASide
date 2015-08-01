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
@property(nonatomic,strong)NSString *category;
@property(nonatomic,strong)NSString *profile_ImageName;
@property(nonatomic,strong)UIImage *profile_Image;//set just for passing values
@property(nonatomic,strong)NSString *latitude;
@property(nonatomic,strong)NSString *longitude;
@property(nonatomic,strong)NSString *rateValue;
@property(nonatomic,strong)NSString *reviewNote;
@property(nonatomic,strong)NSString *facebook_id;
@property(nonatomic,strong)NSString *about_me;
@property(nonatomic,strong)NSArray *othersLocation;
@property(nonatomic,strong)NSArray *contacts;
@property(nonatomic,strong)NSArray *arrayCar;
@property(nonatomic,strong)id car_image1;
@property(nonatomic,strong)NSString *car_name1;
@property(nonatomic,strong)NSString *car_licence_num1;
@property(nonatomic,strong)id car_image2;
@property(nonatomic,strong)NSString *car_name2;
@property(nonatomic,strong)NSString *car_licence_num2;
@property(nonatomic,strong)id car_image3;
@property(nonatomic,strong)NSString *car_name3;
@property(nonatomic,strong)NSString *car_licence_num3;
@property(nonatomic,strong)NSString *visibility;
@property(nonatomic,strong)NSString *smoker;
@property BOOL isSelected;
@property NSUInteger discloseNumber;
-(id)setArrayCarFromUpdate:(id)arrayCar;
-(id)setArray:(id)dictionary;

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
+(void)signUpWithFB:(NSString *)facebookId email:(NSString *)email name:(NSString *)name profileImg:(NSString *)profileImg withCompletionBlock:(void (^)(BOOL, CAUser *, NSError*))completionBlock;
-(void)fetchRatingAndReviewWithUserId:(NSString *)userId WithCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock;
-(void)fetchDriverListAccepted:(NSString *)tripid withCategory:(NSString *)category withCompletion:(void(^)(bool success,id result,NSError*err))completion;
//http://sicsglobal.com/projects/App_projects/rideaside/
+(CAUser *)userWithDetails:(NSDictionary *) userDetails;
+(void)fetchUsersTotalRatingCountWithCompletion:(void(^)(bool success,id result,NSError *error))completion;
+(void)forgotPasswordWithEmailId:(NSString *)emialId withCompletionBlock:(void (^)(bool, id, NSError *))completion;
+(void)listTheAppUserwithCompletionBlock:(void (^)(bool, id, NSError *))completion;
//http://sicsglobal.com/projects/App_projects/rideaside/sum_rating.php?user_id=2 ViewTotalRating Of User
//http://sicsglobal.com/projects/App_projects/rideaside/add_location.php?id=3&latitude=36.114646&longitude=-115.172816 -Adding Location
//http://sicsglobal.com/projects/App_projects/rideaside/signin.php?name=user1@gmail.com&password=pass  //Sign
//http://sicsglobal.com/projects/App_projects/rideaside/signup.php?name=user1&email=user@gmail.com&phone=12345&password=pass&file= //Sign up
//http://sicsglobal.com/projects/App_projects/rideaside/edit_profile.php?id=5&name=mm&email=jj@jdj.com&phone=1234&password=hai&file= //Updation Link
//http://sicsglobal.com/projects/App_projects/rideaside/users_around.php?tripid=90 -Users around the trip
//http://sicsglobal.com/projects/App_projects/rideaside/joineess.php?tripid=90 View trip joinees
//http://sicsglobal.com/projects/App_projects/rideaside/list_drivers.php?user_id=39&category=Passenger&tripid=80 ViewDriverAcceptedList
//http://sicsglobal.com/projects/App_projects/rideaside/logout.php?userid=33 Logout
//http://sicsglobal.com/projects/App_projects/rideaside/payment.php?user_id=33&trip_id=2&trip_name=Longdrive&amount=100 -Trip PaymentDetails
//http://sicsglobal.com/projects/App_projects/rideaside/rating.php?user_id=53&rate_user=54&rating=4&review=good AddRating
//UserId=Looged in user and rate_user=user to be rated
////http://sicsglobal.com/projects/App_projects/rideaside/userdetails.php?user_id=53&rate_user=54-Profile Details
//http://sicsglobal.com/projects/App_projects/rideaside/rating.php?user_id=53&rate_user=54&rating=4&review=good Adding review and rating
//http://sicsglobal.com/projects/App_projects/rideaside/view_rating.php?user_id=54  View Ratingg
//http://sicsglobal.com/projects/App_projects/rideaside/facebooklogin.php?facebook_id=43546&email=reref@gg.com&name=redft&file= SignUp with facebook
//http://sicsglobal.com/projects/App_projects/rideaside/forgotpassword.php?user_id=25&email_id=dorad686@yahoo.com
//http://sicsglobal.com/projects/App_projects/rideaside/list_users.php?userId=14&lattitude=8.487500&longitude=76.952500
@end
