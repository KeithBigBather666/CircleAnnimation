//
//  ViewController.m
//  01-自定义转场动画CABasicAnnimation
//
//  Created by NIAN on 2017/5/13.
//  Copyright © 2017年 NIAN. All rights reserved.
//

#import "ViewController.h"
#import "WeCircleAnimation.h"
@interface ViewController ()
@property (nonatomic, strong) WeCircleAnimation *circleAnnimation;
@end

@implementation ViewController

-(void)awakeFromNib{
    [super awakeFromNib];
    //1.设置展示样式为自定义
    self.modalPresentationStyle = UIModalPresentationCustom;
    //2.设置转场代理
    self.circleAnnimation = [[WeCircleAnimation alloc]init];
    self.transitioningDelegate = self.circleAnnimation;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  
    [self dismissViewControllerAnimated:YES completion:nil];

}


@end
