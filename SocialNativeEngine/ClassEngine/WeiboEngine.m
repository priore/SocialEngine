//
//  TwitterEngine.m
//  SocialNativeEngine
//
//  Created by Danilo Priore on 09/11/15.
//  Copyright (c) 2015 Danilo Priore. All rights reserved.
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

#import <Social/Social.h>
#import "WeiboEngine.h"

@implementation WeiboEngine

#pragma mark - Share

+ (void)shareURI:(NSString*)uri
            text:(NSString*)text
           image:(UIImage*)image
        complete:(void(^)())completeBlock
   failWithError:(void(^)(NSError *error))failBlock
{
    SLComposeViewController *controller = nil;
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo])
        controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
    
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
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            UIViewController *root = [[UIApplication sharedApplication] keyWindow].rootViewController;
            [root presentViewController:controller animated:YES completion:nil];
        }];
    } else if (failBlock) {
        NSError *err = [NSError errorWithDomain:@"SocialEngine" code:-1001 userInfo:@{ NSLocalizedDescriptionKey: @"SinaWeibo not available!"}];
        failBlock(err);
    }
}

@end
