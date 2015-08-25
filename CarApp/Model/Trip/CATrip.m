//
//  CATrip.m
//  RoadTrip
//
//  Created by SICS on 19/08/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CATrip.h"
#import "CAUser.h"
#import "NSMutableData+PostDataAdditions.h"
#import "CAServiceManager.h"
#import "NSDate+TimeZone.h"
#import "CATripReview.h"


@implementation CATrip



-(id)initWithDictionary :(NSMutableDictionary *)dictionary
{
    self=[super init];
    if (self) {
        if ([dictionary[@"UserId"] integerValue] == [CAUser sharedUser].userId.integerValue) {
            self.StartingPlace=dictionary[@"StartingPlace"];
            self.UserId=dictionary[@"UserId"];
            self.EndPlace=dictionary[@"EndPlace"];
            self.FuelExpenses=dictionary[@"FuelExpenses"];
            self.TollBooth=dictionary[@"TollBooth"];
            self.TotalKilometer=dictionary[@"TotalKilometer"];
            self.Vehicle=dictionary[@"Vehicle"];
            self.SeatsAvailable=dictionary[@"SeatsAvailable"];
            self.date=[[NSDate alloc]changeServerTimeZoneToLocalForDate:dictionary[@"DateTime"]];
            self.startPlaceLocation=dictionary[@"startPlaceLocation"];
            self.email = [CAUser sharedUser].emailId;
            self.endPlaceLocation=dictionary[@"endPlaceLocation"];
            self.name=[CAUser sharedUser].userName;
            self.imageName=[CAUser sharedUser].profile_ImageName;
            self.tripId=dictionary[@"TripId"];
            self.tripName=dictionary[@"Tripname"];
            self.cost=dictionary[@"Cost"];
            self.vehicleNumber=dictionary[@"VehicleNumber"];
            self.tripPostedById=dictionary[@"OwnerId"];
            self.tripStartTimeForNotification=dictionary[@"StartTimeNotification"];
            self.category = dictionary[@"addedBy"] ? :dictionary[@"addedBy"];
            self.visibility = [CAUser sharedUser].visibility;
            self.phoneNumber = [CAUser sharedUser].phoneNumber;
            self.carImageName = dictionary[@"Vehicle_image"];
            self.facebookId = dictionary[@"facebook_id"];
            self.latitude = dictionary[@"latitude"] ;
            self.longitude = dictionary[@"longitude"];
        }
        else
        {
        self.StartingPlace=dictionary[@"StartingPlace"];
        self.UserId=dictionary[@"UserId"];
        self.EndPlace=dictionary[@"EndPlace"];
        self.FuelExpenses=dictionary[@"FuelExpenses"];
        self.TollBooth=dictionary[@"TollBooth"];
        self.TotalKilometer=dictionary[@"TotalKilometer"];
        self.Vehicle=dictionary[@"Vehicle"];
        self.SeatsAvailable=dictionary[@"SeatsAvailable"];
        self.date=[[NSDate alloc]changeServerTimeZoneToLocalForDate:dictionary[@"DateTime"]];
        self.startPlaceLocation=dictionary[@"startPlaceLocation"];
        self.email = dictionary[@"email_id"];
        self.endPlaceLocation=dictionary[@"endPlaceLocation"];
        self.name=dictionary[@"name"]?dictionary[@"name"]:dictionary[@"Name"];
        self.imageName=dictionary[@"image"]?dictionary[@"image"]:dictionary[@"Image"];
        self.tripId=dictionary[@"TripId"];
        self.tripName=dictionary[@"Tripname"];
        self.cost=dictionary[@"Cost"];
        self.vehicleNumber=dictionary[@"VehicleNumber"];
        self.tripPostedById=dictionary[@"OwnerId"];
        self.tripStartTimeForNotification=dictionary[@"StartTimeNotification"];
        self.category = dictionary[@"addedBy"] ? :dictionary[@"addedBy"];
        self.visibility = dictionary[@"visibility"];
        self.phoneNumber = dictionary[@"MobileNumber"];
            self.carImageName = dictionary[@"Vehicle_image"];
            NSLog(@"%@    %@",self.carImageName,dictionary[@"Vehicle_image"]);
        self.latitude = dictionary[@"latitude"] ;
        self.longitude = dictionary[@"longitude"];
            self.rateValue = dictionary[@"Rating"];
            self.facebookId = dictionary[@"facebook_id"];

        }
        if ([[dictionary objectForKey:@"joinees"] isKindOfClass:[NSArray class]]) {
            if ([[dictionary objectForKey:@"joinees"] count]) {
                NSMutableArray *arrayUser = [NSMutableArray new];
                [[dictionary objectForKey:@"joinees"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    
                    CAUser *joinees =  [[CAUser alloc] init];
                    joinees.userId=self.UserId;
                    joinees.userName=self.name;
                    joinees.emailId=self.email;
                    joinees.phoneNumber=self.phoneNumber;
                    joinees.profile_ImageName=self.imageName;
                    joinees.latitude= self.latitude;
                    joinees.longitude=self.longitude;
                    joinees.category = self.category;
                    joinees.car_image1 = self.carImageName;
                    NSLog(@"%@",joinees.car_image1);
                    joinees.car_name1 = self.Vehicle;
                    joinees.car_licence_num1 = self.vehicleNumber;
                    joinees.rateValue = self.rateValue;
                    joinees.facebook_id = self.facebookId;
                    [arrayUser addObject:joinees];
                    if ([[dictionary objectForKey:@"joinees"] count]) {
                        CAUser *joinees =  [[CAUser alloc] init];
                        joinees.userId=obj[@"joine_id"];
                        joinees.userName=obj[@"joinee_name"];
                        joinees.emailId=obj[@"joinee_email"];
                        joinees.phoneNumber=obj[@"joinee_mobile"];
                        joinees.profile_ImageName=obj[@"joinee_image"];
                        joinees.latitude=obj[@"lattitude"];
                        joinees.longitude=obj[@"longitude"];
                        joinees.category = obj[@"category"];
                        joinees.rateValue = obj[@"joinee_rating"];
                        joinees.facebook_id = obj[@"joinee_facebook_id"];
                        [arrayUser addObject:joinees];
                        
                    }
                    
                }];
                self.arrayJoinees = arrayUser.mutableCopy;
            }

        }
        else
        {
            NSMutableArray *arrayUser = [NSMutableArray new];
            CAUser *joinees =  [[CAUser alloc] init];
            joinees.userId=self.UserId;
            joinees.userName=self.name;
            joinees.emailId=self.email;
            joinees.phoneNumber=self.phoneNumber;
            joinees.profile_ImageName=self.imageName;
            joinees.latitude= self.latitude;
            joinees.longitude=self.longitude;
            joinees.category=self.category;
            joinees.car_image1 = self.carImageName;
                                NSLog(@"%@",joinees.car_image1);
            joinees.car_name1 = self.Vehicle;
            joinees.car_licence_num1 = self.vehicleNumber;
            joinees.rateValue = self.rateValue;
            joinees.facebook_id = self.facebookId;
            [arrayUser addObject:joinees];
            self.arrayJoinees = arrayUser.mutableCopy;
            
        }
        
    }
    return self;
}

