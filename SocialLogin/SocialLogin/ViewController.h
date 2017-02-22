//
//  ViewController.h
//  SocialLogin
//
//  Created by vivek on 9/20/16.
//  Copyright © 2016 vivek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <linkedin-sdk/LISDK.h>
@interface ViewController : UIViewController

typedef void(^facebookLogin_completion_block)(id result,NSError *error,NSString *msg, int status);
typedef void(^twitterLogin_completion_block)(id result,NSError *error,NSString *msg, int status);
typedef void(^facebookDetail_completion_block)(id result,NSError *error, NSString *msg,int status);
typedef void(^google_completion_block) (id result,NSError *error, NSString *msg, int status);
typedef void(^linkedIn_completion_block) (id result, NSError *error, NSString *msg, int status);
typedef void(^instagram_completion_block) (id result, NSError *error, NSString *msg, int status);

@end

