//
//  SIShiftNavigationController.m
//  ShiftNavigationControllerDemo
//
//  Created by 杨晴贺 on 2017/3/5.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "SIShiftNavigationController.h"

#define RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
// 默认的将要变透明的遮罩的初始透明度(全黑)
#define kDefaultAlpha 0.6
// 当拖动的距离,占了屏幕的总宽高的3/4时, 就让imageview完全显示，遮盖完全消失
#define kTargetTranslateScale 0.75
// 最小移动距离 50
#define kMinPoint 50


@interface ShiftAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic,assign) UINavigationControllerOperation navigationOperation ;
@property (nonatomic,weak) UINavigationController *navigationController ;

@property (nonatomic,assign) BOOL hasTabbar ;
@property (nonatomic,strong) NSMutableArray *screenShotArray ;
@property (nonatomic,assign) NSInteger removeCount ;  // pop删除截图的数量

@end

@implementation ShiftAnimation

#pragma mark --- Delegate
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.4f ;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIImageView *screentImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)] ;
    UIView *coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)] ;
    coverView.backgroundColor = [UIColor blackColor] ;
    coverView.alpha = kDefaultAlpha ;
    UIImage *screenShot = [self screenShot] ;
    screentImageView.image = screenShot ;
    
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] ;
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] ;
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey] ;
    
    CGRect fromViewEndFrame = [transitionContext finalFrameForViewController:fromVc] ;
    fromViewEndFrame.origin.x = SCREEN_WIDTH ;
    CGRect fromViewStartFrame = fromViewEndFrame ;
    CGRect toViewEndFrame = [transitionContext finalFrameForViewController:toVc] ;
    CGRect toViewStartFrame = toViewEndFrame ;
    
    UIView *containerView = [transitionContext containerView] ;
    
    // Push
    if (self.navigationOperation == UINavigationControllerOperationPush){
        [self.screenShotArray addObject:screenShot] ;
        
        // 没有这句，就无法正常Push和Pop出对应的界面
        [containerView addSubview:toView] ;
        
        toView.frame = toViewStartFrame ;
        // 添加截图
        [self.navigationController.view.window insertSubview:screentImageView atIndex:0] ;
        
        
        self.navigationController.view.transform = CGAffineTransformMakeTranslation(SCREEN_WIDTH, 0) ;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            self.navigationController.view.transform  = CGAffineTransformIdentity ;
            screentImageView.center = CGPointMake(-SCREEN_WIDTH/2, SCREEN_HEIGHT/2) ;
        } completion:^(BOOL finished) {
            [screentImageView removeFromSuperview] ;
            [transitionContext completeTransition:YES] ;
        }] ;
    }
    
    // Pop
    if (self.navigationOperation == UINavigationControllerOperationPop){
        fromViewStartFrame.origin.x = 0 ;
        [containerView addSubview:toView] ;
        
        UIImageView *lastVcImgView = [[UIImageView alloc]initWithFrame:CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)] ;
        if(_removeCount > 0){
            for (NSInteger i = 0 ; i < _removeCount ;i++){
                if (i == _removeCount - 1){
                    lastVcImgView.image = [self.screenShotArray lastObject] ;
                    _removeCount = 0 ;
                    break ;
                }else{
                    [self.screenShotArray removeLastObject] ;
                }
            }
        }else{
            lastVcImgView.image = [self.screenShotArray lastObject] ;
        }
        
        screentImageView.layer.shadowColor = [UIColor blackColor].CGColor ;
        screentImageView.layer.shadowOffset = CGSizeMake(-0.8, 0) ;
        screentImageView.layer.shadowOpacity = 0.8 ;
        
        [self.navigationController.view.window addSubview:lastVcImgView] ;
        [lastVcImgView addSubview:coverView] ;
        [self.navigationController.view addSubview:screentImageView] ;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            screentImageView.center = CGPointMake(SCREEN_WIDTH *3/2, SCREEN_HEIGHT/2) ;
            lastVcImgView.center = CGPointMake(SCREEN_WIDTH /2, SCREEN_HEIGHT /2) ;
            coverView.alpha = 0 ;
        } completion:^(BOOL finished) {
            [lastVcImgView removeFromSuperview] ;
            [screentImageView removeFromSuperview] ;
            [coverView removeFromSuperview] ;
            [self.screenShotArray removeLastObject] ;
            [transitionContext completeTransition:YES] ;
        }] ;
    }
}