-(void)getTripDetailswithPath:(NSString *)path withSearchString:(NSString *)searchString withIndex:(NSInteger)index withMiles:(NSInteger)milesIndex withOptionForTripDetailIndex:(NSUInteger)indexOfTripDetailIndex withCompletionBlock:(void (^)(BOOL,id,id, NSError*))completionBlock
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
     NSMutableData *body = [NSMutableData postData];
    [body addValue:[CAUser sharedUser].userId forKey:@"userid"];
    [body addValue:[NSString stringWithFormat:@"%ld",(long)index] forKey:@"index"];
    [body addValue:searchString.length>0?searchString:@"" forKey:@"search"];
    [body addValue:[NSString stringWithFormat:@"%ld",(long)indexOfTripDetailIndex] forKey:@"status"];
    [body addValue:[NSString stringWithFormat:@"%ld",(long)milesIndex] forKey:@"distance"];
    [body addValue:[CATrip changeLocalTimeZoneToServerForDate:[dateFormatter stringFromDate:[NSDate date]]] forKey:@"date"];
    
    NSLog(@"http://sicsglobal.com/projects/App_projects/rideaside/%@?userid=%@&index=%ld&search=%@&status=%lu&date=%@&distance=%ld",path,[CAUser sharedUser].userId,(long)index,searchString.length>0?searchString:@"",(unsigned long)indexOfTripDetailIndex,[CATrip changeLocalTimeZoneToServerForDate:[dateFormatter stringFromDate:[NSDate date]]],(long)milesIndex);
    
    
    [CAServiceManager fetchDataFromService:path withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error)
     {
         NSLog(@"resulr  %@",result);
         if(success)
         {
             if ([result[@"status"] isEqualToString:@"success"])
             {
                // NSLog(@"Rsult trip list %@",result);

                 [result[@"result"] isKindOfClass:[NSArray class]]? completionBlock(success,[self gettTripArray:result[@"result"]],[self gettTripArray:result[@"created_rides"]],error):  completionBlock(NO,nil,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Trips Not Available"}]);
             }
             else
             {
                 
                 [result[@"created_rides"] isKindOfClass:[NSArray class]] && [result[@"created_rides"] count] ?  completionBlock(success,nil,[self gettTripArray:result[@"created_rides"]],error) :completionBlock(NO,nil,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Post Not Available"}]);
             }
         }
         else{
             
             completionBlock(success,nil,nil,error);
         }
         
     }];
}
+ (NSString *)changeLocalTimeZoneToServerForDate:(NSString *)date
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *localDate = [dateFormatter dateFromString:date];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Paris"]];
    NSDate *utcDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:localDate]];
    NSString *utcTime = [dateFormatter stringFromDate:utcDate];
    
    return utcTime;
    
}

