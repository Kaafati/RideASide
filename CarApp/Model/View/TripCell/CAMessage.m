//
//  CAMessage.m
//  SampleChat
//
//  Created by Aswin on 02/06/14.
//  Copyright (c) 2014 Aswin. All rights reserved.
//

#import "CAMessage.h"
#import "NSMutableData+PostDataAdditions.h"
#import "CAServiceManager.h"

@implementation CAMessage

-(id)initWithDictionary:(NSDictionary *)dicData
{
    self=[super init];
    if (self) {
        _chat_id=dicData[@"chatid"];
        _sender_id=dicData[@"userid"];
        _sender_name=dicData[@"name"];
        _messageImage=dicData[@"image"];
        _messageText=dicData[@"message"];
        _sender_picture = dicData[@"image"];
        _messageTime= [self getDateFromString: dicData[@"datetime"]];//dicData[@"time"];//
        /*
         chat_id: "1",
         sender_id: "2",
         sender_name: "leema",
         sender_picture: "",
         message: "hello",
         chat_image: "",
         time: "2015-04-06 13:07:38"
         */
    }
    return self;
}
-(NSDate*)getDateFromString:(NSString*)time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter dateFromString:time];
    
}

+(void)listTheChatWithtripId:(NSString *)tripId index:(int)index completion:(void(^)(BOOL,id result,NSError *))completion{
   // http://sicsglobal.com/projects/WebT1/rideaside/viewchat.php?tripid=1&index=0
    NSMutableData *body=[NSMutableData postData];
    [body addValue:tripId forKey:@"tripid"];
    [body addValue:[NSString stringWithFormat:@"%d",index] forKey:@"index"];
    [CAServiceManager fetchDataFromService:@"viewchat.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error)
     {
         NSLog(@"FETCH RESULT - %@",result);
         success ? [result[@"result"] isEqualToString:@"success"] ? completion(YES,[CAMessage getAllChatWithResult:result[@"chatdetails"]],nil) : completion(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"chatdetails"]}]) : completion(NO,nil,error);
         
     }];
}
+(NSArray *)getAllChatWithResult:(id)result
{
    NSLog(@"result %@",result);
    NSMutableArray *arrayChat  = [NSMutableArray new];
    NSArray * arrayFinal;
    [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CAMessage *message = [[CAMessage alloc]initWithDictionary:obj];
        [arrayChat addObject:message];
    }];

    return arrayFinal = arrayChat.mutableCopy;
}
+(void)insertChatWIthSenderId:(NSString *)senderId tripId:(NSString *)tripId chatMessage:(NSString *)chatMessage completion:(void (^)(BOOL, id, NSError *))completion
{
    //http://sicsglobal.com/projects/WebT1/rideaside/addchat.php?tripid=1&userid=2&message=hello
    NSMutableData *body=[NSMutableData postData];
        [body addValue:tripId forKey:@"tripid"];
        [body addValue:senderId forKey:@"userid"];
        [body addValue:chatMessage forKey:@"message"];
    [CAServiceManager fetchDataFromService:@"addchat.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error)
     {
         NSLog(@"FETCH RESULT - %@",result);
         success ? [result[@"result"] isEqualToString:@"success"] ? completion(YES,result,nil) : completion(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"chatdetails"]}]) : completion(NO,nil,error);
         
     }];

}
+(void)checkForNewChatWithTripId:(NSString *)tripId chatId:(NSString *)chatId completion:(void(^)(BOOL,id result,NSError*))completion
{
    //http://sicsglobal.com/projects/WebT1/rideaside/viewlatestchat.php?tripid=1&chatid=24
    NSMutableData *body=[NSMutableData postData];
    [body addValue:tripId forKey:@"tripid"];
    [body addValue:chatId forKey:@"chatid"];
    [CAServiceManager fetchDataFromService:@"viewlatestchat.php?" withParameters:body withCompletionBlock:^(BOOL success,id result, NSError *error)
     {
         NSLog(@"FETCH RESULT - %@",result);
         success ? [result[@"result"] isEqualToString:@"success"] ? completion(YES,[CAMessage getAllChatWithResult:result[@"chatdetails"]],nil) : completion(NO,nil,[NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:result[@"chatdetails"]}]) : completion(NO,nil,error);
         
     }];
}
@end