#pragma mark --- Get / Set
- (NSMutableArray *)screenShotArray{
    if (!_screenShotArray) {
        _screenShotArray = [NSMutableArray array] ;
    }
    return _screenShotArray ;
}
- (void)removeLastScreenShot{
    [self.screenShotArray removeLastObject];
}

- (void)setNavigationController:(UINavigationController *)navigationController{
    _navigationController = navigationController;
    UIViewController *rootVc = self.navigationController.view.window.rootViewController;
    if (self.navigationController.tabBarController == rootVc) {
        _hasTabbar = YES;
    }else{
        _hasTabbar = NO;
    }
}

#pragma mark --- Private Method
- (UIImage *)screenShot{
    UIViewController *rootVc = self.navigationController.view.window.rootViewController ;
    CGSize size = rootVc.view.frame.size ;
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0) ;
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) ;
    if (_hasTabbar){
        [rootVc.view drawViewHierarchyInRect:rect afterScreenUpdates:NO] ;
    }else{
        [self.navigationController.view drawViewHierarchyInRect:rect afterScreenUpdates:NO] ;
    }
    
    // 重上下文中取出UIImage
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext() ;
    
    UIGraphicsEndImageContext() ;
    
    return snapshot ;
    
}

@end


@interface SIShiftNavigationController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) UIImageView *screenshotImageView ;
@property (nonatomic,strong) UIView *coverView ;
@property (nonatomic,strong) NSMutableArray *screenshotImages ;

@property (nonatomic,strong) UIScreenEdgePanGestureRecognizer *panGestureRec ;
@property (nonatomic,strong) ShiftAnimation *animation ;


@end

@implementation SIShiftNavigationController


#pragma mark --- Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self ;
    
    // 设置阴影
    self.view.layer.shadowColor = [UIColor blackColor].CGColor ;
    self.view.layer.shadowOffset = CGSizeMake(-0.8, 0) ;
    self.view.layer.shadowOpacity = 0.8 ;
    
    //  手势识别器
    _panGestureRec = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)] ;
    _panGestureRec.edges = UIRectEdgeLeft ;  // 边缘方向
    
    // 添加手势
    [self.view addGestureRecognizer:_panGestureRec] ;
    
    _screenshotImages = [NSMutableArray array] ;
    
    _screenshotImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)] ;
    _coverView = [[UIView alloc]initWithFrame:_screenshotImageView.frame] ;
    _coverView.backgroundColor = [UIColor blackColor] ;
}

#pragma mark --- Action
- (void)panGestureAction:(UIScreenEdgePanGestureRecognizer *)panGestureRec{
    if (self.visibleViewController == self.viewControllers.firstObject) return ;
    
    switch (panGestureRec.state) {
        case UIGestureRecognizerStateBegan:
            // 开始拖拽阶段
            [self dragBegin] ;
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
            // 拖拽中
            [self dragEnd] ;
            break ;
        default:
            [self dragging:panGestureRec] ;
            break;
    }
}

#pragma mark --- Get / Set
- (ShiftAnimation *)animation{
    if (!_animation) {
        _animation = [[ShiftAnimation alloc]init] ;
    }
    return _animation ;
}


#pragma mark --- Delegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    self.animation.navigationOperation = operation ;
    self.animation.navigationController = self ;
    return self.animation ;
}

