#import "cocos2d.h"
#import <CCActionInterval.h>
#import "ccConfig.h"
#import <iAd/iAd.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>



@interface MainScene : CCNode <CCPhysicsCollisionDelegate, ADBannerViewDelegate, CCBAnimationManagerDelegate>{
}
   
@property(nonatomic,retain)IBOutlet ADBannerView *adView;
@property(nonatomic) BOOL *musicPlaying;

@end
