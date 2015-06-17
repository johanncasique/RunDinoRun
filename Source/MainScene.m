#import "MainScene.h"
#import "cocos2d.h"
#import <CCActionInterval.h>
#import "ccConfig.h"
#import "../Obstacle.h"
#import <CCDirector.h>
#import "CCBReader.h"
#import "CCTextureCache.h"
#import "GameOverLayer.h"
#import "AppDelegate.h"
#import "PauseLayer.h"

static const CGFloat scrollSpeed = 280.0f;
CGFloat firstObstaclePosition;
static const CGFloat distanceBetweenObstacles = 220.f;
BOOL playing = NO;
BOOL paused = false;
CGSize winSize;
NSInteger obstaclesMaxQt;
NSString *obstacles_cbs[3]  = {@"Obstacle", @"obstacle_triangle", @"enemy"};
NSString *weapons_cbs[1]    = {@"weapon_fireball"};
BOOL jumping = false;
BOOL musicPlaying = YES;

@implementation MainScene {
  
    CCPhysicsNode *_physicsNode;
    CCSprite *_hero;
    CCSprite *_robot;
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_background;
    CCNode *_startButton;
    CCNode *_pause_game_btn;
    CCNode *_btn_fire_fireball;
    CCNode *screen_pause;
    CCNode *screen_game_over;
    CCNode *_no_ads_button;
    CCNode *_gameTitle;
    CCNode *_soundButton;
    CCNode *scoreLabel;

    
    
    // Menus
    //CCLayoutBox *menu_box;
    CCLayoutBox *pause_menu;
    
    //CCNode *_goal;
    NSArray *_grounds;
    NSTimeInterval _sinceTouch;
    //UISwipeGestureRecognizer *swipeUp;
    NSMutableArray *_obstacles;
    NSMutableArray *_fireballs;
    NSMutableArray *_playing_menu_items;
    NSInteger hero_y_ini_pos;
    NSInteger _points;
    CCLabelTTF *_score_label;
    
    
    
}

-(void)addExplosion:(CGPoint)position
{
    CCParticleExplosion* particleExplosion;
    particleExplosion = [[CCParticleExplosion alloc] initWithTotalParticles:4000];
    particleExplosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"ccbParticleFire.png"];
    particleExplosion.life = 0.0f;
    particleExplosion.lifeVar = 0.7f;
    particleExplosion.startSize = 5;
    particleExplosion.startSizeVar = 3;
    particleExplosion.endSize = 2;
    particleExplosion.endSizeVar = 0;
    particleExplosion.angle = 0;
    particleExplosion.angleVar = 360;
    particleExplosion.speed = 0;
    particleExplosion.speedVar = 200;
    particleExplosion.blendAdditive = YES;
    
    //CGPoint g = CGPointMake(1.15, 1.f);
    //particleExplosion.gravity = g;
    
    particleExplosion.startColor = [CCColor colorWithRed:254 green:27 blue:36];
    particleExplosion.endColor = [CCColor colorWithRed:1 green:0 blue:0];

    particleExplosion.startColorVar = [CCColor colorWithRed:86 green:39 blue:116];
    particleExplosion.endColorVar = [CCColor colorWithRed:1 green:0 blue:0];
    
    CGPoint positionWorldPosition = [_physicsNode convertToWorldSpace:position];
    // get the screen position of the ground
    CGPoint positionScreenPosition = [self convertToNodeSpace:positionWorldPosition];
    particleExplosion.position = positionScreenPosition;
    
    particleExplosion.posVar = ccp(10.f, 65.f);
    
    [self addChild:particleExplosion];
    [particleExplosion resetSystem];
