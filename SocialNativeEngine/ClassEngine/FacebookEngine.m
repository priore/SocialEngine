//
//  FacebookEngine.m
//  SocialNativeEngine
//
//  Created by Danilo Priore on 28/03/13.
//  Copyright (c) 2013 Danilo Priore. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "FacebookEngine.h"

@implementation FacebookEngine

#pragma mark - Share

+ (void)shareURI:(NSString*)uri
            text:(NSString*)text
           image:(UIImage*)image
        complete:(void(^)())completeBlock
   failWithError:(void(^)(NSError *error))failBlock
{
    UIViewController *root = [[UIApplication sharedApplication] keyWindow].rootViewController;
    
    // iOS 6.x
    SLComposeViewController *controller = nil;
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    if(controller)
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [controller dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.....");
                    
                    if (failBlock) {
                        failBlock(nil);
                    }
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Posted.");
                    
                    if (completeBlock) {
                        completeBlock();
                    }
                }
                    break;
            }};
        
        [controller addImage:image];
        [controller setInitialText:text];
        [controller addURL:[NSURL URLWithString:uri]];
        [controller setCompletionHandler:completionHandler];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [root presentViewController:controller animated:YES completion:nil];
        });
    } else if (failBlock) {
        NSError *err = [NSError errorWithDomain:@"SocialEngine" code:-1001 userInfo:@{ NSLocalizedDescriptionKey: @"Facebook not available!"}];
        failBlock(err);
    }
}

#pragma mark - User

+ (void)getUserInfoWithAppID:(NSString*)appID complete:(void(^)(NSDictionary *userInfo, NSError *error))completeBlock
{
    NSDictionary *options = @{
                              @"ACFacebookAppIdKey" : appID,
                              @"ACFacebookPermissionsKey" : @[@"email"],
                              @"ACFacebookAudienceKey" : ACFacebookAudienceOnlyMe
                              };
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    [accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error){
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            if (accounts.count > 0) {
                ACAccount *socialAccount = [accounts objectAtIndex:0];
                SLRequest *infoRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://graph.facebook.com/me"] parameters:nil];
                [infoRequest setAccount:socialAccount];
                [infoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *err) {
                    NSMutableDictionary *dictInfo = nil;
                    if (urlResponse.statusCode == 200 && err == nil && responseData) {
                        NSArray *FBData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
                        dictInfo = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)FBData];
                        [dictInfo setValue:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", [dictInfo objectForKey:@"id"]] forKey:@"profile_image_url"];;
                    }
                    
                    completeBlock(dictInfo, err);
                }];
            } else {
                completeBlock(nil, [NSError errorWithDomain:NSStringFromClass([self class]) code:-2 userInfo:nil]);
            }
        } else {
            completeBlock(nil, error);
        }
    }];
}

#pragma mark - Application

+ (void)getAppAccessTokenWithAppId:(NSString*)appId cosumerSecret:(NSString*)secret complete:(void(^)(NSString *token, NSError *error))completeBlock
{
    // get application access token
    NSString *link = [NSString stringWithFormat:@"https://graph.facebook.com/oauth/access_token?client_id=%@&client_secret=%@&grant_type=client_credentials", appId, secret];
    NSURL *url = [NSURL URLWithString:link];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (completeBlock) {
            if (error) {
                completeBlock(nil, error);
            } else {
                NSError *error = nil;
                NSString *token = nil;
                NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if ([result containsString:@"access_token="])
                    token = [result stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
                else {
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    if (dict[@"error"]) {
                        NSInteger code = [[dict valueForKeyPath:@"error.code"] integerValue];
                        error = [NSError errorWithDomain:NSStringFromClass([self class]) code:code userInfo:dict];
                    } else {
                        error = [NSError errorWithDomain:NSStringFromClass([self class]) code:-1001 userInfo:dict];
                    }
                }
                completeBlock(token, error);
            }
        }
    }];
}

+ (void)getAppInfoFromToken:(NSString*)token complete:(void(^)(NSDictionary *appInfo, NSError *error))completeBlock
{
    // get application info
    NSString *link = [NSString stringWithFormat:@"https://graph.facebook.com/app?access_token=%@", [token stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:link];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (completeBlock) {
            if (error) {
                completeBlock(nil, error);
            } else {
                NSError *err = nil;
                NSDictionary *dict = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
                completeBlock(dict, err);
            }
        }
    }];
}

@end
