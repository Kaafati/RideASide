//
//  CAUser.m
//  RoadTrip
//
//  Created by SICS on 19/08/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CAUser.h"
#import "NSMutableData+PostDataAdditions.h"
#import "CAServiceManager.h"
static CAUser *_user = nil;

@implementation CAUser

+(void)logout{
    _user = nil;
}

-(id)initWithUserDetails:(NSDictionary *)userDetails{
    
    self = [super init];
    
    if (self) {
        
        [self setValueInObject:userDetails];
        
    }
    return self;
}

-(void)setValueInObject:(NSDictionary *)dictionary
{
    self.userId=dictionary[@"UserId"]?dictionary[@"UserId"]:self.userId;
    self.userName=dictionary[@"Name"];
    self.emailId=dictionary[@"EmailId"];
    self.phoneNumber=dictionary[@"MobieNo"]?dictionary[@"MobieNo"]:dictionary[@"MobileNo"];
    self.profile_Image=dictionary[@"Image__Name"];
    self.profile_ImageName=dictionary[@"image"]?dictionary[@"image"]:dictionary[@"Image"];
    self.password=dictionary[@"password"];
    self.latitude=dictionary[@"latitude"];
    self.longitude=dictionary[@"longitude"];
    self.rateValue=dictionary[@"rating"];
    self.about_me =dictionary[@"about_me"];
    self.category =dictionary[@"category"];
    self.othersLocation =dictionary[@"others"];
    NSString *reviewNote=dictionary[@"review"];
    self.reviewNote=reviewNote.length>0?reviewNote:@"";
}

-(void)updateValues:(NSDictionary *)dictionary{
    NSMutableDictionary *dictionary_Modified=[[NSMutableDictionary alloc]initWithDictionary:dictionary];
    [dictionary_Modified setValue:[CAUser sharedUser].userId forKeyPath:@"UserId"];
    
    [CAUser saveLoggedUser:dictionary_Modified];
    [CAUser sharedUser].userName=dictionary[@"Name"];
    [CAUser sharedUser].emailId=dictionary[@"EmailId"];
    [CAUser sharedUser].phoneNumber=dictionary[@"MobieNo"]?dictionary[@"MobieNo"]:dictionary[@"MobileNo"];
    [CAUser sharedUser].profile_Image=dictionary[@"Image__Name"];
    [CAUser sharedUser].profile_ImageName=dictionary[@"image"]?dictionary[@"image"]:dictionary[@"Image"];
    [CAUser sharedUser].password=dictionary[@"password"];
    [CAUser sharedUser].about_me =dictionary[@"about_me"];
    [CAUser sharedUser].category = dictionary[@"category"];
}

+(CAUser*)sharedUser{
    
    @synchronized([CAUser class]) {
        
        return _user?_user:[[self alloc] init];
        
    }
    return nil;
}

+(CAUser *)userWithDetails:(NSDictionary *) userDetails{
    
    @synchronized([CAUser class]) {
        [CAUser saveLoggedUser:userDetails];
        _user=[[self alloc] initWithUserDetails:userDetails];
        return _user;
        
    }
    return nil;
}

+(void)loginWithUsername:(NSString *)username password:(NSString *)password withCompletionBlock:(void (^)(BOOL,  CAUser *, NSError*))completionBlock{
    
    NSMutableData *body = [NSMutableData postData];
    [body addValue:username forKey:@"name"];
    [body addValue:password forKey:@"password"];
    NSString *deviceToken=[[NSUserDefaults standardUserDefaults]valueForKey:@"DeviceToken"] ;
    [body addValue:deviceToken forKey:@"token"];
    
    [CAServiceManager fetchDataFromService:@"signin.php?" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
         NSLog(@"Result %@",result);
         success ? [result[@"Result"] isEqualToString:@"Success"] ? completionBlock(YES,[self userWithDetails:result[@"Details"][0]],nil) : completionBlock(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Incorrect username or password or account not activated"}]) : completionBlock(NO,nil,error);
     }];
}