-(void)fetchRequestsWithIndex:(NSString *)index withPath:(NSString *)path CompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock{
    
    NSMutableData *body = [NSMutableData postData];
    [body addValue:[CAUser sharedUser].userId forKey:@"UserId"];

    [CAServiceManager fetchDataFromService:path withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error)
     {
         if(success)
         {
             if ([result[@"Result"] isEqualToString:@"Success"])
             {
                 [result[@"Details"] isKindOfClass:[NSArray class]]? completionBlock(success,[self gettTripArray:result[@"Details"]],error):  completionBlock(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Trips Not Available"}]);
             }
             else
             {
                 completionBlock(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Post Not Available"}]);
             }
         }
         else{
             
             completionBlock(success,nil,error);
         }
         

     }];
}
+(void)editTrip:(CATrip *)trip completion:(void (^)(BOOL,id result, NSError *))completion
{
//http://sicsglobal.com/projects/WebT1/rideaside/edit_trip.php?id=1&startingPlace=trivandrum&endingPlace=kochi&datetime=2014-08-20%2017:21:13&fuelExp=500&tollbooth=no&kilometer=200&vehicle=car&seats=5&trip_name=Longdrive&vehicle_number=123&cost=1 Edit Trip
  
    NSMutableData *body=[NSMutableData postData];
    [body addValue:trip.tripId forKey:@"id"];
    [body addValue:trip.StartingPlace forKey:@"startingPlace"];
    [body addValue:trip.EndPlace forKey:@"endingPlace"];
    [body addValue:trip.date forKey:@"datetime"];
    [body addValue:trip.FuelExpenses forKey:@"fuelExp"];
    [body addValue:trip.TollBooth forKey:@"tollbooth"];
    [body addValue:trip.TotalKilometer forKey:@"kilometer"];
    [body addValue:trip.Vehicle forKey:@"vehicle"];
    [body addValue:trip.SeatsAvailable forKey:@"seats"];
    [body addValue:trip.tripName forKey:@"trip_name"];
    [body addValue:trip.vehicleNumber forKey:@"vehicle_number"];
    [body addValue:trip.cost forKey:@"cost"];
    [body addValue:trip.tripStartTimeForNotification forKey:@"alert_date"];
    NSString *fileName = [CATrip makeFileName];

     [body addValue:UIImageJPEGRepresentation(trip.imageCar, 0.5) forKey:@"vehicle_image" withFileName:fileName];
    [CAServiceManager fetchDataFromService:@"edit_trip.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error)
     {
         NSLog(@"FETCH RESULT - %@",result);
         success ? [result[@"Result"] isEqualToString:@"Success"] ? completion(YES,[[CATrip alloc]initWithDictionary:[result valueForKey:@"Message"]],nil) : completion(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"error"]}]) : completion(NO,nil,error);
         
     }];

}
+(NSString *)makeFileName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyMMddHHmmssSSS"];
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    int randomValue = arc4random() % 1000;
    
    NSString *fileName = [NSString stringWithFormat:@"%@%d.jpg",dateString,randomValue];
    
    return fileName;
}
-(void)addTripWithDataWithTrip:(CATrip*)trip  CompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock;{
    NSMutableData *body=[NSMutableData postData];
    [body addValue:[CAUser sharedUser].userId forKey:@"userid"];
    [body addValue:trip.StartingPlace forKey:@"startingPlace"];
    [body addValue:trip.EndPlace forKey:@"endingPlace"];
    [body addValue:trip.date forKey:@"datetime"];
    [body addValue:trip.FuelExpenses forKey:@"fuelExp"];
    [body addValue:trip.TollBooth forKey:@"tollbooth"];
    [body addValue:trip.TotalKilometer forKey:@"kilometer"];
    [body addValue:trip.Vehicle forKey:@"vehicle"];
    [body addValue:trip.SeatsAvailable forKey:@"seats"];
    [body addValue:trip.tripName forKey:@"trip_name"];
    [body addValue:trip.vehicleNumber forKey:@"vehicle_number"];
    [body addValue:trip.cost forKey:@"cost"];
    [body addValue:trip.tripStartTimeForNotification forKey:@"alert_date"];
    [body addValue:trip.addedBy forKey:@"addedBy"];
    NSString *fileName = [CATrip makeFileName];
    
    [body addValue:UIImageJPEGRepresentation(trip.imageCar, 0.5) forKey:@"vehicle_image" withFileName:fileName];
    [CAServiceManager fetchDataFromService:@"addtripyy.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error)
     {
         NSLog(@"FETCH RESULT - %@",result);
         success ? [result[@"Result"] isEqualToString:@"Success"] ? completionBlock(YES,nil,nil) : completionBlock(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"error"]}]) : completionBlock(NO,nil,error);
         
     }];
}

