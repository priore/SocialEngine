//
//  ViewController.m
//  SocialNativeEngine
//
//  Created by danilo on 28/08/13.
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

#import "ViewController.h"
#import "SocialEngine.h"

@implementation ViewController

- (IBAction)didFacebookButtonSelected:(id)sender
{
    #warning write here your Facebook AppID
    [FacebookEngine getUserInfoWithAppID:@"1234567890" complete:^(NSDictionary *userInfo, NSError *error) {
        
        if (userInfo == nil) {
            NSLog(@"Invalid Facebook AppID!");
        } else {
            NSLog(@"Facebook User infos : %@", userInfo);
        }
        
        /*
        // load profile image
        NSString *image_url = [userInfo objectForKey:@"profile_image_url"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:image_url]];
        UIImage *profileImage = [UIImage imageWithData:data];
        */
        
        UIImage *img = [UIImage imageNamed:@"egyptoname.jpg"];
        [FacebookEngine shareURI:@"http://www.prioregroup.com"  // you url (uri)
                            text:@"My site"                     // you default message
                           image:img                            // you image
                        complete:^{
                            NSLog(@"Facebook message shared.");
                            //
                            // TODO: your code here when sharing is completed
                            //
                        } failWithError:^(NSError *error) {
                            NSLog(@"Facebook message not shared!");
                            //
                            // TODO: your code here were not shared or canceled
                            //
                        }];
    }];
}

- (IBAction)didTwitterButtonSelected:(id)sender
{
    [TwitterEngine getUserInfoWithComplete:^(NSDictionary *userInfo, NSError *error) {
        
        NSLog(@"Twitter User infos : %@", userInfo);

        /*
        // load profile image
        NSString *image_url = [userInfo objectForKey:@"profile_image_url"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:image_url]];
        UIImage *profileImage = [UIImage imageWithData:data];
        */
        
        UIImage *img = [UIImage imageNamed:@"egyptoname.jpg"];
        [TwitterEngine shareURI:@"http://www.prioregroup.com"   // you url (uri)
                           text:@"@danilopriore "               // you default message
                          image:img                             // you image
                       complete:^{
                           NSLog(@"Twitter message shared.");
                           //
                           // TODO: your code here when sharing is completed
                           //
                       } failWithError:^(NSError *error) {
                           NSLog(@"Twitter message not shared!");
                           //
                           // TODO: your code here were not shared or canceled
                           //
                       }];
    }];
}

@end
