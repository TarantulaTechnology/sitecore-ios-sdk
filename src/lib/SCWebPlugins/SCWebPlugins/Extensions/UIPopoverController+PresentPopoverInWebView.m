#import "UIPopoverController+PresentPopoverInWebView.h"

#include <objc/runtime.h>

@interface UIWebView (SCHookTouchesViewJWSGetPictureListener)

@property ( nonatomic, retain, readonly ) NSString* scLastTouchLocationPoint;

@end

@implementation UIPopoverController (PresentPopoverInWebView)

-(void)presentPopoverFromRect:( CGRect )rect
                    inWebView:( UIWebView* )webView_
{
    CGPoint touchPoint_ = CGPointFromString( webView_.scLastTouchLocationPoint );

    CGRect frame_ = CGRectMake( touchPoint_.x, touchPoint_.y, 10.f, 10.f );

    UIView* scTouchView_ = [ [ UIView alloc ] initWithFrame: frame_ ];
    scTouchView_.alpha = 0.f;
    [ webView_.scrollView addSubview: scTouchView_ ];

    dispatch_async(dispatch_get_main_queue(), ^{
        [ self presentPopoverFromRect: scTouchView_.frame
                               inView: webView_
             permittedArrowDirections: UIPopoverArrowDirectionAny
                             animated: YES ];
    });

    __weak UIView* weakTouchView_ = scTouchView_;
    [ self addOnDeallocBlock: ^
    {
        [ weakTouchView_ removeFromSuperview ];
    } ];
}

@end
