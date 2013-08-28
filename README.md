**SocialEngine**
================

With SocialEngine you can simplify retrieving information for a iOS Facebook or Twitter account and simplify the sharing of a message, link or an image, all in quickly and easily.

SocialEngine consists of only two classes, and requires Twitter.framework, Social.framework and Accounts.framework. SocialEngine is for iOS version 5.0 and higher.

## Features
* Retrieve user informations.
* Share text, url and image.

## Requirements
* iOS 5.x and higher.
* XCode 4.5 or later
* Social.framework (iOS6)
* Twitter.framework (iOS5)
* Accounts.framework (both)

Below a simple example on Objective-C :

	#import "SocialEngine.h"

	// facebook user infos
	[FacebookEngine getUserInfoWithAppID:@"1234567890" complete:^(NSDictionary *userInfo, NSError *error) {
        
        if (userInfo == nil) {
            NSLog(@"Invalid Facebook AppID!");
        } else {
            NSLog(@"Facebook User infos : %@", userInfo);
            
	        // load profile image
    	    NSString *image_url = [userInfo objectForKey:@"profile_image_url"];
        	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:image_url]];
        	UIImage *profileImage = [UIImage imageWithData:data];
        }
    }];
        
        
    // facebook share
    UIImage *img = [UIImage imageNamed:@"my-image.jpg"];
    [FacebookEngine shareURI:@"http://www.my-domain.com"  	// you url (uri)
                        text:@"My site"                     // you default message
                        image:img                           // you image
                    complete:^{
                        NSLog(@"Facebook message shared.");
                        // TODO: your code here when sharing is completed
                    } failWithError:^(NSError *error) {
                        NSLog(@"Facebook message not shared!");
                        // TODO: your code here were not shared or canceled
                    }];
    }];
    
    // twitter user infos
    [TwitterEngine getUserInfoWithComplete:^(NSDictionary *userInfo, NSError *error) {
        
        if (userInfo == nil) {
            NSLog(@"Invalid Twitter account!");
        } else {
            NSLog(@"Twitter User infos : %@", userInfo);
            
	        // load profile image
    	    NSString *image_url = [userInfo objectForKey:@"profile_image_url"];
        	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:image_url]];
        	UIImage *profileImage = [UIImage imageWithData:data];
        }
    }];
        
    // twitter share
    UIImage *img = [UIImage imageNamed:@"my-image.jpg"];
    [TwitterEngine shareURI:@"http://www.my-domain.com"   	// you url (uri)
                        text:@"@my-screename "              // you default message
                        image:img                           // you image
                    complete:^{
                        NSLog(@"Twitter message shared.");
                        // TODO: your code here when sharing is completed
                    } failWithError:^(NSError *error) {
                        NSLog(@"Twitter message not shared!");
                        // TODO: your code here were not shared or canceled
                    }];


**[Facebook Home Page](https://www.facebook.com/prioregroup)**