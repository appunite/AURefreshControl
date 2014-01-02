//
//  YPRefreshControlView.m
//  AURefreshControl
//
//  Created by Emil Wojtaszek on 27.12.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import "YPRefreshControlView.h"

#define DEGREES_TO_RADIANS(x) (x)/180.0*M_PI
#define RADIANS_TO_DEGREES(x) (x)/M_PI*180.0

@interface YPRefreshControlView ()
@property (nonatomic, weak) CAShapeLayer *shapeLayer;
@property (nonatomic, weak) CALayer *imageLayer;
@end

@implementation YPRefreshControlView

- (id)init
{
    self = [super init];
    if (self) {

        //init icon layer
        CALayer *imageLayer = [CALayer layer];
        imageLayer.contentsScale = [UIScreen mainScreen].scale;
        imageLayer.opacity = 0.f;
        [self.layer addSublayer:imageLayer];
        
        //init arc draw layer
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.fillColor = nil;
//        shapeLayer.strokeColor = [UIColor colorWithRed:241.f/255.f green:21.f/255.f blue:19.f/255.f alpha:1.f].CGColor;
        shapeLayer.strokeColor = [UIColor colorWithRed:41.f/255.f green:21.f/255.f blue:19.f/255.f alpha:1.f].CGColor;
        shapeLayer.strokeEnd = 0.0f;
        shapeLayer.shadowColor = [UIColor colorWithWhite:1 alpha:0.4f].CGColor;
        shapeLayer.shadowOpacity = 0.7f;
        shapeLayer.shadowRadius = 20.f;
        shapeLayer.contentsScale = [UIScreen mainScreen].scale;
        shapeLayer.lineWidth = 2.f;
        shapeLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:shapeLayer];

        // save weak referances
        _shapeLayer = shapeLayer;
        _imageLayer = imageLayer;
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _imageLayer.contents = (__bridge id)(image.CGImage);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGSize imageSize = _image.size;
    CGPoint center = CGPointMake(rintf(CGRectGetMidX(self.bounds)), rintf(self.threshold * .5f));
    CGPoint offset = CGPointMake(rintf(imageSize.width * .5f), rintf(imageSize.height * .5f));
    CGRect controlRect = CGRectMake(center.x - offset.x, center.y - offset.y, imageSize.width, imageSize.height);

    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:offset
                                                              radius:(_image.size.width/2.0f -1.f)
                                                          startAngle:-M_PI_2
                                                            endAngle:M_PI * 3/2
                                                           clockwise:YES];
    
    _imageLayer.frame = controlRect;
    _shapeLayer.frame = controlRect;
    _shapeLayer.path = bezierPath.CGPath;
}


#pragma mark -
#pragma mark AURefreshControlViewDelegate

- (void)refreshControlViewDidUpdateContentOffset:(CGPoint)offset {
    // default no nothing
}

- (void)refreshControlViewDidUpdateProgress:(CGFloat)progress {
    
    if (progress >= 0 && progress <= 1.0f) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = [NSNumber numberWithFloat:((CAShapeLayer *)self.shapeLayer.presentationLayer).strokeEnd];
        animation.toValue = [NSNumber numberWithFloat:progress];
        animation.duration = 0.1f;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [_shapeLayer addAnimation:animation forKey:@"animation"];
    }
}

- (void)refreshControlViewDidChangeState:(AURefreshControlViewState)state {
    if (state == AURefreshControlViewStateLoading) {
        _shapeLayer.opacity = 0.f;
        _imageLayer.opacity = 1.f;

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.fromValue = @(-M_PI_2);
        animation.toValue = @(2 * M_PI - M_PI_2);
        animation.duration = 1.0f;
        animation.repeatCount = INFINITY;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [_imageLayer addAnimation:animation forKey:@"animation"];

    }
    
    else if (state == AURefreshControlViewStateNormal) {
        _shapeLayer.opacity = 1.f;
        _imageLayer.opacity = 0.f;
    }
}

@end
