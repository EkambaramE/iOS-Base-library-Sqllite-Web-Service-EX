//
//  ServerHandler.h
//  Eller
//
//  Created by MuthuRaj on 21/08/15.
//  Copyright (c) 2015 Karya. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServerHandler;

@protocol ServerHandlerDelegate <NSObject>

- (void)serverHandler:(ServerHandler *)serverHandler andRequestStatus:(BOOL)status andReponseData:(id)responseData andErrorMessage:(NSString *)errorMessage;

@end

@interface ServerHandler : NSOperation

- (instancetype)initWithURL:(NSString *)urlString withRequestParameter:(NSString *)parameters andRequestType:(NSString *)requestType andTimeout:(int)timeout andPostDict:(NSDictionary*)postDict;

@property (nonatomic,weak) id<ServerHandlerDelegate>delegate;

@end
