//
//  TwitterEngine.m
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
#define kTwitterErrorMsg                @"Please set your Twitter account in Settings."
#define kTwitterAccessDeniedMsg         @"Twitter Access denied."

#define TWITTER_USERINFO_API @"https://api.twitter.com/1.1/users/show.json"

#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "TwitterEngine.h"

@implementation TwitterEngine

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
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
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
        NSError *err = [NSError errorWithDomain:@"SocialEngine" code:-1001 userInfo:@{ NSLocalizedDescriptionKey: @"Twitter not available!"}];
        failBlock(err);
    }
}

#pragma mark - User

+ (void)getUserInfoWithComplete:(void(^)(NSDictionary *userInfo, NSError *error))completeBlock
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            if (accounts.count > 0) {
                ACAccount *socialAccount = [accounts lastObject];
                        SLRequest *infoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:TWITTER_USERINFO_API] parameters:[NSDictionary dictionaryWithObject:socialAccount.username forKey:@"screen_name"]];
                        [infoRequest setAccount:socialAccount];
                        [infoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *err) {
                            if (err) {
                                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
                                completeBlock(nil, [NSError errorWithDomain:NSStringFromClass([self class]) code:[[dict valueForKeyPath:@"errors.code.@firstObject"] integerValue] userInfo:@{NSLocalizedDescriptionKey: dict}]);
                            } else {
                                NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
                                NSDictionary *dict = [NSDictionary dictionaryWithDictionary:(NSDictionary*)TWData];
                                completeBlock(dict, nil);
                            }
                        }];
            } else {
                NSString *message = kTwitterErrorMsg;
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                if(error.code == ACErrorPermissionDenied || error.code == ACErrorAccessDeniedByProtectionPolicy) {
                    [details setValue:kTwitterAccessDeniedMsg forKey:NSLocalizedDescriptionKey];
                }
                
                completeBlock(nil, [NSError errorWithDomain:NSStringFromClass([self class]) code:error.code userInfo:@{NSLocalizedDescriptionKey: message}]);
            }
            
        } else {
            completeBlock(nil, [NSError errorWithDomain:NSStringFromClass([self class]) code:-3 userInfo:nil]);
        }
    }];
}

@end
