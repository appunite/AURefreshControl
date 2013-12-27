//
//  AUViewController.m
//  AURefreshControl
//
//  Created by Emil Wojtaszek on 19.12.2013.
//  Copyright (c) 2013 AppUnite.com. All rights reserved.
//

#import "AUViewController.h"
#import "YPRefreshControlView.h"

@interface AUViewController ()
@property (nonatomic, strong) UIView *thresholdView;
@end

@implementation AUViewController {
    __weak UIScrollView *_scrollView;
}

- (void)loadView {
    // get app frame
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    
    // create and assign view
    UIScrollView* view = [[UIScrollView alloc] initWithFrame:rect];
    view.delegate = self;
    view.maximumZoomScale = 2.0f;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor whiteColor];
    view.contentSize = CGSizeMake(0.f, 1000);
    self.view = view;

    UILabel *xx = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 180, 100)];
    [xx setText:@"dsfsdfsd sdf sdf sdfds f dfgd gd fgfgdf gdsfg dsf gdsf gds fg dfg dg df g dsfgdfgdsfg dfg dfsgdfg"];
    [view addSubview:xx];
    
    // save weak referance
    _scrollView = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    YPRefreshControlView *tv = [[YPRefreshControlView alloc] initWithPosition:AURefreshControlViewPositionTop];
    
    [_scrollView addRefreshControlView:tv actionHandler:^(AURefreshControlView *v) {
        [v performSelector:@selector(stopAnimating) withObject:nil afterDelay:5.0f];
    }];
    
    [tv setImage:[[UIImage imageNamed:@"spinnerRingFatLight"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.thresholdView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.thresholdView.backgroundColor = [UIColor yellowColor];
    [_scrollView addSubview:self.thresholdView];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewWillLayoutSubviews
//{
//    CGRect rect = _scrollView.bounds;
//    rect.size.height = _scrollView.contentSize.height;
//    self.thresholdView.frame = rect;
//}

@end