+(void)signUpWithFB:(NSString *)facebookId email:(NSString *)email name:(NSString *)name profileImg:(NSString *)profileImg withCompletionBlock:(void (^)(BOOL, CAUser *, NSError *))completionBlock{
    NSMutableData *body = [NSMutableData postData];
    [body addValue:facebookId forKey:@"facebook_id"];
    [body addValue:email forKey:@"email"];
    [body addValue:name forKey:@"name"];
    [body addValue:UIImageJPEGRepresentation([self convertProfileImage:profileImg] , 0.4) forKey:@"file" withFileName:[self makeFileName ]];

    [CAServiceManager fetchDataFromService:@"facebooklogin.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error) {
        
        if (success) {
            if ([result[@"status"] isEqualToString:@"success"]) {
                completionBlock(YES,[self userWithDetails:result[@"result"]],nil);
            }
            else{
                completionBlock(NO,nil,error);
            }
        }
    }];
}

+(UIImage *)convertProfileImage:(NSString *)imageURL{
    NSData *profileImgData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageURL]];
    return [UIImage imageWithData:profileImgData];
}

//-(NSData *)getFBDetailsAsData{
//    NSMutableData *body = [NSMutableData postData];
//    [body addValue:self.facebook_id forKey:@"facebook_id"];
//    [body addValue:self.emailId forKey:@"email"];
//    [body addValue:self.userName forKey:@"name"];
//    [body addValue:self.profile_ImageName forKey:@"file"];
//    return body;
//    
//}

-(void)signUpwithCompletionBlock:(void (^)(BOOL, NSError*))completionBlock{
    [CAServiceManager fetchDataFromService:@"signup.php?" withParameters:[self getPropertiesAsData] withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
         _user = nil;
         if (success) {
             
             if ([result[@"status"] isEqualToString:@"success"])
             {
                 //                 [self setValueInObject:result[@"result"]];
                 //                 [CAUser saveLoggedUser:result[@"result"]];
                 _user = self;
                 completionBlock(YES,nil);
                
 
             }
             else
             {
                 completionBlock(NO,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"error"]}]);
                 _user = nil;
             }
         }
         else{
             completionBlock(NO,error);
             _user = nil;
        }
     }];
}
+(void)forgotPasswordWithEmailId:(NSString *)emialId withCompletionBlock:(void (^)(bool, id, NSError *))completion
{       //http://sicsglobal.com/projects/WebT1/rideaside/forgotpassword.php?user_id=25&email_id=dorad686@yahoo.com
    NSMutableData *data = [NSMutableData postData];
    [data addValue:emialId forKey:@"email_id"];
    [CAServiceManager fetchDataFromService:@"forgotpassword.php?" withParameters:data withCompletionBlock:^(BOOL success, id result, NSError *error){
        if (success)
        {
            [result[@"result"] isEqualToString:@"success"] ? completion(true,result,error) : completion(false,result,error);
        }
        else
        {
            completion(false,result,error);
        }
        NSLog(@"Result %@",result);
        
    }];
}
#pragma mark - Sign up
+(void)addUserLocationWithData:(NSData *)data withCompletionBlock:(void (^)(BOOL, NSError*))completionBlock{
    [CAServiceManager fetchDataFromService:@"add_location.php?" withParameters:data withCompletionBlock:^(BOOL success, id result, NSError *error){
        NSLog(@"Result %@",result);
    }];
}

-(NSData *)getPropertiesAsData{
    NSMutableData *body = [NSMutableData postData];
    [body addValue:self.userName forKey:@"name"];
    [body addValue:self.emailId forKey:@"email"];
    [body addValue:self.phoneNumber forKey:@"phone"];
    [body addValue:self.password forKey:@"password"];
    [body addValue:self.about_me forKey:@"about_me"];
    [body addValue:self.category forKey:@"category"];

    [body addValue:[CAUser sharedUser].userId forKey:@"id"];
    NSString *deviceToken=[[NSUserDefaults standardUserDefaults]valueForKey:@"DeviceToken"] ;
    [body addValue:deviceToken.length>0?deviceToken:@"428f838e3f724b24a17f8f50f91e85138cb32d25a3c417792249f0f22fc92fae" forKey:@"device_token"];
    
//    UIImage *image=[UIImage imageNamed:@"back-arrow"];
    NSString *fileName = [CAUser makeFileName];
    [body addValue:UIImageJPEGRepresentation(self.profile_Image, 0.5) forKey:@"file" withFileName:fileName];
    
    return body;
}