//    CCLOG(@"%.2f %.2f", particleExplosion.position.x, particleExplosion.position.y);
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level
{
    //CCLOG(@"Game over");
    [self gameOver];
    
   
    return TRUE;
    
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goal:(CCNode *)goal
{
    _points++;
   _score_label.string = [NSString stringWithFormat:@"%i", (int)_points];
    
    [self fadeText:_score_label duration:1.5 curve:0 x:0 y:0 alpha:255.0];

    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero robot:(CCSprite *)robot
{
    if(robot.visible == YES)
    {
    [self gameOver];
        [robot.animationManager setPaused:YES];
    }
    return TRUE;
        
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair fireball:(CCSprite *)fireball robot:(CCSprite *)robot
{
    if(robot.visible == YES)
    {
        _points++;
        _score_label.string = [NSString stringWithFormat:@"%d", (int)_points];
        robot.anchorPoint = ccp(0.5f, 0.5f);
        [self addExplosion:robot.position];
        robot.visible = NO;
        [fireball removeFromParent];
        
        
    }
    return TRUE;
}

- (void)didLoadFromCCB
{
    _grounds = @[_ground1, _ground2];
    
    self.userInteractionEnabled = TRUE;
  
    
    _physicsNode.collisionDelegate = self;
    _hero.physicsBody.collisionType = @"hero";
    
    winSize = [CCDirector sharedDirector].viewSize;
    
    _points = 0;
    
    screen_game_over = (CCNode *) [CCBReader load:@"screen_gameOver"];
    
    
   

   }



- (void)fadeText:(CCLabelTTF *)progress duration:(NSTimeInterval)duration
           curve:(int)curve x:(CGFloat)x y:(CGFloat)y alpha:(float)alpha
{
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // The transform matrix
    progress.opacity = alpha;
    //[progress setOpacity:alpha];
    // Commit the changes
    [UIView commitAnimations];
}



-(void) gameOver
{
    if(playing)
    {
        playing = NO;
    
        [_background.animationManager setPaused:true];
       
//        screen_game_over.anchorPoint = ccp(0.5f, 0.5f);
        screen_game_over.position = ccp(winSize.width , winSize.height );
        screen_game_over.name = @"screen_game_over";
    
        [self addChild:screen_game_over];
        
        [self removeChild:_btn_fire_fireball];
    
        
        id bounce = [CCActionJumpBy actionWithDuration:0.17f position:ccp(0.f, (winSize.height*-0.1)* -1.f) height:-80 jumps:1];
        id seq = [CCActionSequence actions:bounce, nil];
        [screen_game_over runAction:seq];
        _pause_game_btn.visible = NO;
        [_hero.animationManager setPaused:YES];
        [_robot.animationManager setPaused:YES];
        [_hero stopAllActions];
        [self setUserInteractionEnabled:false];
        [self removeChild:scoreLabel];
        [self removeChild:_soundButton];
        
        
        
        [_score_label removeFromParent];
    
        _score_label.string = [NSString stringWithFormat:@"%i", (int)_points];
        
        [self fadeText:_score_label duration:1.5 curve:0 x:0 y:0 alpha:255.0];
                
        
        NSDictionary *userInfo = @{
                                   @"score": [NSString stringWithFormat:@"%d", (int)_points],
                                   };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"set_score_to_label" object:self userInfo:userInfo];
       
      
      
        

        [[OALSimpleAudio sharedInstance] stopBg];
    
    }
}

-(id) init
{
    // always call "super" init
    // Apple recommends to re-assign "self" with the "super" return value
    if( (self=[super init] )) {
        [CCBReader load:weapons_cbs[0]];
        [CCBReader load:obstacles_cbs[0]];
        [CCBReader load:obstacles_cbs[1]];
        [CCBReader load:obstacles_cbs[3]];
        [CCBReader load:@"Pause"];
      
        
        _obstacles = [NSMutableArray array];
        _fireballs = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:@"resume_game_from_pause" object:nil];
      
        
        // On iOS 6 ADBannerView introduces a new initializer, use it when available.
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            _adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
            
        } else {
            _adView = [[ADBannerView alloc] init];
        }
        _adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
        _adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        [[[CCDirector sharedDirector]view]addSubview:_adView];
        [_adView setBackgroundColor:[UIColor clearColor]];
        [[[CCDirector sharedDirector]view]addSubview:_adView];
        _adView.delegate = self;
        
        [[OALSimpleAudio sharedInstance] preloadBg:@"bounce_bg_music.mp3"];
    }
    [self layoutAnimated:YES];
    return self;
}

- (void)layoutAnimated:(BOOL)animated
{
    // As of iOS 6.0, the banner will automatically resize itself based on its width.
    // To support iOS 5.0 however, we continue to set the currentContentSizeIdentifier appropriately.
    CGRect contentFrame = [CCDirector sharedDirector].view.bounds;
    if (contentFrame.size.width < contentFrame.size.height) {
        _adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    } else {
        _adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }
    
    CGRect bannerFrame = _adView.frame;
    if (_adView.bannerLoaded) {
        contentFrame.size.height -= _adView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        _adView.frame = bannerFrame;
    }];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [self layoutAnimated:YES];
     NSLog(@"iAdBanner loaded");
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self layoutAnimated:YES];
     NSLog(@"iAdBanner failed");
}


