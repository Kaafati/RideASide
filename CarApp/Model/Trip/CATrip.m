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



@implementation CATrip



-(id)initWithDictionary :(NSMutableDictionary *)dictionary
{
    self=[super init];
    if (self) {
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
        self.endPlaceLocation=dictionary[@"endPlaceLocation"];
        self.name=dictionary[@"name"]?dictionary[@"name"]:dictionary[@"Name"];
        self.imageName=dictionary[@"image"]?dictionary[@"image"]:dictionary[@"Image"];
        self.tripId=dictionary[@"TripId"];
        self.tripName=dictionary[@"Tripname"];
        self.cost=dictionary[@"Cost"];
        self.vehicleNumber=dictionary[@"VehicleNumber"];
        self.tripPostedById=dictionary[@"OwnerId"];
        self.tripStartTimeForNotification=dictionary[@"StartTimeNotification"];
        
        
        
        
    }
    return self;
}
-(void)getTripDetailswithPath:(NSString *)path withSearchString:(NSString *)searchString withIndex:(NSInteger)index  withOptionForTripDetailIndex:(NSUInteger)indexOfTripDetailIndex withCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    
    
     NSMutableData *body = [NSMutableData postData];
    [body addValue:[CAUser sharedUser].userId forKey:@"userid"];
    [body addValue:[NSString stringWithFormat:@"%ld",(long)index] forKey:@"index"];
    [body addValue:searchString.length>0?searchString:@"" forKey:@"search"];
    [body addValue:[NSString stringWithFormat:@"%ld",(long)indexOfTripDetailIndex] forKey:@"status"];
    [body addValue:[CATrip changeLocalTimeZoneToServerForDate:[NSString stringWithFormat:@"%@",[NSDate date]]] forKey:@"date"];
    
//    NSLog(@"http://sicsglobal.com/projects/WebT1/roadtripapp/%@?userid=%@&index=%d&search=%@&status=%d",path,[CAUser sharedUser].userId,index,searchString.length>0?searchString:@"",indexOfTripDetailIndex);
    
    
    [CAServiceManager fetchDataFromService:path withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error)
     {
         if(success)
         {
             if ([result[@"status"] isEqualToString:@"success"])
             {
                 [result[@"result"] isKindOfClass:[NSArray class]]? completionBlock(success,[self gettTripArray:result[@"result"]],error):  completionBlock(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Trips Not Available"}]);
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
    
    return  trip;
}
+(void)acceptOrRejectTrip:(CATrip*)trip withStatus:(NSString *)status CompletionBlock:(void (^)(BOOL, NSError*))completionBlock{
    
    NSMutableData *body=[NSMutableData postData];
    [body addValue:trip.tripId forKey:@"tripid"];
    [body addValue:[CAUser sharedUser].userId forKey:@"joineeid"];
     [body addValue:status forKey:@"status"];
    
    
    [CAServiceManager fetchDataFromService:@"accept_trip.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error)
     {
         success ? [result[@"status"] isEqualToString:@"Success"] ? completionBlock(YES,nil) : completionBlock(NO,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"Message"]?result[@"Message"]:result[@"error"]}]) : completionBlock(NO,error);
         
     }];
    
    
    
}


@end
