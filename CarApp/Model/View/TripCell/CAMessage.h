//
//  CAMessage.h
//  SampleChat
//
//  Created by Aswin on 02/06/14.
//  Copyright (c) 2014 Aswin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CAMessage : NSObject

@property (nonatomic, strong) NSString *messageText;
@property (nonatomic, strong) UIImage *messageImage;
@property (nonatomic, strong) NSDate *messageTime;
@property (nonatomic, strong) NSString *chat_id;
@property (nonatomic, strong) NSString *sender_id;
@property (nonatomic, strong) NSString *sender_name;
@property (nonatomic, strong) NSString *sender_picture;
-(id)initWithDictionary:(NSDictionary *)dicData;
+(void)listTheChatWithtripId:(NSString *)tripId index:(int)index completion:(void(^)(BOOL,id result,NSError *))completion;
+(void)insertChatWIthSenderId:(NSString *)senderId tripId:(NSString *)tripId chatMessage:(NSString *)chatMessage completion:(void (^)(BOOL, id, NSError *))completion;
+(void)checkForNewChatWithTripId:(NSString *)tripId chatId:(NSString *)chatId completion:(void(^)(BOOL,id result,NSError*))completion;
/*
 chat_id: "1",
 sender_id: "2",
 sender_name: "leema",
 sender_picture: "",
 message: "hello",
 chat_image: "",
 time: "2015-04-06 13:07:38"
 */
@end