-(void)jumpRunner
{
    [_hero.animationManager runAnimationsForSequenceNamed:@"jumping"];
    id jumpUp = [CCActionJumpBy actionWithDuration:0.2f position:ccp(0,120) height:20 jumps:1];
    id jumpDown = [CCActionJumpBy actionWithDuration:0.3f position:ccp(0,-120) height:20 jumps:1];
    id seq = [CCActionSequence actions:jumpUp, jumpDown, nil];
    [_hero runAction:seq];
}


- (void)launch_fb_Button_Tapped:(id)sender
{
    [self spawnNewFireball];
}

-(void)soundBtn
{
    [[OALSimpleAudio sharedInstance] stopBg];
}

- (void)play //_startButton selector

{
    
    _btn_fire_fireball.visible = TRUE;
   
    playing = YES;
    [_hero.animationManager setPaused:NO];
    hero_y_ini_pos = [[NSString stringWithFormat: @"%.2f", _hero.position.y] integerValue];
    firstObstaclePosition = (_hero.position.x - _hero.contentSize.width) + winSize.width;
    obstaclesMaxQt = ( winSize.width / (int) distanceBetweenObstacles ) * 2;
    screen_pause = (CCNode *) [CCBReader load:@"Pause"];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    _pause_game_btn.visible = YES;
    [self removeChild:_startButton];
    [self removeChild:_no_ads_button];
    _soundButton.visible = YES;
    [self removeChild:_gameTitle];
    scoreLabel.visible = YES;
    
    
   [[OALSimpleAudio sharedInstance] playBgWithLoop:YES];
    
}





//-(void)pause_game
//{
//
//    
//    
//
//    
//    [self setUserInteractionEnabled:false];
//    [_btn_fire_fireball stopAllActions];
//    _score_label.visible = NO;
//    _btn_fire_fireball.visible = NO;
//    [[CCDirector sharedDirector] pause];
//    
//    screen_pause.anchorPoint = ccp(0.5f, 0.5f);
//    screen_pause.position = ccp(winSize.width/2, winSize.height/2);
//    screen_pause.name = @"pause_menu";
//    [self addChild:screen_pause];
//    
////    [self removeChildByName:@"menu_box"];
//    _pause_game_btn.visible = NO;
//    
//    [[OALSimpleAudio sharedInstance] setBgVolume:0.3f];
//  
//  
//   
//}







//-(void)resume:(NSNotification *) resumeNotification{
//    
//        [self removeChildByName:@"pause_menu"];
//        [self setup_menu];
//    [self setUserInteractionEnabled:true];
//    
//
//    _score_label.visible = YES;
//    _btn_fire_fireball.visible = YES;
//    
//        _hero.physicsBody.affectedByGravity = true;
//        [_hero.animationManager setPaused:false];
//        _hero.physicsBody.affectedByGravity = true;
//        [_background.animationManager setPaused:false];
//    
////        NSInteger hero_actual_y = [[NSString stringWithFormat: @"%.2f", _hero.position.y] integerValue];
////        if((hero_actual_y - hero_y_ini_pos) > 1)
////        {
////            id jumping = [CCActionJumpBy actionWithDuration:0.25f position:ccp(0,(_hero.position.y - hero_y_ini_pos)*-1) height:20 jumps:1];
////            id seq = [CCActionSequence actions:jumping, nil];
////            [_hero runAction:seq];
////        }
//    
//        paused = false;
//        [[OALSimpleAudio sharedInstance] setBgVolume:1.0f];
//    
//}





- (void)spawnNewObstacle
{
    if(playing)
    {
    CCNode *previousObstacle = [_obstacles lastObject];
    
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    
    if (!previousObstacle) {
        // this is the first obstacle
        previousObstacleXPosition = firstObstaclePosition;
    }
    
    NSInteger cb_id = arc4random_uniform(3);
    CGFloat randomDistance = arc4random_uniform(winSize.width) + distanceBetweenObstacles;
    
    Obstacle *obstacle = (Obstacle *) [CCBReader load:obstacles_cbs[cb_id]];
    obstacle.position = ccp(previousObstacleXPosition + randomDistance, 211);
    
    switch (cb_id) {
        case 0:
            obstacle.scale = 0.8;
            break;
            
        case 1:
            obstacle.scale = 1.0;
            break;
        case 2:
            obstacle.scale = 0.4;
            obstacle.anchorPoint = ccp(0.5f, 0.0f);
            obstacle.position = ccp(previousObstacleXPosition + randomDistance, 211);
            obstacle.animationManager.playbackSpeed = 1.8f;
            break;
        default:
            break;
    }
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
    }
}