-(void)updateUserProfileWithCompletionBlock:(void (^)(BOOL, NSError*))completionBlock{
    
    [CAServiceManager fetchDataFromService:@"edit_profile.php" withParameters:[self getPropertiesAsData] withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
         if (success) {
             if ([result[@"status"] isEqualToString:@"success"])
             {
                 [self updateValues:result[@"result"]];
                 completionBlock(YES,nil);
                 
             }
             else
             {
                 completionBlock(NO,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"error"]}]);
             }
         }
         else{
             
             completionBlock(NO,error);
         }
     }];
    
}

-(void)fetchUsersAroundTripwithTripId:(NSString *)tripId  WithCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock{
    NSMutableData *body=[NSMutableData postData];
    [body addValue:tripId forKey:@"tripid"];
    
    [CAServiceManager fetchDataFromService:@"users_around.php" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
         if(success)
         {
             if ([result[@"status"] isEqualToString:@"Success"])
             {
                 completionBlock(success,[self gettTripUsersArray:result[@"result"]],error);
             }
             else
             {
                 completionBlock(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Users Not Available"}]);
             }
         }
         else{
             
             completionBlock(success,nil,error);
         }
     }];
}

-(void)fetchJoineesListInTripWithTripId:(NSString *)tripId WithCompletionBlock:(void (^)(BOOL, id, NSError *))completionBlock{
    NSMutableData *body=[NSMutableData postData];
    [body addValue:tripId forKey:@"tripid"];
    
    [CAServiceManager fetchDataFromService:@"joineess.php?" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
         if(success)
         {
             if ([result[@"status"] isEqualToString:@"Success"])
             {
                 completionBlock(success,[self gettTripUsersArray:result[@"result"]],error);
             }
             else
             {
                 completionBlock(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Users  Not Available"}]);
             }
         }
         else{
                completionBlock(success,nil,error);
         }
     }];
}


-(void)fetchDriverListAccepted:(NSString *)tripid withCategory:(NSString *)category withCompletion:(void(^)(bool success,id result,NSError*err))completion{
    NSMutableData *body=[NSMutableData postData];
    [body addValue:tripid forKey:@"tripid"];
    [body addValue:category forKey:@"category"];
    [body addValue:[CAUser sharedUser].userId forKey:@"user_id"];
    [CAServiceManager fetchDataFromService:@"list_drivers.php?" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *err) {
        if(success)
        {
            NSLog(@"The result listDrivers %@",result);
            if ([result[@"Result"] isEqualToString:@"success"])
            {
                completion(success,[self gettTripUsersArray:result[@"Details"]],err);
            }
            else
            {
                completion(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Users  Not Available"}]);
            }
        }
        else{
            completion(success,nil,err);
        }

    }];
}

-(void)viewRatingHistoryWithCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock{
    NSMutableData *body=[NSMutableData postData];
    [body addValue:[CAUser sharedUser].userId forKey:@"user_id"];
    [CAServiceManager fetchDataFromService:@"view_rating.php?" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
         if(success)
         {
             if ([result[@"status"] isEqualToString:@"success"])
             {
                 completionBlock(success,[self gettTripUsersArray:result[@"details"]],error);
             }
             else
             {
                 completionBlock(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Users  Not Available"}]);
             }
         }
         else{
             
             completionBlock(success,nil,error);
         }

     }];
}

-(void)fetchRatingAndReviewWithUserId:(NSString *)userId WithCompletionBlock:(void (^)(BOOL, id, NSError *))completionBlock{
        NSMutableData *body=[NSMutableData postData];
       [body addValue:userId  forKey:@"user_id"];
    [CAServiceManager fetchDataFromService:@"view_rating.php?" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
         if(success)
         {
             if ([result[@"status"] isEqualToString:@"success"])
             {
                 completionBlock(success,result[@"details"],error);
             }
             else
             {
                 completionBlock(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Users  Not Available"}]);
             }
         }
         else{
             
             completionBlock(success,nil,error);
         }
         
     }];
}


