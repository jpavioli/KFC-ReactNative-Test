#import "AppDelegate.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTLinkingManager.h>
#import <React/RCTConvert.h>

// Import mParticle
#import <mParticle-Apple-SDK/mParticle.h>

// Add Add Tracking Dependencies
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

#if defined(FB_SONARKIT_ENABLED) && __has_include(<FlipperKit/FlipperClient.h>)
#import <FlipperKit/FlipperClient.h>
#import <FlipperKitLayoutPlugin/FlipperKitLayoutPlugin.h>
#import <FlipperKitUserDefaultsPlugin/FKUserDefaultsPlugin.h>
#import <FlipperKitNetworkPlugin/FlipperKitNetworkPlugin.h>
#import <SKIOSNetworkPlugin/SKIOSNetworkAdapter.h>
#import <FlipperKitReactPlugin/FlipperKitReactPlugin.h>

static void InitializeFlipper(UIApplication *application) {
  FlipperClient *client = [FlipperClient sharedClient];
  SKDescriptorMapper *layoutDescriptorMapper = [[SKDescriptorMapper alloc] initWithDefaults];
  [client addPlugin:[[FlipperKitLayoutPlugin alloc] initWithRootNode:application withDescriptorMapper:layoutDescriptorMapper]];
  [client addPlugin:[[FKUserDefaultsPlugin alloc] initWithSuiteName:nil]];
  [client addPlugin:[FlipperKitReactPlugin new]];
  [client addPlugin:[[FlipperKitNetworkPlugin alloc] initWithNetworkAdapter:[SKIOSNetworkAdapter new]]];
  [client start];
}
#endif

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if defined(FB_SONARKIT_ENABLED) && __has_include(<FlipperKit/FlipperClient.h>)
  InitializeFlipper(application);
#endif

  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"main" initialProperties:nil];
  id rootViewBackgroundColor = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RCTRootViewBackgroundColor"];
  if (rootViewBackgroundColor != nil) {
    rootView.backgroundColor = [RCTConvert UIColor:rootViewBackgroundColor];
  } else {
//    rootView.backgroundColor = [UIColor whiteColor];
  }

  // Build mParticle Config 
  MParticleOptions *options = [MParticleOptions optionsWithKey:@"us1-676663aaaca5634cb331a2ce9757bc24"
                                                        secret:@"f6-XjBN4rSmOfJAefKZmoz8EYAjE9FFldY7F4BEpNq59caNQtg9a6gPC4yFGfol3"];
  MPIdentityApiRequest *identityRequest = [MPIdentityApiRequest requestWithEmptyUser];
  options.identifyRequest = identityRequest;
  options.environment = MPEnvironmentDevelopment;
  options.logLevel = MPILogLevelVerbose;
  id identityCallback = ^(MPIdentityApiResult *_Nullable apiResult, NSError *_Nullable error){
    if (apiResult){
      //ADD ANY SUCCESSFUL IMPLEMENTATION LOGIC
    } else {
      NSLog(@"%@",error.userInfo);
      switch (error.code) {
          case MPIdentityErrorResponseCodeClientNoConnection:
          case MPIdentityErrorResponseCodeClientSideTimeout:
              //retry the IDSync request
              break;
          case MPIdentityErrorResponseCodeRequestInProgress:
          case MPIdentityErrorResponseCodeRetry:
              //inspect your implementation if this occurs frequency
              //otherwise retry the IDSync request
              break;
          default:
              // inspect error.userInfo to determine why the request failed
              // this typically means an implementation issue
              break;
      }
    }
  };
  options.onIdentifyComplete = identityCallback;

  // Initialize mParticle with Config
  [[MParticle sharedInstance] startWithOptions:options];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];

  [super application:application didFinishLaunchingWithOptions:launchOptions];

  return YES;
 }

- (NSArray<id<RCTBridgeModule>> *)extraModulesForBridge:(RCTBridge *)bridge
{
  // If you'd like to export some custom RCTBridgeModules, add them here!
  return @[];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
 #ifdef DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
 #else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
 #endif
}

// Linking API
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  return [RCTLinkingManager application:application openURL:url options:options];
}

// Universal Links
- (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
  return [RCTLinkingManager application:application
                   continueUserActivity:userActivity
                     restorationHandler:restorationHandler];
}

@end
