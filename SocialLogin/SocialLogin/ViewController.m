//
//  ViewController.m
//  SocialLogin
//
//  Created by vivek on 9/20/16.
//  Copyright © 2016 vivek. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)loginWithLinkedInn:(linkedIn_completion_block)completion
{
    @try {
        
        [LISDKSessionManager createSessionWithAuth:[NSArray arrayWithObjects:LISDK_BASIC_PROFILE_PERMISSION, LISDK_EMAILADDRESS_PERMISSION, LISDK_W_SHARE_PERMISSION, nil]
                                             state:@"some state"
                            showGoToAppStoreDialog:YES
                                      successBlock:^(NSString *returnState) {
                                          
                                          
                                          [[LISDKAPIHelper sharedInstance] getRequest:@"https://api.linkedin.com/v1/people/~:(id,firstName,lastName,email-address)"
                                                                              success:^(LISDKAPIResponse *response)
                                           {
                                               NSData* data = [response.data dataUsingEncoding:NSUTF8StringEncoding];
                                               NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                               
                                               
                                               if(completion)
                                               {
                                                   
                                                   completion(dictResponse,nil,@"LinkedIn login success",1);
                                               }
                                           } error:^(LISDKAPIError *apiError)
                                           {
                                               if(completion)
                                               {
                                                   completion(nil,nil,@"Unable to retrive linkedin basic information",-1);
                                               }
                                           }];
                                          
                                          
                                          
                                      }
                                        errorBlock:^(NSError *error) {
                                            if(completion)
                                            {
                                                completion(nil,error,[error description],-1);
                                            }
                                        }
         ];
        
        return;
    }
    @catch (NSException *exception) {
        
        if(completion)
        {
            completion(nil,nil,@"Exception error",-1);
        }
        
    }
    @finally {
    }
}
-(void)loginWithFacebook:(facebookDetail_completion_block)completion
{
    
//    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
//    [login logOut];
//    [login
//     logInWithReadPermissions: @[@"public_profile",@"email"]
//     fromViewController:topController
//     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//         if (error)
//         {
//             NSLog(@"Process error");
//             
//             
//         } else if (result.isCancelled) {
//             NSLog(@"Cancelled");
//         } else {
//             NSLog(@"Logged in");
//             if ([FBSDKAccessToken currentAccessToken]) {
//                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id,first_name,last_name,email,name"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                     
//                     
//                     if (!error) {
//                         
//                         
//                     }
//                 }];
//             }
//         }
//     }];
//
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