-(void)spawnNewFireball
{
    if( _fireballs.count < 4)
    {
        CCSprite *weapon;
        weapon = (CCSprite *) [CCBReader load:weapons_cbs[0]];
        weapon.position = ccp(_hero.position.x + 60, _hero.position.y);
        weapon.scale = 0.25;
        weapon.physicsBody.sensor = true;
        [_physicsNode addChild:weapon];
        [_fireballs addObject:weapon];
    }
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSInteger hero_actual_y = [[NSString stringWithFormat: @"%.2f", _hero.position.y] integerValue];
    if ( (hero_actual_y - hero_y_ini_pos) < 1 && !jumping)
    {
        [self jumpRunner];
    }
}


- (void)update:(CCTime)delta
{
    if(playing && !paused )
    {
        // loop the ground
        for (CCNode *ground in _grounds)
        {
            // get the world position of the ground
            CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
            // get the screen position of the ground
            CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
            // if the left corner is one complete width off the screen, move it to the right
            if (groundScreenPosition.x <= (-1 * ground.contentSize.width))
            {
                ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
            }
            // clamp velocity
            float yVelocity = clampf(_hero.physicsBody.velocity.y, 0 * MAXFLOAT, 50.f);
            _hero.physicsBody.velocity = ccp(-0.5, yVelocity);
        }
        
        _hero.position = ccp(_hero.position.x + delta * scrollSpeed, _hero.position.y);
        _physicsNode.position = ccp(_physicsNode.position.x - ( scrollSpeed * delta), _physicsNode.position.y);
    }
    
    if(playing && !paused)
    {
        NSMutableArray *offScreenObstacles = nil;
        
        for (CCNode *obstacle in _obstacles)
        {
            CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
            CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
            
            if (obstacleScreenPosition.x < -obstacle.contentSize.width)
            {
                if (!offScreenObstacles)
                {
                    offScreenObstacles = [NSMutableArray array];
                }
                
                [offScreenObstacles addObject:obstacle];
            }
        }
        
        for (CCNode *obstacleToRemove in offScreenObstacles)
        {
            [obstacleToRemove removeFromParent];
            [_obstacles removeObject:obstacleToRemove];
            // for each removed obstacle, add a new one
            [self spawnNewObstacle];
            if(_obstacles.count < obstaclesMaxQt)
            {
                [self spawnNewObstacle];
            }
        }
        
        //Move fireballs or kick out the ones off screen
        NSMutableArray *offScreenFireballs = nil;
        for(CCNode *fireball in _fireballs)
        {
            CGPoint fireballWorldPosition = [_physicsNode convertToWorldSpace:fireball.position];
            CGPoint fireballScreenPosition = [self convertToNodeSpace:fireballWorldPosition];
            
            if ( (fireballScreenPosition.x - (fireball.contentSize.width * 0.3)) > winSize.width )
            {
                //Add off screen fb to the delayed delete
                if(!offScreenFireballs)
                {
                    offScreenFireballs = [NSMutableArray array];
                }
                [offScreenFireballs addObject:fireball];
            }else{
                fireball.position = ccp(fireball.position.x + delta * (scrollSpeed*1.7), fireball.position.y);
            }
        }
        
        for(CCNode *offscreenfireball in offScreenFireballs)
        {
            [offscreenfireball removeFromParent];
            [_fireballs removeObject:offscreenfireball];
        }
        
        NSInteger hero_actual_y = [[NSString stringWithFormat: @"%.2f", _hero.position.y] integerValue];
        if( (hero_actual_y - hero_y_ini_pos) > 1)
        {
            jumping = TRUE;
        }
        
        if ( jumping )
        {
            //CCLOG(@"2) %.2ld, dif: %.2ld", (long)hero_actual_y, (long)(hero_actual_y - hero_y_ini_pos) );
            if( (hero_actual_y - hero_y_ini_pos) < 1)
            {
                [_hero.animationManager runAnimationsForSequenceNamed:@"walking"];
                jumping = false;
                
            }
        }
    }
}
  
//}
@end