//
//  SocialLogin.h
//  SocialLogin
//
//  Created by aadil on 19/08/15.
//  Copyright (c) 2015 zaptechsolutions. All rights reserved.
//
// Library used :
// Twitter : https://github.com/nst/STTwitter
// Facebook : https://developers.facebook.com/docs/ios/
// Google + : https://developers.google.com/+/mobile/ios/getting-started
// Instagram : https://github.com/shyambhat/InstagramKit
// LinkedInn : 

// ***************************** For Facebook ***************************** //

// In App Delegate add Code to openURL Method :
//
//
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    return [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                          openURL:url
//                                                sourceApplication:sourceApplication
//                                                       annotation:annotation];
//}
//
// In App Delegate add code to Application DidBecome Active
//
//- (void)applicationDidBecomeActive:(UIApplication *)application {
//    // Activates Facebook App
//    [FBSDKAppEvents activateApp];
//    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//}
//
//
// In App Delegate return application didFinishLaunchingWithOptions
//
// - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//  return [[FBSDKApplicationDelegate sharedInstance] application:application
// didFinishLaunchingWithOptions:launchOptions];
// }
//
// In Info.plist ADD -----(URL Types -> ITEM 0 -> URL Schemes =-> ITEM0 = fb<APPID>)
//               ADD -----FacebookAppID = <APPID>
//


#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
//#import <FHSTwitterEngine.h>
#import <TwitterKit/TwitterKit.h>
#import <TwitterCore/TwitterCore.h>
#import <Twitter/Twitter.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GoogleOpenSource/GTLServicePlus.h>
#import <Social/Social.h>
#import <linkedin-sdk/LISDK.h>
//#import <InstagramKit.h>
//#import "InstaLoginVC.h"
typedef enum
{
    socialTypeFaceBook=1,
    socialTypeTwitter,
    socialTypeGoogle,
    socialTypeLinkedInn,
    socialTypeInstagram
    
}SocialType;
typedef void(^facebookLogin_completion_block)(id result,NSError *error,NSString *msg, int status);
typedef void(^twitterLogin_completion_block)(id result,NSError *error,NSString *msg, int status);
typedef void(^facebookDetail_completion_block)(id result,NSError *error, NSString *msg,int status);
typedef void(^google_completion_block) (id result,NSError *error, NSString *msg, int status);
typedef void(^linkedIn_completion_block) (id result, NSError *error, NSString *msg, int status);
typedef void(^instagram_completion_block) (id result, NSError *error, NSString *msg, int status);
@interface SocialLogin : NSObject <GPPSignInDelegate,UIWebViewDelegate>
@property (nonatomic,strong) NSMutableString *strFBAppId;
@property (nonatomic,strong) NSMutableString *strFBSecretKey;
@property (nonatomic,strong) NSMutableString *strGoogleId;
@property (nonatomic,strong) NSMutableString *strGoogleSecretKey;
@property (nonatomic,strong) NSMutableString *strTwitterId;
@property (nonatomic,strong) NSMutableString *strTwitterSecretKey;
@property (nonatomic,strong) NSMutableString *strTwitterClient;
@property (nonatomic,strong) NSMutableString *strInstagramId;
@property (nonatomic,strong) NSMutableString *strInstagramSecretKey;
@property (nonatomic,strong)  UIWebView *webView;
@property (nonatomic,assign) facebookDetail_completion_block objDetailBlock;
@property (nonatomic,assign) facebookLogin_completion_block objLoginBlock;
@property (nonatomic,retain) google_completion_block objGoogleBlock;
@property (nonatomic,retain) instagram_completion_block objInstagramBlock;
@property (nonatomic,assign) SocialType socialType;
@property (nonatomic,strong) UIViewController *viewController;
@property BOOL isStreaming;

-(instancetype)initWithSocialType:(SocialType)social;

// Facebook Methods
-(void)loginWithFacebookWithViewController: (UIViewController*)view :(facebookLogin_completion_block)completion;
-(void)logoutFacebook;
-(void)getFacebookDetails:(facebookDetail_completion_block) completion;
-(void)postFacebookStatus:(NSString *)msg ViewController:(UIViewController *)view;

// Google Methods
-(void)loginWithGoogle:(google_completion_block) completion;
-(void)logoutGoogle;
-(void)postToGooglePlus;
-(void)postToGooglePlusWithTitle:(NSString *)title andDescription:(NSString *)desc andImage: (NSData *)imageData andURL:(NSURL *)url;
// Twitter Methods
-(void)loginWithTwitter:(twitterLogin_completion_block)completion withViewController:(UIViewController *)view;
- (void)logTimeline:(twitterLogin_completion_block) completion;
- (void)postTweetWithMessage:(NSString *)msg withCompletionBlock:(twitterLogin_completion_block) completion;
- (void)toggleStreaming:(twitterLogin_completion_block) completion ;
- (void)postTweetWithMessage:(NSString *)msg andImage:(NSData *)imgData withCompletionBlock:(twitterLogin_completion_block) completion;

// LinkedInn Methods
-(void)loginWithLinkedInn:(linkedIn_completion_block) completion;
-(void) postLinkedInnWithMessage:(NSDictionary *)msg withCompletionBlock:(linkedIn_completion_block) completion;
-(void)logoutLinkedInn;

// Instagram Methods
-(void)loginWithInstagram:(linkedIn_completion_block)completion withViewController:(UIViewController *)view;
@end
