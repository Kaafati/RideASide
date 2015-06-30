//
//  CAServiceManager.m
//  RoadTrip
//
//  Created by SICS on 19/08/14.
//  Copyright (c) 2014 SICS. All rights reserved.
//

#import "CAServiceManager.h"

@implementation CAServiceManager
{
    NSMutableData *_urlData;
    NSString *_mainURl;
    void (^finishLoading)(BOOL ,id , NSError *);

}
-(id)init{
    self = [super init];
    if (self) {
        
        //http://sicsglobal.com/projects/App_projects/rideaside/accept_trip.php
        
        _mainURl=@"http://sicsglobal.com/projects/App_projects/rideaside/";
        
    }
    return self;
}
+(void)fetchDataFromService:(NSString *)serviceName withParameters:(id)parameters withCompletionBlock:(void(^)(BOOL ,id , NSError *))completion{
    
    CAServiceManager *conectionRequest = [self new];
    
    [conectionRequest httpRequestForService:serviceName withParameters:parameters inCompletionBlock:^(BOOL success, id result, NSError *error) {
        completion(success,result,error);
    }];
    
}

+(void)handleError:(NSError*)error{
    [[[UIAlertView alloc] initWithTitle:error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
}
-(void)httpRequestForService:(NSString *)service withParameters:(NSData *)parameters inCompletionBlock:(void(^)(BOOL , id ,NSError *)) completion{
    
    finishLoading = completion;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",_mainURl,service]];
    NSURLRequest *request = [self prepareRequestWithURL:url andParameters:parameters];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
    
}

-(NSURLRequest *)prepareRequestWithURL:(NSURL *)url andParameters:(NSData *) parameters
{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:url];
    if (parameters) {
        
        [request setHTTPMethod:@"POST"];
        
        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@",charset, @"0xKhTmLbOuNdArY"];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        [request setHTTPBody:parameters];
        
    }
    
    return request;
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    _urlData = [NSMutableData data];
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [_urlData appendData:data];
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:_urlData options:kNilOptions error:&error];
  //  NSLog(@"Json %@",json);
    finishLoading(json?YES:NO,json,error);
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    finishLoading(NO,nil,error);
    
}


@end
