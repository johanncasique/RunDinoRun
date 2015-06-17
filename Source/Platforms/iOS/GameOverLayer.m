//
//  GameOverLayer.m
//  DinoRunner
//
//  Created by kembikio on 1/3/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameOverLayer.h"
#import "Social/Social.h"
#import <UIKit/UIKit.h>






@implementation GameOverLayer{
    CCLabelTTF *scoreLabel;
   }

-(void)restartGame
{

  [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"] ];
    NSLog(@"hola mundo" );
}
-(void)shareButton
{
 
   
    SLComposeViewController *twitter = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            [twitter dismissViewControllerAnimated:NO completion:nil];
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.....");
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Posted....");
                }
                    break;
            }
        };
        NSMutableArray *scoreArray = [NSMutableArray arrayWithObjects:scoreLabel.string, nil];
        [twitter setInitialText:[NSString stringWithFormat:@"OMG! I scored %@ points in the #Run Dino Run! iOS",[NSString pathWithComponents: scoreArray]]];
        UIImage *imagetwitter = [UIImage imageNamed:@"runDinoTwitter"];
        [twitter addImage:imagetwitter];
        [twitter setCompletionHandler:completionHandler];
        [[CCDirector sharedDirector] presentViewController:twitter animated:YES completion:nil];
        
       
    }
    
}




- (void)didLoadFromCCB
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(set_score_to_label:) name:@"set_score_to_label" object:nil];
}

-(void)set_score_to_label:(NSNotification *) notification
{
    
 // NSLog(notification.userInfo[@"score"]);
    scoreLabel.string = notification.userInfo[@"score"];
 [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}

@end
