//
//  EmailEngine.h
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

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

typedef void(^EmailEngineCompleteWithResult)(MFMailComposeResult result);
typedef void(^EmailEngineFailWithError)(NSError *error);

@interface EmailEngine : NSObject <MFMailComposeViewControllerDelegate>

+ (EmailEngine*)sharedInstance;

+ (BOOL)isAvailable;

- (void)shareTo:(NSArray<NSString*>*)to
        subject:(NSString*)subject
           text:(NSString*)text
          image:(UIImage*)image
       complete:(EmailEngineCompleteWithResult)completeBlock
  failWithError:(EmailEngineFailWithError)failBlock;

@end
