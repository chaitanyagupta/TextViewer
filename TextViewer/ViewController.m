//
//  ViewController.m
//  TextViewer
//
//  Created by Chaitanya Gupta on 10/02/15.
//  Copyright (c) 2015 N/A. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <tgmath.h>


enum {
  TextViewTag = 1
};


@interface ViewController () <UITextViewDelegate>

@property (nonatomic, readonly) UITextView *textView;

@end


@implementation ViewController

static CGFloat FontSize = 20;
static CGFloat DefaultHeight = 40;
static CGFloat MaxHeight = 112;

- (UITextView *)textView {
  return (UITextView *)[self.view viewWithTag:TextViewTag];
}

- (void)loadView {
  CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
  UIView *view = [[UIView alloc] initWithFrame:applicationFrame];
  view.backgroundColor = [UIColor whiteColor];
  self.view = view;
  CGRect bounds = view.bounds;
  
  UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:FontSize];
  CGFloat defaultHeight = DefaultHeight;
  UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0,
                                                                      CGRectGetHeight(bounds) - defaultHeight,
                                                                      CGRectGetWidth(bounds),
                                                                      defaultHeight)];
  textView.tag = TextViewTag;
  textView.delegate = self;
  textView.font = font;
  textView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  textView.layer.borderColor = [[UIColor blackColor] CGColor];
  textView.layer.borderWidth = 1;
  [view addSubview:textView];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillUpdateNotification:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillUpdateNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidLayoutSubviews {
  [self refreshTextViewHeight];
}

- (void)keyboardWillUpdateNotification:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  CGRect endFrame;
  [userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&endFrame];
  endFrame = [self.view convertRect:endFrame fromView:nil];
  double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationOptions animationOptions = [userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16;
  [UIView animateWithDuration:animationDuration
                        delay:0
                      options:animationOptions
                   animations:^{
                     UITextView *textView = [self textView];
                     CGFloat textViewHeight = CGRectGetHeight(textView.bounds);
                     textView.frame = CGRectMake(0,
                                                 CGRectGetHeight(self.view.bounds) - CGRectGetHeight(endFrame) - textViewHeight,
                                                 CGRectGetWidth(self.view.bounds),
                                                 textViewHeight);
                   }
                   completion:nil];
}

- (void)refreshTextViewHeight {
  UITextView *textView = self.textView;
  CGSize contentSize = [self contentSizeRectForTextView:textView];
  CGFloat newHeight = MIN(MaxHeight, ceil(contentSize.height));
  CGFloat currentHeight = CGRectGetHeight(textView.bounds);
  if (newHeight != currentHeight) {
    NSLog(@"current height: %@; new height: %@", @(currentHeight), @(newHeight));
    CGFloat delta = newHeight - currentHeight;
    textView.frame = CGRectMake(0, CGRectGetMinY(textView.frame) - delta, CGRectGetWidth(textView.frame), newHeight);
  }
}

#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
  [self refreshTextViewHeight];
}

- (CGSize)contentSizeRectForTextView:(UITextView *)textView
{
  [textView.layoutManager ensureLayoutForTextContainer:textView.textContainer];
  CGRect textBounds = [textView.layoutManager usedRectForTextContainer:textView.textContainer];
  CGFloat width =  (CGFloat)ceil(textBounds.size.width + textView.textContainerInset.left + textView.textContainerInset.right);
  CGFloat height = (CGFloat)ceil(textBounds.size.height + textView.textContainerInset.top + textView.textContainerInset.bottom);
  return CGSizeMake(width, height);
}

@end
