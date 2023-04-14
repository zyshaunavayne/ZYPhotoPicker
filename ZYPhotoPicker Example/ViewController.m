//
//  ViewController.m
//  ZYPhotoPicker Example
//
//  Created by 张宇 on 2023/4/13.
//

#import "ViewController.h"
#import "ZYPhotoView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ZYPhotoView *photoView = ZYPhotoView.alloc.init;
    photoView.layer.cornerRadius = 4;
    photoView.layer.borderColor = UIColor.redColor.CGColor;
    photoView.layer.borderWidth = 1;
    photoView.photoViewAllHeight = 60;
    photoView.itemSize = CGSizeMake(100, 40);
    photoView.manager.configuration.photoMaxNum = 1;
    [photoView addWithFrame: CGRectMake(0, 50, 120 , 60)];
    [self.view addSubview:photoView];
}


@end