-(void)fetchProfileDetailsWithUserId:(NSString *)userId WithCompletionBlock:(void (^)(BOOL, id, NSError *))completionBlock{
    NSMutableData *body=[NSMutableData postData];
    [body addValue:userId  forKey:@"rate_user"];
    [body addValue:[CAUser sharedUser].userId  forKey:@"user_id"];
    
    [CAServiceManager fetchDataFromService:@"userdetails.php?" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error)
     {
         if(success)
         {
             if ([result[@"status"] isEqualToString:@"Success"])
             {
                 completionBlock(success,[self gettTripUsersArray:result[@"result"]],error);
             }
             else
             {
                 completionBlock(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Users  Not Available"}]);
             }
         }
         else{
             
             completionBlock(success,nil,error);
         }
    }];
    
}

+(void)fetchUsersTotalRatingCountWithCompletion:(void(^)(bool success,id result,NSError *error))completion{
    
    NSMutableData *body = [NSMutableData postData];
    [body addValue:[CAUser sharedUser].userId forKey:@"user_id"];
    
    [CAServiceManager fetchDataFromService:@"sum_rating.php?" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error) {
       
        if (success) {
            if ([result[@"status"] isEqualToString:@"success"]) {
                completion(YES,result[@"count"],nil);
            }else{
                completion(YES,nil,nil);
            }
        }
        
    }];
}

#pragma mark making FileName For Attachments
+(NSString *)makeFileName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyMMddHHmmssSSS"];
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    int randomValue = arc4random() % 1000;
    
    NSString *fileName = [NSString stringWithFormat:@"%@%d.jpg",dateString,randomValue];
    
    return fileName;
}

-(NSMutableArray*)gettTripUsersArray:(NSMutableArray *)arraydata
{
    NSMutableArray *tripArrayList=[[NSMutableArray alloc]init];
    [arraydata enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CAUser *newPost=[[CAUser alloc]initWithUserDetails:obj];
        [tripArrayList addObject:newPost];
        
    }];
    return tripArrayList;
}


+(void)parseLogoutwithCompletionBlock:(void (^)(BOOL, NSError*))completionBlock{
    NSMutableData *body=[NSMutableData postData];
    [body addValue:[CAUser sharedUser].userId forKey:@"userid"];
    [CAServiceManager fetchDataFromService:@"logout.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error){
        success ? [result[@"Result"] isEqualToString:@"Success"] ? completionBlock(YES,nil) : completionBlock(NO,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:[result[@"Result"] isEqualToString:@"Failed"]?@"User doesnot exist":result[@"error"]}]) : completionBlock(NO,error);
        
    }];
}

+(void)parsePaymentDetailsToBackEndWithTripId:(NSString *)tripId andTripName:(NSString *)tripName andAmount:(NSString *)tripAmount  WithCompletionBlock:(void (^)(BOOL, NSError*))completionBlock{
    NSMutableData *body=[NSMutableData postData];
    [body addValue:[CAUser sharedUser].userId forKey:@"user_id"];
    [body addValue:tripId forKey:@"trip_id"];
    [body addValue:tripName forKey:@"trip_name"];
    [body addValue:tripAmount forKey:@"amount"];
    [CAServiceManager fetchDataFromService:@"payment.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error){
        success ? [result[@"status"] isEqualToString:@"Success"] ? completionBlock(YES,nil) : completionBlock(NO,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"Message"]?result[@"Message"]:result[@"error"]}]) : completionBlock(NO,error);
        
    }];
    
}

+(void)parseReviewingadRaringOfUseriD:(NSString *)userId withReview:(NSString *)review withRateValue:(NSString *)rateValue WithCompletionBlock:(void (^)(BOOL, NSError*))completionBlock{
    NSMutableData *body=[NSMutableData postData];
    [body addValue:[CAUser sharedUser].userId forKey:@"user_id"];
    [body addValue:userId forKey:@"rate_user"];
    [body addValue:rateValue forKey:@"rating"];
    [body addValue:review forKey:@"review"];
    [CAServiceManager fetchDataFromService:@"rating.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error){
        success ? [result[@"status"] isEqualToString:@"Success"] ? completionBlock(YES,nil) : completionBlock(NO,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"Message"]?result[@"Message"]:result[@"error"]}]) : completionBlock(NO,error);
        
    }];
    
}

#pragma mark saveLoggedUserAutoLogin
+ (void)saveLoggedUser:(NSDictionary *)dictionary
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kLoggeduserdetails];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
