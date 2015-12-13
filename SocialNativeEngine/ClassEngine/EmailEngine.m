//
//  EmailEngine.m
//  SocialNativeEngine
//
//  Created by Danilo Priore on 11/07/13.
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

#ifdef DEBUG
#define EMLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define EMLog( s, ... )
#endif

#import "EmailEngine.h"

@interface EmailEngine()

@property (nonatomic, strong) EmailEngineCompleteWithResult complete_block;
@property (nonatomic, strong) EmailEngineFailWithError fail_block;

@end

@implementation EmailEngine

+ (EmailEngine*)sharedInstance
{
    static dispatch_once_t onceEmailEngine;
    static id instanceEmailEngine;
    dispatch_once(&onceEmailEngine, ^{
        instanceEmailEngine = self.new;
    });
    return instanceEmailEngine;
}

+ (BOOL)isAvailable
{
    return [MFMailComposeViewController canSendMail];
}

- (void)shareTo:(NSArray<NSString*>*)to subject:(NSString*)subject text:(NSString*)text image:(UIImage*)image complete:(EmailEngineCompleteWithResult)completeBlock failWithError:(EmailEngineFailWithError)failBlock
{
    if ([MFMailComposeViewController canSendMail]) {
        
        self.complete_block = [completeBlock copy];
        self.fail_block = [failBlock copy];
        
        // compose email message
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        
        if (image) {
            [mailViewController addAttachmentData:UIImageJPEGRepresentation(image, 0.7)
                                         mimeType:@"image/jpeg"
                                         fileName:@"image.jpeg"];
        }
        
        [mailViewController setToRecipients:to];
        [mailViewController setSubject:subject];
        [mailViewController setMessageBody:text isHTML:[text containsString:@"<html>"]];
        [mailViewController setMailComposeDelegate:self];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            UIViewController *root = [[UIApplication sharedApplication] keyWindow].rootViewController;
            [root presentViewController:mailViewController animated:YES completion:nil];
        }];
        
    } else {
        EMLog(@"Cancelled.....");
        
        if (completeBlock)
            completeBlock(MFMailComposeResultCancelled);
    }
}

#pragma mark - MFMailComposeViewController Delegates

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (error && self.fail_block)
        self.fail_block(error);
    else if (!error && self.complete_block)
        self.complete_block(result);
}

@end
