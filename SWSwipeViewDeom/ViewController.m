//
//  ViewController.m
//  SWSwipeViewDeom
//
//  Created by EShi on 10/19/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "ViewController.h"
#import "SWSwipeView.h"
@interface ViewController () <SWSwipeViewDataSource>

@property (weak, nonatomic) IBOutlet SWSwipeView *swipeView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _swipeView.dataSource = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SWSwipeViewDataSource
- (NSInteger)numberOfPagesInSwipeView:(SWSwipeView *)swipeView
{
    return 5;
}
- (UIView *)swipeView:(SWSwipeView *)swipeView viewForPageAtIndex:(NSInteger)index resuingView:(UIView *)resuingView
{
    UIView *view = nil;
    if (resuingView == nil) {
        view = [[UIView alloc] initWithFrame:self.swipeView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%ld", (long)index];
        label.tag = 100;
        label.font = [label.font fontWithSize:100];
        [view addSubview:label];
    }else{
        view = resuingView;
        UILabel *label = [view viewWithTag:100];
        label.text = [NSString stringWithFormat:@"%ld", (long)index];
    }
    
    //set background color
    CGFloat red = arc4random() / (CGFloat)INT_MAX;
    CGFloat green = arc4random() / (CGFloat)INT_MAX;
    CGFloat blue = arc4random() / (CGFloat)INT_MAX;
    view.backgroundColor = [UIColor colorWithRed:red
                                           green:green
                                            blue:blue
                                           alpha:1.0];

   // view.backgroundColor = [UIColor brownColor];
    return view;
    
}

- (IBAction)scrollViewToIndex:(id)sender {
    [_swipeView scrollToIndex:3 duration:3.0];
}

@end
