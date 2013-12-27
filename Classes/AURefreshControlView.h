//
//  AURefreshControlView.h
//  AURefreshControl
//
//  Created by Emil Wojtaszek on 23.12.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AURefreshControlView;
typedef void (^AURefreshControlViewHandler)(AURefreshControlView *view);

typedef NS_ENUM(NSUInteger, AURefreshControlViewState) {
    AURefreshControlViewStateNormal = 0,
    AURefreshControlViewStateStopped,
    AURefreshControlViewStateLoading,
};

typedef NS_ENUM(NSUInteger, AURefreshControlViewPosition) {
    AURefreshControlViewPositionTop = 0,
    AURefreshControlViewPositionBottom,
    AURefreshControlViewPositionLeft,
    AURefreshControlViewPositionRight,
};

@protocol AURefreshControlViewDelegate <NSObject>
- (void)refreshControlViewDidUpdateContentOffset:(CGPoint)offset;
- (void)refreshControlViewDidUpdateProgress:(CGFloat)progress;
- (void)refreshControlViewDidChangeState:(AURefreshControlViewState)state;
@end

@interface AURefreshControlView : UIView <AURefreshControlViewDelegate>
// init
- (id)initWithPosition:(AURefreshControlViewPosition)position;

// start/top animating
- (void)triggerRefresh;
- (void)stopAnimating;

// configuration
@property (nonatomic, assign) CGFloat threshold;
@property (nonatomic, assign, readonly) CGFloat progress;
@property (nonatomic, assign, readonly) AURefreshControlViewPosition position;
@property (nonatomic, assign, readonly) AURefreshControlViewState state;

// views
@property (nonatomic, weak, readonly) UIScrollView *scrollView;
@end

@interface UIScrollView (AURefreshControlView)
- (void)addRefreshControlView:(AURefreshControlView *)view
                actionHandler:(AURefreshControlViewHandler)handler;
@end
