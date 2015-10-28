**SocialEngine**
================

With SocialEngine you can simplify retrieving information for a iOS Facebook or Twitter account 
and simplify the sharing of a message, link or an image, all in quickly and easily.

SocialEngine consists of only two classes, and requires Twitter.framework, Social.framework 
and Accounts.framework, MessageUI.framework. SocialEngine is for iOS version 6.0 and higher.

## Features
* Retrieve user informations.
* Retrieve app informations.
* Share text, url and image.

## Requirements
* iOS 6.x and higher.
* XCode 6.0 or later
* Social.framework
* Twitter.framework
* Accounts.framework
* MessageUI.framework

Below a simple example on Objective-C :

```objective-c
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
    
    // facebook app infos
    [FacebookEngine getAppAccessTokenWithAppId:@"1234567890" cosumerSecret:@"1234567890" 
    								  complete:^(NSString *token, NSError *error) {
    								  
        [FacebookEngine getAppInfoFromToken:token complete:^(NSDictionary *appInfo, NSError *error) {
            
            NSLog(@"Facebook App infos : %@", appInfo);
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

    // email share
    UIImage *img = [UIImage imageNamed:@"my-image.jpg"];
    [[EmailEngine sharedInstance] shareURI:@"http://www.my-domain.com"  // you url (uri)
                                      text:@"My site"                	// you default message
                                     image:img                          // you image
                                  complete:^(MFMailComposeResult result) {
                                      NSLog(@"Email message sended.");
                                      // TODO: your code here when sharing is completed
                                  } failWithError:^(NSError *error) {
                                      NSLog(@"Email message not sended!");
                                      // TODO: your code here were not shared or canceled
                                  }];
```

**[Facebook Home Page](https://www.facebook.com/prioregroup)**  -  **[Twitter Home Page](https://www.twitter.com/DaniloPriore)**
