//
//  ViewController.m
//  ZYPhotoPicker Example
//
//  Created by 张宇 on 2023/4/13.
//

#import "ViewController.h"
#import "ZYPhotoView.h"
#import "ZYVideoView.h"

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
    [photoView addWithFrame: CGRectMake(0, 50, 120 , 60)];
    [self.view addSubview:photoView];
    
    ZYVideoView *videoView = ZYVideoView.alloc.init;
    videoView.layer.cornerRadius = 4;
    videoView.layer.borderColor = UIColor.redColor.CGColor;
    videoView.layer.borderWidth = 1;
    videoView.photoViewAllHeight = 60;
    videoView.itemSize = CGSizeMake(100, 40);
    [videoView addWithFrame: CGRectMake(0, 300, 120 , 60)];
    [self.view addSubview:videoView];
    videoView.videosCompletionBlock = ^(NSMutableArray * _Nonnull videosArray, BOOL completion) {
        NSLog(@"videosArray == %@", videosArray);
    };
    
}


@end
