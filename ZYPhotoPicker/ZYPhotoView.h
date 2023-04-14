//
//  ZYPhotoView.h
//  ZYPhotoPicker
//
//  Created by 张宇 on 2023/4/13.
//

#import <UIKit/UIKit.h>
#import <HXPhotoPicker.h>
#import <CoreServices/CoreServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYPhotoView : UIScrollView

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

/// 已选择的图片.completion=yes才会有值
@property (nonatomic, strong) void (^photosCompletionBlock) (NSMutableArray *photosArray, BOOL completion);

/// 已选择的视频.completion=yes才会有值
@property (nonatomic, strong) void (^videosCompletionBlock) (NSMutableArray *videosArray, BOOL completion);

@end

NS_ASSUME_NONNULL_END
