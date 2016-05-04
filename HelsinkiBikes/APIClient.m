//
//  HSLCommunication.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 31/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "APIClient.h"
#import "RKXMLReaderSerialization.h"

@implementation APIClient

@synthesize apiBaseUrl;

-(id)init{
    self = [super init];
    
    if (self) {
        /* Production
        RKLogConfigureByName("RestKit", RKLogLevelCritical);
        RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelCritical);
        RKLogConfigureByName("RestKit/Network", RKLogLevelCritical);
         
         */
        
        RKLogConfigureByName("RestKit", RKLogLevelCritical);
        RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelCritical);
        RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
        
    }
    
    return self;
}

#pragma mark - helpers
+(NSString *)commaSepStringFromArray:(NSArray *)array withSeparator:(NSString *)separator{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    if (array != nil && ![[array firstObject] isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    for (NSString *line in array) {
        if (![tempArray containsObject:line]) {
            [tempArray addObject:line];
        }
    }
    
    separator = separator != nil ? separator : @",";
    
    if (tempArray.count > 0) {
        return [[tempArray valueForKey:@"description"] componentsJoinedByString:separator];
    }else{
        return @"";
    }
}

#pragma mark - Rest api helpers
+(NSString *)formatRestQueryFilterForDictionary:(NSDictionary *)paramsDictionary{
    if (paramsDictionary == nil)
        return nil;
    
    NSMutableArray *paramsArray = [@[] mutableCopy];
    for (NSString *key in paramsDictionary.allKeys) {
        [paramsArray addObject:[NSString stringWithFormat:@"%@=%@",key, paramsDictionary[key]]];
    }
    
    return [self commaSepStringFromArray:paramsArray withSeparator:@"&"];
}

#pragma mark - Generic fetch method
-(void)doApiFetchWithParams:(NSDictionary *)params responseDiscriptor:(RKResponseDescriptor *)responseDescriptor isJsonResponse:(BOOL)isJson andCompletionBlock:(ActionBlock)completionBlock{
    NSURL *baseURL = [NSURL URLWithString:apiBaseUrl];
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:isJson ? RKMIMETypeJSON : RKMIMETypeXML];
    [RKMIMETypeSerialization registerClass:isJson ? [RKNSJSONSerialization class] : [RKXMLReaderSerialization class] forMIMEType:isJson ? @"text/plain" : @"text/xml"];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    NSString *apiURL = apiBaseUrl;
    //Construct params query string
    NSString *parameters = [APIClient formatRestQueryFilterForDictionary:params];
    if (parameters) {
        if ([parameters respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
            parameters = [parameters stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }else{
            parameters = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        apiURL = [NSString stringWithFormat:@"%@?%@",apiBaseUrl,parameters];
    }
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        completionBlock(mappingResult.array, nil);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
    
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
}

-(void)doJsonApiFetchWithParams:(NSDictionary *)params responseDescriptor:(RKResponseDescriptor *)responseDescriptor andCompletionBlock:(ActionBlock)completionBlock{
    
    [self doApiFetchWithParams:params responseDiscriptor:responseDescriptor isJsonResponse:YES andCompletionBlock:completionBlock];
}

-(void)doXmlApiFetchWithParams:(NSDictionary *)params responseDescriptor:(RKResponseDescriptor *)responseDescriptor andCompletionBlock:(ActionBlock)completionBlock{
    
    [self doApiFetchWithParams:params responseDiscriptor:responseDescriptor isJsonResponse:NO andCompletionBlock:completionBlock];
}

-(void)doApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping mapToClass:(Class)mapToClass mapKeyPath:(NSString *)keyPath isJsonResponse:(BOOL)isJson andCompletionBlock:(ActionBlock)completionBlock{
    RKObjectMapping *responseMApping = [RKObjectMapping mappingForClass:mapToClass];
    [responseMApping addAttributeMappingsFromDictionary:mapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMApping method:RKRequestMethodGET pathPattern:nil keyPath:keyPath statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [self doApiFetchWithParams:params responseDiscriptor:responseDescriptor isJsonResponse:isJson andCompletionBlock:completionBlock];
}

-(void)doJsonApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping mapToClass:(Class)mapToClass mapKeyPath:(NSString *)keyPath andCompletionBlock:(ActionBlock)completionBlock{
    
    [self doApiFetchWithParams:params mappingDictionary:mapping mapToClass:mapToClass mapKeyPath:keyPath isJsonResponse:YES andCompletionBlock:completionBlock];
}

-(void)doXmlApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping mapToClass:(Class)mapToClass mapKeyPath:(NSString *)keyPath andCompletionBlock:(ActionBlock)completionBlock{
    [self doApiFetchWithParams:params mappingDictionary:mapping mapToClass:mapToClass mapKeyPath:keyPath isJsonResponse:NO andCompletionBlock:completionBlock];
}

-(void)doApiFetchWithOutMappingWithParams:(NSDictionary *)params andCompletionBlock:(ActionBlock)completionBlock{
    
    //Construct params query string
    NSString *parameters = [APIClient formatRestQueryFilterForDictionary:params];
    if ([parameters respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        parameters = [parameters stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }else{
        parameters = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString *apiURL = [NSString stringWithFormat:@"%@?%@",apiBaseUrl,parameters];
    
    NSURL *url = [NSURL URLWithString:apiURL];
    //    NSLog(@"%@", urlAsString);
    
    
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(data, error);
        });
    }];
}

@end