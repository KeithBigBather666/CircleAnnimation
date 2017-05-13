//
//  WeCircleAnimation.m
//  01-自定义转场动画CABasicAnnimation
//
//  Created by NIAN on 2017/5/13.
//  Copyright © 2017年 NIAN. All rights reserved.
//

#import "WeCircleAnimation.h"

@interface WeCircleAnimation ()<UIViewControllerAnimatedTransitioning,CAAnimationDelegate>
//动画是呈现还是解除
@property (nonatomic, assign) BOOL isPresented;

/**
 保存动画上下文(必须要弱引用,如果强引用则会导致循环引用,内存泄露)
 */
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;


@end


@implementation WeCircleAnimation

//告诉控制器谁来提供展现转场动画
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.isPresented = YES;
    return self;
}
//告诉控制器谁来提供解除转场动画
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    self.isPresented = NO;
    return self;
}

/**
 返回动画时长
 @param transitionContext 转场上下文
 @return 转场动画
 */
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.3;
}


/**
 转场动画最核心的方法-有程序员提供自己的动画实现
 @param transitionContext 转场上下文提供转场动画的所有细节
 容器视图-转场动画的表演的舞台
 转场上下文会对展现的控制器强引用
 */
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    //1.获取容器视图
    UIView *containerView = transitionContext.containerView;
    //2.获取目标视图,如果是展现去toView,如果是解除,去fromView;
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    UIView *view = self.isPresented?toView:fromView;
    
    NSLog(@"%@---%@",fromView,toView);
    //3.添加目标视图到容器视图
    [containerView addSubview:view];
    //4.动画
    [self layerAnimationWithView:view];
    //5.一定要完成转场,如果不完成,系统会一直等待转场完成,就无法接收用户的任何交互
    //应该在动画完成之后在通知系统转场结束
    self.transitionContext = transitionContext;
    
}



-(void)layerAnimationWithView:(UIView *)view{
    //1.创建形状图层ShapeLayer
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    //圆的屏幕边距
    CGFloat mergin = 20;
    //圆的半径
    CGFloat radiu = 25;
    CGRect startRect = CGRectMake(view.bounds.size.width - mergin - radiu*2, mergin, radiu*2, radiu*2);
    
    //2.创建圆形贝塞尔路径 参数是圆的外界矩形
    UIBezierPath *startBezierPath = [UIBezierPath bezierPathWithOvalInRect:startRect];
    CGFloat sWidth = view.bounds.size.width;
    CGFloat sHeight = view.bounds.size.height;
    
    //结束圆的半径(屏幕的半径)
    CGFloat endRadius = sqrt(sWidth * sWidth + sHeight * sHeight);
    //使用缩进矩形创建圆的外接矩形
    CGRect endRect = CGRectInset(startRect, -endRadius, -endRadius);
    //3.外接圆的的贝塞尔路径
    UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:endRect];
    
    //设置形状图层的填充颜色 fillColor:填充圆 strokeColor:边框圆
    //    shapeLayer.fillColor = [UIColor redColor].CGColor;
    //4.绘制号的贝塞尔路径为形状图层的路径
    shapeLayer.path = startBezierPath.CGPath;
    //设置shapeLayer为控制器视图的遮罩图层
    //5.设置mask遮罩图层:1.会裁切图层,让图层只能看见shapelayer的形状的区域 2.一旦将layer设置为遮罩图层之后,填充颜色会失效
    view.layer.mask = shapeLayer;
    //将shape添加到视图中,addSublayer实在当前的图层上添加一个layer的形状区域
    //    [self.view.layer addSublayer:shapeLayer];
    //5.动画 -如果要做layer视图的动画，不能使用UIView的动画，应该使用核心动画
    //    [UIView animateWithDuration:3 animations:^{
    //                //设置图层的路径
    //        layer.path = endPath.CGPath;
    //
    //    }];
    //6.实例化对象
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    //7.设置动画的属性:1.时间  2.填充模式
    //设置动画属性
    //时长
    animation.duration = [self transitionDuration:self.transitionContext];
    //判断是展现还是解除
    if (self.isPresented) {
        //formValue
        animation.fromValue = (__bridge id _Nullable)(startBezierPath.CGPath);
        animation.toValue = (__bridge id _Nullable)(endPath.CGPath);
    }else{
    
        animation.fromValue = (__bridge id _Nullable)(endPath.CGPath);
        animation.toValue = (__bridge id _Nullable)(startBezierPath.CGPath);
    }
   
    //设置向前填充模式
    animation.fillMode = kCAFillModeForwards;
    //完成之后不删除
    animation.removedOnCompletion = NO;
    //设置动画代理 必须要写在添加动画到图层的前面,否则代理不会调用(一旦将动画添加到图层,动画已经开启,在设置代理已经来不及了)
    animation.delegate = self;
    
    
    //8.将动画添加到图层 -shapeLayer,让哪个图层执行动画就应该将动画添加到哪个图层
    [shapeLayer addAnimation:animation forKey:nil];
    
}

/**
 监听动画完成
 
 @param anim 动画
 @param flag 完成
 */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.transitionContext completeTransition:YES];
}

@end
