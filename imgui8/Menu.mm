#import <UIKit/UIKit.h>
#import "DrawView.h"

extern bool menu_open;

@interface ImGuiLoad : NSObject
@property (nonatomic, strong) ImGuiDrawView *vna;
@property (nonatomic, strong) UIButton *toggleButton;
+ (instancetype)share;
- (void)initMenu;
- (void)toggleMenu;
@end

@implementation ImGuiLoad

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ImGuiLoad share] initMenu];
    });
}

+ (instancetype)share {
    static ImGuiLoad *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[ImGuiLoad alloc] init];
    });
    return tool;
}

- (UIWindow *)findActiveWindow {
    UIApplication *app = [UIApplication sharedApplication];
    for (UIScene *scene in app.connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *win in windowScene.windows) {
                if (win.isKeyWindow) return win;
            }
            if (windowScene.windows.count > 0) {
                return windowScene.windows.firstObject;
            }
        }
    }
    return app.windows.firstObject;
}

- (void)initMenu {
    UIWindow *keyWindow = [self findActiveWindow];
    if (!keyWindow) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self initMenu];
        });
        return;
    }

    if (!_vna) {
        _vna = [[ImGuiDrawView alloc] init];
        _vna.view.frame = keyWindow.bounds;
        _vna.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _vna.view.backgroundColor = [UIColor clearColor];
        _vna.view.hidden = YES;
        menu_open = false;
        [keyWindow addSubview:_vna.view];
    }

    if (!_toggleButton) {
        _toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _toggleButton.frame = CGRectMake(16, 140, 46, 46);
        _toggleButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85f];
        _toggleButton.layer.cornerRadius = 23.0f;
        _toggleButton.layer.borderWidth = 1.2f;
        _toggleButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [_toggleButton setTitle:@"M" forState:UIControlStateNormal];
        [_toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _toggleButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];

        [_toggleButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_toggleButton addGestureRecognizer:pan];

        [keyWindow addSubview:_toggleButton];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIView *btn = gesture.view;
    UIView *superview = btn.superview;
    if (!btn || !superview) return;

    CGPoint translation = [gesture translationInView:superview];
    CGPoint newCenter = CGPointMake(btn.center.x + translation.x, btn.center.y + translation.y);

    CGFloat halfW = btn.bounds.size.width / 2.0f + 8.0f;
    CGFloat halfH = btn.bounds.size.height / 2.0f + 8.0f;
    newCenter.x = MIN(MAX(newCenter.x, halfW), superview.bounds.size.width - halfW);
    newCenter.y = MIN(MAX(newCenter.y, halfH), superview.bounds.size.height - halfH);

    btn.center = newCenter;
    [gesture setTranslation:CGPointZero inView:superview];
}

- (void)toggleMenu {
    if (!_vna) {
        [self initMenu];
    }
    menu_open = !menu_open;
    _vna.view.hidden = !menu_open;
    [_vna.view setUserInteractionEnabled:menu_open];

    if (_toggleButton) {
        [_toggleButton setTitle:(menu_open ? @"X" : @"M") forState:UIControlStateNormal];
        [self.toggleButton.superview bringSubviewToFront:_toggleButton];
    }
}

@end
