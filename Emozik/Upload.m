

//
//  Upload.m
//  Emozik
//
//  Created by Thanh Hai Tran on 1/11/17.
//  Copyright © 2017 Thanh Hai Tran. All rights reserved.
//

#import "Upload.h"

static Upload * shareInst = nil;

@interface Upload ()
{
    NSMutableData * responseData;
}

@end

@implementation Upload

@synthesize uploadCompletion, percentComplete;

+ (Upload*)shareInstance
{
    if(!shareInst)
    {
        shareInst = [Upload new];
    }
    
    return shareInst;
}

- (NSString *)boundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [self uuidString]];
}

- (Upload*)didStartUpload:(NSDictionary*)info andCompletion:(UploadCompletion)_completion
{
    self.uploadCompletion = nil;
    
    self.uploadCompletion = _completion;
    
    responseData = nil;
    
    responseData = [NSMutableData new];

    percentComplete = 0;
    
    NSURL *url = [NSURL URLWithString:info[@"url"]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [self boundaryString];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    [info[@"param"] enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"profilepic", [NSString stringWithFormat:@"%@.mp4", info[@"name"]]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", @"audio/mpeg"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:info[@"data"]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSURLConnection * urlconnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(urlconnection == nil)
    {
        self.uploadCompletion(3, self, @{@"error":@"Connection Failed"});
    }
    else
    {
        [urlconnection start];
        
        self.uploadCompletion(0, self, @{@"error":@"Connection Started"});
    }
    
    return  self;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    float progress = [[NSNumber numberWithInteger:totalBytesWritten] floatValue];
    
    float total = [[NSNumber numberWithInteger: totalBytesExpectedToWrite] floatValue];
    
    percentComplete = progress/total;
    
    self.uploadCompletion(1, self, @{@"percent":@(percentComplete)});
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@", response);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.uploadCompletion(3, self, @{@"error":@"failed"});
    
    NSLog(@"____%@",[error description]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    id dict = [response objectFromJSONString];
    
    NSLog(@"____%@",response);
    
    self.uploadCompletion(![dict isKindOfClass:[NSDictionary class]] ? 3 : [dict[@"ERR_CODE"] boolValue] ? 3 : 2, self, @{@"percent":@(percentComplete),@"infor": [dict isKindOfClass:[NSDictionary class]] ? dict : @"failed"});
}

@end