-(NSMutableArray*)gettTripArray:(NSMutableArray *)arraydata
{
    NSMutableArray *tripArrayList=[[NSMutableArray alloc]init];
    [arraydata enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CATrip *newPost= [obj isKindOfClass:[NSMutableDictionary class]]?[[CATrip alloc]initWithDictionary:obj]:nil;
        [tripArrayList addObject:newPost];
        
    }];
    return tripArrayList;
}

+(CATrip *)getTripDetail:(NSDictionary *)userInfo{
    CATrip *trip=[[CATrip alloc]init];
    trip.StartingPlace=userInfo[@"Staring Place"];
    trip.EndPlace=userInfo[@"Ending Placer"];
    trip.FuelExpenses=userInfo[@"FuelExp"];
    trip.TotalKilometer=userInfo[@"Kilometer"];
    trip.StartingPlace=userInfo[@"Staring Place"];
    trip.date=userInfo[@"Time"];
    trip.TollBooth=userInfo[@"Tollbooth"];
    trip.tripName=userInfo[@"Trip Name"];
    trip.tripPostedById=[NSString stringWithFormat:@"%@",userInfo[@"Trip Owner"]];
    trip.Vehicle=userInfo[@"Vehicle"];
    trip.vehicleNumber=userInfo[@"Vehicle number"];
    trip.cost=userInfo[@"cost"];
    trip.tripId=userInfo[@"Tripid"];
    trip.SeatsAvailable=userInfo[@"Seats"];
    trip.category = userInfo[@"category"];
    return  trip;
}

