//
//  CATrip.h
//  RoadTrip
//
//  Created by SICS on 19/08/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface CATrip : NSObject
@property(nonatomic,strong)NSString *StartingPlace;
@property(nonatomic,strong)NSString *UserId;
@property(nonatomic,strong)NSString *EndPlace;
@property(nonatomic,strong)NSString *FuelExpenses;
@property(nonatomic,strong)NSString *TollBooth;
@property(nonatomic,strong)NSString *TotalKilometer;
@property(nonatomic,strong)NSString *Vehicle;
@property(nonatomic,strong)NSString *SeatsAvailable;
@property(nonatomic,strong)NSString *date;
@property(nonatomic,strong)CLLocation *startPlaceLocation;
@property(nonatomic,strong)CLLocation *endPlaceLocation;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *imageName;
@property(nonatomic,strong)NSString *tripId;
@property(nonatomic,strong)NSString *tripName;
@property(nonatomic,strong)NSString *cost;
@property(nonatomic,strong)NSString *vehicleNumber;
@property(nonatomic,strong)NSString *tripPostedById;
@property(nonatomic,strong)NSString *tripStartTimeForNotification;
@property(nonatomic,strong)NSString *category;
@property BOOL isSelected;

-(id)initWithDictionary :(NSMutableDictionary *)dictionary;
-(void)getTripDetailswithPath:(NSString *)path withSearchString:(NSString *)searchString withIndex:(NSInteger)index  withOptionForTripDetailIndex:(NSUInteger)indexOfTripDetailIndex withCompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock;

-(void)addTripWithDataWithTrip:(CATrip*)trip  CompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock;
+(void)acceptOrRejectTrip:(CATrip*)trip withStatus:(NSString *)status CompletionBlock:(void (^)(BOOL, NSError*))completionBlock;
+(CATrip *)getTripDetail:(NSDictionary *)userInfo;
-(void)fetchRequestsWithIndex:(NSString *)index withPath:(NSString *)path CompletionBlock:(void (^)(BOOL,id, NSError*))completionBlock;
+(void)acceptOrRejectTripForDriver:(CATrip*)trip withStatus:(NSString*)status completion:(void(^)(bool,NSError*))completion;
+(void)selectDriverForTrip:(CATrip*)trip completion:(void(^)(BOOL,NSError*))completion;
+(void)editTrip:(CATrip *)trip completion:(void(^)(BOOL,id result, NSError *))completion;
+(void)inviteTripWithTripId:(NSString *)tripId andAppuserId:(NSString *)userId completion:(void(^)(BOOL,id result, NSError *))completion;
//http://sicsglobal.com/projects/WebT1/rideaside/PendingTrip.php?UserId=25-Pending Requests
//http://sicsglobal.com/projects/WebT1/rideaside/view_all_trip.php?index=0&search=&userid=25 //Passenger Tab
//http://sicsglobal.com/projects/WebT1/rideaside/view_trip.php?userid=1&index=1 //view my trip
//http://sicsglobal.com/projects/WebT1/rideaside/addtripyy.php?userid=26&startingPlace=trivandrum&endingPlace=kollam&datetime=2014-08-20%2017:21:13&fuelExp=500&tollbooth=no&kilometer=200&vehicle=car&seats=5&trip_name=Longdrive&vehicle_number=123&cost=1 -Add trip
//http://sicsglobal.com/projects/WebT1/rideaside/accept_trip.php?tripid=90&userid=26&joineeid=29&Status=Accept Accept trip link
//http://sicsglobal.com/projects/WebT1/rideaside/accept_tripDriver.php?tripid=2&joineeid=1&status=reject Accept trip for Driver
//http://sicsglobal.com/projects/WebT1/rideaside/select_driver.php?tripid=2&joineeid=1

//[14/10/14 4:35:51 pm] Leeja .: http://sicsglobal.com/projects/WebT1/rideaside/trip_details.php?userid=25&status=2&index=0&search=   Rides Tab
//http://sicsglobal.com/projects/WebT1/rideaside/edit_trip.php?id=1&startingPlace=trivandrum&endingPlace=kochi&datetime=2014-08-20%2017:21:13&fuelExp=500&tollbooth=no&kilometer=200&vehicle=car&seats=5&trip_name=Longdrive&vehicle_number=123&cost=1 Edit Trip//[14/10/14 4:36:17 pm] Leeja .: status=0--->all trips with 10 index
//[14/10/14 4:36:36 pm] Leeja .: status=1 ---->upcoming rides with 10 index
//[14/10/14 4:36:57 pm] Leeja .: status=2----->completed rides with 10 index

//http://sicsglobal.com/projects/WebT1/rideaside/inviite_frnds.php?trip_id=1&phone_num=123456789 Invite 
//
@end
