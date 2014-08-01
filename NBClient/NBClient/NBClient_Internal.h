//
//  NBClient_Internal.h
//  NBClient
//
//  Created by Peng Wang on 7/21/14.
//  Copyright (c) 2014 NationBuilder. All rights reserved.
//

#import "NBClient.h"

@interface NBClient ()

@property (nonatomic, strong, readwrite) NSString *nationName;
@property (nonatomic, strong, readwrite) NSURLSession *urlSession;
@property (nonatomic, strong, readwrite) NSURLSessionConfiguration *sessionConfiguration;

@property (nonatomic, strong, readwrite) NBAuthenticator *authenticator;

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSURLComponents *baseURLComponents;
@property (nonatomic, strong) NSString *defaultErrorRecoverySuggestion;

- (void)commonInitWithNationName:(NSString *)nationName
                customURLSession:(NSURLSession *)urlSession
   customURLSessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration;

- (NSMutableURLRequest *)baseFetchRequestWithURL:(NSURL *)url;
- (NSURLSessionDataTask *)baseFetchTaskWithURLComponents:(NSURLComponents *)components
                                              resultsKey:(NSString *)resultsKey
                                          paginationInfo:(NBPaginationInfo *)paginationInfo
                                       completionHandler:(NBClientResourceListCompletionHandler)completionHandler;
- (NSURLSessionDataTask *)baseFetchTaskWithURLComponents:(NSURLComponents *)components
                                              resultsKey:(NSString *)resultsKey
                                       completionHandler:(NBClientResourceItemCompletionHandler)completionHandler;

- (NSMutableURLRequest *)baseSaveRequestWithURL:(NSURL *)url
                                     parameters:(NSDictionary *)parameters
                                          error:(NSError **)error;
- (NSURLSessionDataTask *)baseSaveTaskWithURLRequest:(NSURLRequest *)request
                                          resultsKey:(NSString *)resultsKey
                                   completionHandler:(NBClientResourceItemCompletionHandler)completionHandler;

- (NSMutableURLRequest *)baseDeleteRequestWithURL:(NSURL *)url;
- (NSURLSessionDataTask *)baseDeleteTaskWithURL:(NSURL *)url
                              completionHandler:(NBClientResourceItemCompletionHandler)completionHandler;

- (NSURLSessionDataTask *)startTask:(NSURLSessionDataTask *)task;

- (void (^)(NSData *, NSURLResponse *, NSError *))dataTaskCompletionHandlerForFetchResultsKey:(NSString *)resultsKey
                                                                            completionHandler:(void (^)(id results, NSDictionary *jsonObject, NSError *error))completionHandler;

- (NSError *)errorForResponse:(NSHTTPURLResponse *)response jsonData:(NSDictionary *)data;
- (NSError *)errorForJsonData:(NSDictionary *)data resultsKey:(NSString *)resultsKey;
- (void)logResponse:(NSHTTPURLResponse *)response data:(NSData *)data;

@end