+(void)acceptOrRejectTrip:(CATrip*)trip withStatus:(NSString *)status CompletionBlock:(void (^)(BOOL, NSError*))completionBlock{
    
    NSMutableData *body=[NSMutableData postData];
    [body addValue:trip.tripId forKey:@"tripid"];
    [body addValue:[CAUser sharedUser].userId forKey:@"joineeid"];
    [body addValue:[CAUser sharedUser].latitude forKey:@"lattitude"];
    [body addValue:[CAUser sharedUser].longitude forKey:@"longitude"];
    [body addValue:[CAUser sharedUser].category forKey:@"category"];
    [body addValue:status forKey:@"status"];
    
    
    [CAServiceManager fetchDataFromService:@"accept_trip.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error)
     {
         success ? [result[@"status"] isEqualToString:@"Success"] ? completionBlock(YES,nil) : completionBlock(NO,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"Message"]?result[@"Message"]:result[@"error"]}]) : completionBlock(NO,error);
         
     }];
}

+(void)acceptOrRejectTripForDriver:(CATrip*)trip withStatus:(NSString*)status completion:(void(^)(bool,NSError*))completion{
    NSMutableData *body = [NSMutableData postData];
    [body addValue:trip.tripId forKey:@"tripid"];
    [body addValue:[CAUser sharedUser].userId forKey:@"joineeid"];
    [body addValue:status forKey:@"status"];
    NSLog(@"tripid%@,userid%@,status%@",trip.tripId,[CAUser sharedUser].userId,status);
    [CAServiceManager fetchDataFromService:@"accept_tripDriver.php?" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error) {
        NSLog(@"the result accept or reject is %@",result);
        success ? [result[@"status"] isEqualToString:@"Success"] ? completion(YES,nil) : completion(NO,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"Message"]?result[@"Message"]:result[@"error"]}]) : completion(NO,error);
    }];
}

+(void)selectDriverForTrip:(CATrip*)trip completion:(void(^)(BOOL,NSError*))completion{
    NSMutableData *body = [NSMutableData postData];
    [body addValue:trip.tripId forKey:@"tripid"];
    [body addValue:[CAUser sharedUser].userId forKey:@"joineeid"];
    [CAServiceManager fetchDataFromService:@"select_driver.php?" withParameters:body withCompletionBlock:^(BOOL success, id result, NSError *error) {
        
        success ? [result[@"status"] isEqualToString:@"Success"] ? completion(YES,nil) : completion(NO,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"Message"]?result[@"Message"]:result[@"error"]}]) : completion(NO,error);

    }];
}

