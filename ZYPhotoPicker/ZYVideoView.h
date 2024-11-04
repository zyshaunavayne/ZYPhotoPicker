//
//  ZYVideoView.h
//  ZYPhotoPicker
//
//  Created by 张宇 on 2024/11/4.
//

#import <UIKit/UIKit.h>
#import <HXPhotoPicker.h>

NS_ASSUME_NONNULL_BEGIN

/// formData表单类型
typedef NS_ENUM(NSUInteger, ZYPhotoViewVideoQualityType) {
    ZYPhotoViewVideoQualityTypeO = 0, /// 原视频
};

@interface ZYVideoView : UIScrollView

/// photoPickerView 会有一些默认配置，需要的话自行调整。
@property (nonatomic, strong) HXPhotoView *photoView;

/// manager 会有一些默认配置，需要的话自行调整。
@property (nonatomic, strong) HXPhotoManager *manager;

/// 设置当前view的frame
/// - Parameter frame: frame
- (void)addWithFrame:(CGRect)frame;

/// 自定义item大小。搜索 HXPhotoViewCustomItemSize 1 并调整。否则不生效
@property (nonatomic, assign) CGSize itemSize;

/// photoView总的高度
@property (nonatomic, assign) CGFloat photoViewAllHeight;

/// 视频的质量 默认原图
@property (nonatomic, assign) ZYPhotoViewVideoQualityType imageQualityType;

/// 已选择的视频.completion=yes才会有值。返回视频地址：本地NSURL-string地址
@property (nonatomic, strong) void (^videosCompletionBlock) (NSMutableArray *videosArray, BOOL completion);


@end

NS_ASSUME_NONNULL_END
