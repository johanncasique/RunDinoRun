//
//  PauseLayer.m
//  DinoRunner
//
//  Created by kembikio on 22/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "PauseLayer.h"
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



@implementation PauseLayer{
     CCNode *screen_pause;
    CCLabelTTF *_score_label;
    CCNode *_btn_fire_fireball;
    CCSprite *_hero;
    CCNode *_background;
    
}


-(void)ask_resume_game
{
   
   
    
  
    [[OALSimpleAudio sharedInstance] setBgVolume:1.0f];
   

}


-(void)score
{
    
}

-(void)sound
{
    [[OALSimpleAudio sharedInstance] stopBg];
}
@end