+(void)inviteTripWithTripId:(NSString *)tripId andAppuserId:(NSString *)userId completion:(void (^)(BOOL, id, NSError *))completion{
    //http://sicsglobal.com/projects/WebT1/rideaside/inviite_frnds.php?trip_id=1&phone_num=123456789
    NSMutableData *body=[NSMutableData postData];
    [body addValue:tripId forKey:@"id"];
    [body addValue:userId forKey:@"userid"];
    [CAServiceManager fetchDataFromService:@"inviite_frnds.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error)
     {
         NSLog(@"FETCH RESULT - %@",result);
         success ? [result[@"Result"] isEqualToString:@"Success"] ? completion(YES,result,nil) : completion(NO,nil,error) : completion(NO,nil,error);
         
     }];

    
}
+(void)listTheAppUserwithCompletionBlock:(void (^)(bool, id, NSError *))completion
{
    //http://sicsglobal.com/projects/App_projects/rideaside/list_users.php?userId=14&lattitude=8.487500&longitude=76.952500
    NSMutableData *body=[NSMutableData postData];
    [body addValue:[CAUser sharedUser].userId forKey:@"userId"];
    [body addValue:[CAUser sharedUser].latitude forKey:@"lattitude"];
    [body addValue:[CAUser sharedUser].longitude forKey:@"longitude"];
    
    [CAServiceManager fetchDataFromService:@"list_users.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error){
        CATrip *user = [[CATrip alloc]init];
        
        success ? [result[@"status"] isEqualToString:@"success"] ? completion(YES,[user gettTripArray:result[@"result"]],nil) : completion(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"Message"]?result[@"Message"]:result[@"error"]}]) : completion(NO,nil,error);
        
    }];
    
}
+(void)submitReviewWithRatedUserId:(NSString *)ratedUserId withtripId:(NSString *)tripId answer:(NSString *)answer completion:(void (^)(BOOL, id, NSError *))completion
{
    //http://sicsglobal.com/projects/App_projects/rideaside/review.php?userId=1&rateduserId=2&tripId=1&questionId=1,2,3,4&answer=Always,No,Not%20at%20al,Amazing
    NSMutableData *body=[NSMutableData postData];
    [body addValue:[CAUser sharedUser].userId forKey:@"userId"];
    [body addValue:ratedUserId forKey:@"rateduserId"];
    [body addValue:tripId forKey:@"tripId"];
    [body addValue:@"1,2,3,4" forKey:@"questionId"];
    [body addValue:answer forKey:@"answer"];
    
    [CAServiceManager fetchDataFromService:@"review.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error){

        
        success ? [result[@"result"] isEqualToString:@"success"] ? completion(YES,result,nil) : completion(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"Message"]?result[@"Message"]:result[@"error"]}]) : completion(NO,nil,error);
        
    }];
}

+(void)fetchReviewWithUserId:(NSString *)userId completion:(void (^)(BOOL, id, NSError *))completion
{
    //http://sicsglobal.com/projects/App_projects/rideaside/view_reviews.php?userId=2
    NSMutableData *body=[NSMutableData postData];
    [body addValue:userId forKey:@"userId"];
    [CAServiceManager fetchDataFromService:@"view_reviews.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error){
        
        
        success ? [result[@"result"] isEqualToString:@"success"] ? completion(YES,[CATrip getRating:result],nil) : completion(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"Message"]?result[@"Message"]:result[@"error"]}]) : completion(NO,nil,error);
        
    }];
}
+(NSArray *)getRating:(id)result
{
    
   
    
    NSMutableArray *arrayReview = [NSMutableArray new];
    
    [result[@"Trips"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dictRatings1 = [[obj valueForKey:@"user_category"] isEqualToString:@"passenger"] ?  @{@"reviewQuestion1":@"Was the passenger respectful?",@"reviewQuestion2":@"Was it difficult to set up the trip with the passenger?",@"reviewQuestion3" :@"Did you have any Problems with receiving your payment from the passenger?",@"reviewQuestion4":@"How was your RideAside experience with this Passenger?"} : @{@"reviewQuestion1" :@"Was the driver Respectful?",@"reviewQuestion2":@"Was the Driver a Safe Driver?",@"reviewQuestion3":@"Does the driver speed?",@"reviewQuestion4":@"How was your RideAside experience with the Driver?"};
        CATripReview *reviewTrip = [[CATripReview alloc] initWithDictionary:obj andQuestion:dictRatings1];
//    CAReview *review = [[CAReview alloc] initWithDictionary:result andQuestion:dictRatings1];
        [arrayReview addObject:reviewTrip];
    }];
    
    
    return arrayReview;
}
@end
