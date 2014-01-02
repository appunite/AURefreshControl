//
//  AURefreshControlView.m
//  AURefreshControl
//
//  Created by Emil Wojtaszek on 23.12.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import "AURefreshControlView.h"

@interface AURefreshControlView ()
@property (nonatomic, copy) AURefreshControlViewHandler refreshHandler;
@property (nonatomic, assign, readwrite) UIEdgeInsets originalEdgeInset;
@property (nonatomic, assign, readwrite) AURefreshControlViewState state;
@property (nonatomic, assign, readwrite) CGFloat progress;
@property (nonatomic, weak, readwrite) UIScrollView *scrollView;
@property (nonatomic, assign, getter = isObserving) BOOL observe;
@end

@implementation AURefreshControlView

#pragma mark -
#pragma mark Init

- (void)dealloc {
    [self _removeObservers];
}

- (id)init {
    self = [super init];
    if (self) {
        // set defaults
        _state = AURefreshControlViewStateNormal;
        self.threshold = 38.0f;
        
        // setup view
        self.contentMode = UIViewContentModeRedraw;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (id)initWithPosition:(AURefreshControlViewPosition)position {
    self = [self init];
    if (self) {
        _position = position;
        
        // change autoresizing mash
        if ([self _isSidePosition]) {
            self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        }
        
        else {
            self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        }
        
//        // layout view
//        switch (_position) {
//            case AURefreshControlViewPositionTop:
//            case AURefreshControlViewPositionBottom:
//                self.frame = CGRectIntegral(CGRectMake((CGRectGetWidth(_scrollView.bounds) - CGRectGetWidth(self.bounds)) /2.f, -CGRectGetHeight(self.bounds),
//                                                       CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)));
//                break;
//            case AURefreshControlViewPositionLeft:
//                self.frame = CGRectIntegral(CGRectMake(-CGRectGetWidth(self.bounds), CGRectGetHeight(_scrollView.bounds) /2.0f,
//                                                       CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)));
//                break;
//            case AURefreshControlViewPositionRight:
//                self.frame = CGRectIntegral(CGRectMake(CGRectGetWidth(_scrollView.bounds), CGRectGetHeight(_scrollView.bounds) /2.0f,
//                                                       CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)));
//                break;
//            default:
//                break;
//        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // update view frame
    self.frame = CGRectIntegral(CGRectMake(0.f, - _threshold, CGRectGetWidth(_scrollView.bounds), _threshold));
}

#pragma mark -
#pragma mark Setters

- (void)setObserve:(BOOL)observe {
    if (_observe != observe) {
        _observe = observe;
        
        if (observe) {
            [self _addObservers];
        }
        
        else {
            [self _removeObservers];
        }
    }
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    [self setObserve:!hidden];
}

- (void)setState:(AURefreshControlViewState)state {
    if (_state != state) {
        _state = state;
        
        // send delegate
        [self refreshControlViewDidChangeState:state];
    }
}

- (void)setProgress:(CGFloat)progress {
    if (_progress != progress) {
        _progress = progress;
        
        // send delegate
        [self refreshControlViewDidUpdateProgress:progress];
    }
}

#pragma mark - public method

- (void)triggerRefresh {
    
    // calculate new inset
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalEdgeInset.top + self.bounds.size.height + 20.0f;
    
    // add animation
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, -currentInsets.top);
    } completion:^(BOOL finished) {
        [self _actionTriggeredState];
    }];
}

- (void)stopAnimating {
    [self _resetScrollViewContentInset:^{
        self.state = AURefreshControlViewStateNormal;
    }];
}

- (void)setThreshold:(CGFloat)threshold {
    // set new threshold value
    _threshold = threshold;
    
    // relayout
    [self setNeedsLayout];
}


#pragma mark -
#pragma mark - Private

- (void)_addObservers {
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.scrollView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)_removeObservers {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
    [self.scrollView removeObserver:self forKeyPath:@"frame"];
}

- (BOOL)_isSidePosition {
    return (self.position == AURefreshControlViewPositionLeft || self.position == AURefreshControlViewPositionRight);
}

- (void)_actionTriggeredState {
    self.state = AURefreshControlViewStateLoading;
    
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    
    if (self.position == AURefreshControlViewPositionTop) {
        CGFloat offset = MAX(self.scrollView.contentOffset.y * -1.f, 0);
        currentInsets.top = MIN(offset, self.originalEdgeInset.top + self.bounds.size.height + 20.0f);
    }
    
    else {
        currentInsets.bottom = MIN(self.threshold, self.originalEdgeInset.bottom + self.bounds.size.height + 40.0f);
    }
    
    [self _setScrollViewContentInset:currentInsets handler:nil];
    
    if (self.refreshHandler) {
        self.refreshHandler(self);
    }
}

