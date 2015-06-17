#import "Obstacle.h"
@implementation Obstacle {
    CCNode *_obstacle1;
    //CCNode *_obstacle2;
   // CCNode *_obstacle3;
    
}

-(void)didLoadFromCCB
{
	_obstacle1.physicsBody.collisionType = @"level";
//	_obstacle1.physicsBody.sensor = TRUE;
}

#define ARC4RANDOM_MAX      0x100000000
// visibility on a 3,5-inch iPhone ends a 88 points and we want some meat
//static const CGFloat minimumYPositionTopPipe = 128.f;
// visibility ends at 480 and we want some meat
//static const CGFloat maximumYPositionBottomPipe = 440.f;
// distance between top and bottom pipe
//static const CGFloat pipeDistance = 142.f;
// calculate the end of the range of top pipe
//static const CGFloat maximumYPositionTopPipe = maximumYPositionBottomPipe - pipeDistance;

- (void)setupRandomPosition {
    // value between 0.f and 1.f
   //CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX);
    //CGFloat range = minimumYPositionTopPipe - minimumYPositionTopPipe;
    _obstacle1.position = ccp(_obstacle1.position.x, 211);
    //_obstacle2.position = ccp(_obstacle2.position.x, _obstacle1.position.y + pipeDistance);
    //_obstacle3.position = ccp(_obstacle3.position.x, _obstacle1.position.y + pipeDistance);
    
}
@end