#pragma mark --- OverRide
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.viewControllers.count >= 1){
        // 截图
        [self screenShot] ;
    }
    [super pushViewController:viewController animated:animated] ;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    NSInteger index = self.viewControllers.count ;
    if (_screenshotImages.count >= index - 1) {
        [_screenshotImages removeLastObject] ;
    }
    return [super popViewControllerAnimated:animated] ;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    NSInteger removeCount = 0 ;
    for (NSInteger i = self.viewControllers.count - 1 ; i > 0 ; i--){
        if (viewController == self.viewControllers[i]) {
            break ;
        }
        [_screenshotImages removeLastObject] ;
        removeCount++ ;
    }
    self.animation.removeCount = removeCount ;
    return [super popToViewController:viewController animated:animated] ;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated{
    return [self popToViewController:self.viewControllers.firstObject animated:animated] ;
}

#pragma mark --- Private Method
// 截图并保存
- (void)screenShot{
    UIViewController *rootVc = self.view.window.rootViewController ;
    CGSize size = rootVc.view.frame.size ;
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0) ;
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) ;
    if (self.tabBarController == rootVc) {
        [rootVc.view drawViewHierarchyInRect:rect afterScreenUpdates:NO] ;
    }else{
        [self.view drawViewHierarchyInRect:rect afterScreenUpdates:NO] ;
    }
    
    // 从上下文中,取出image
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext() ;
    // 添加到数组中
    if(snapshot){
        [self.screenshotImages addObject:snapshot] ;
    }
    
    // 结束上下文
    UIGraphicsEndImageContext() ;
}

// 开始拖动,添加图片和遮罩
- (void)dragBegin{
    [self.view.window insertSubview:_screenshotImageView atIndex:0] ;
    _screenshotImageView.image = _screenshotImages.lastObject ;
    
    [self.view.window insertSubview:_coverView aboveSubview:_screenshotImageView] ;
}

// 当拖动到指定距离时,让Imageview完全显示,遮罩层消息
- (void)dragging:(UIPanGestureRecognizer *)pan{
    // X偏移量
    CGFloat offsetX = [pan translationInView:self.view].x ;
    // View平移
    if(offsetX > 0){
        self.view.transform = CGAffineTransformMakeTranslation(offsetX, 0) ;
    }
    
    CGFloat currentTranslateScaleX = offsetX / self.view.frame.size.width ;
    if(offsetX < SCREEN_WIDTH){
        // 图片平移
        _screenshotImageView.transform = CGAffineTransformMakeTranslation((offsetX - SCREEN_WIDTH) * 0.6, 0) ;
    }
    // 改变遮罩
    CGFloat alpha = kDefaultAlpha - (currentTranslateScaleX/kTargetTranslateScale) * kDefaultAlpha;
    self.coverView.alpha = alpha ;
}

// 拖动结束时,将图片和遮罩重父控件上移除
- (void)dragEnd{
    CGFloat translateX = self.view.transform.tx ;
    CGFloat width = self.view.frame.size.width ;
    
    if (translateX <= kMinPoint) {
        // 当手指一动的距离不满足条件
        [UIView animateWithDuration:0.3 animations:^{
            self.view.transform = CGAffineTransformIdentity ;
            _screenshotImageView.transform = CGAffineTransformMakeTranslation(-SCREEN_WIDTH, 0) ;
            _coverView.alpha = kDefaultAlpha ;
        } completion:^(BOOL finished) {
            [_screenshotImageView removeFromSuperview] ;
            [_coverView removeFromSuperview] ;
        }] ;
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(width, 0) ;
            _screenshotImageView.transform = CGAffineTransformIdentity ;
            _coverView.alpha = 0 ;
        } completion:^(BOOL finished) {
            self.view.transform = CGAffineTransformIdentity ;
            [_screenshotImageView removeFromSuperview] ;
            [_coverView removeFromSuperview] ;
            
            [self popViewControllerAnimated:NO] ;
            [self.animation removeLastScreenShot] ;
        }] ;
    }
}

@end