- (void)_scrollViewDidScroll:(CGPoint)contentOffset {
    // send delegate
    [self refreshControlViewDidUpdateContentOffset:contentOffset];
    
    CGFloat yOffset = contentOffset.y;
    CGFloat xOffset = contentOffset.x;
    CGFloat overBottomOffsetY = yOffset - self.scrollView.contentSize.height + self.scrollView.frame.size.height;
    CGFloat centerX, centerY;
    switch (self.position) {
        case AURefreshControlViewPositionTop:
            self.progress = ((yOffset + self.originalEdgeInset.top) / -self.threshold);
//            centerX = self.scrollView.center.x + xOffset;
//            centerY = (yOffset + self.originalEdgeInset.top) / 2.0f;
            centerX = self.scrollView.center.x + xOffset;
            centerY = contentOffset.y + self.originalEdgeInset.top + _threshold * .5f;

            break;
        case AURefreshControlViewPositionBottom:
            self.progress = overBottomOffsetY / self.threshold;
            centerX = self.scrollView.center.x + xOffset;
            centerY = CGRectGetHeight(self.scrollView.frame) + CGRectGetHeight(self.frame) / 2.0f + yOffset;
            if (overBottomOffsetY >= 0.0f) {
                centerY -= overBottomOffsetY / 1.5f;
            }
            break;
        case AURefreshControlViewPositionLeft:
            self.progress = xOffset / -self.threshold;
            centerX = xOffset / 2.0f;
            centerY = CGRectGetHeight(self.scrollView.bounds) / 2.0f + yOffset;
            break;
        case AURefreshControlViewPositionRight: {
            CGFloat rightEdgeOffset = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.bounds);
            centerX = self.scrollView.contentSize.width + MAX((xOffset - rightEdgeOffset) / 2.0f, 0);
            centerY = CGRectGetHeight(self.scrollView.bounds) / 2.0f + yOffset;
            self.progress = MAX((xOffset - rightEdgeOffset) / self.threshold, 0);
            break;
        }
        default:
            break;
    }
    
    // update center
    self.center = CGPointMake(centerX, centerY);
    
    switch (self.state) {
        case AURefreshControlViewStateNormal: //detect action
            if (!self.scrollView.isZooming && self.progress > 0.99f) {
                [self _actionTriggeredState];
            }
            break;
        case AURefreshControlViewStateStopped: // finish
        case AURefreshControlViewStateLoading: // wait until stopAnimation
            break;
        default:
            break;
    }
    
}


#pragma mark -
#pragma mark ScrollViewInset

- (void)_resetScrollViewContentInset:(void (^)(void))handler {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalEdgeInset.top;
    currentInsets.bottom = self.originalEdgeInset.bottom;
    [self _setScrollViewContentInset:currentInsets handler:handler];
}

- (void)_setScrollViewContentInset:(UIEdgeInsets)contentInset handler:(void (^)(void))handler {
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction |
     UIViewAnimationOptionCurveEaseOut |
     UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:^(BOOL finished) {
                         if (handler) {
                             handler();
                         }
                     }];
}


#pragma mark -
#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint point = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        [self _scrollViewDidScroll:point];
    }
    
    else if ([keyPath isEqualToString:@"contentSize"]) {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    
    else if ([keyPath isEqualToString:@"frame"]) {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}


#pragma mark -
#pragma mark AURefreshControlViewDelegate

- (void)refreshControlViewDidUpdateContentOffset:(CGPoint)offset {
    // default no nothing
}

- (void)refreshControlViewDidUpdateProgress:(CGFloat)progress {
    // default no nothing
}

- (void)refreshControlViewDidChangeState:(AURefreshControlViewState)state {
    // default no nothing
}

@end


@implementation UIScrollView (AURefreshControlView)

- (void)addRefreshControlView:(AURefreshControlView *)view
                actionHandler:(AURefreshControlViewHandler)handler
{
    // setup view
    view.originalEdgeInset = self.contentInset;
    view.refreshHandler = handler;
    view.scrollView = self;
    view.observe = YES;
    
    // add subview
    [self insertSubview:view atIndex:0];
    
    // relayout
    [view setNeedsLayout];
}

@end
