//
//  ZYVideoView.m
//  ZYPhotoPicker
//
//  Created by 张宇 on 2024/11/4.
//

#import "ZYVideoView.h"

@interface ZYVideoView () <HXPhotoViewDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) NSMutableArray *videoArray;
@end

@implementation ZYVideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.photoView];
    }
    return self;
}

#pragma mark -- manager
- (HXPhotoManager *)manager
{
    if (!_manager) {
        _manager = [HXPhotoManager.alloc initWithType:HXPhotoManagerSelectedTypeVideo];
        _manager.configuration.saveSystemAblum = YES;
        _manager.configuration.openCamera = YES;
        _manager.configuration.videoMaxNum = 9;
        _manager.configuration.maxNum = 0;
        _manager.configuration.requestImageAfterFinishingSelection = YES;
        _manager.configuration.rowCount = 4;
        _manager.configuration.showDateSectionHeader = NO;
        _manager.configuration.selectTogether = NO;
        _manager.configuration.hideOriginalBtn = NO;
        __weak typeof(self) weakSelf = self;
        _manager.configuration.shouldUseCamera = ^(UIViewController *viewController, HXPhotoConfigurationCameraType cameraType, HXPhotoManager *manager) {
            
            // 这里拿使用系统相机做例子
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = (id)weakSelf;
            imagePickerController.allowsEditing = NO;
            NSString *requiredMediaTypeImage = (NSString *)kUTTypeImage;
            NSString *requiredMediaTypeMovie = (NSString *)kUTTypeMovie;
            NSArray *arrMediaTypes;
            if (cameraType == HXPhotoConfigurationCameraTypePhoto) {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeImage,nil];
            }else if (cameraType == HXPhotoConfigurationCameraTypeVideo) {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeMovie,nil];
            }else {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeImage, requiredMediaTypeMovie,nil];
            }
            [imagePickerController setMediaTypes:arrMediaTypes];
            // 设置录制视频的质量
            [imagePickerController  setVideoQuality:UIImagePickerControllerQualityTypeHigh];
            //设置最长摄像时间
            [imagePickerController setVideoMaximumDuration:60.f];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            imagePickerController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
            [viewController presentViewController:imagePickerController animated:YES completion:nil];
        };
    }
    return _manager;
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    HXPhotoModel *model;
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        model = [HXPhotoModel photoModelWithImage:image];
        if (self.manager.configuration.saveSystemAblum) {
            [HXPhotoTools savePhotoToCustomAlbumWithName:self.manager.configuration.customAlbumName photo:model.thumbPhoto];
        }
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
        float second = 0;
        second = urlAsset.duration.value/urlAsset.duration.timescale;
        model = [HXPhotoModel photoModelWithVideoURL:url videoTime:second];
        if (self.manager.configuration.saveSystemAblum) {
            [HXPhotoTools saveVideoToCustomAlbumWithName:self.manager.configuration.customAlbumName videoURL:url];
        }
    }
    if (self.manager.configuration.useCameraComplete) {
        self.manager.configuration.useCameraComplete(model);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath isAddItem:(BOOL)isAddItem photoView:(HXPhotoView *)photoView
{
    return _itemSize;
}

- (CGFloat)photoViewHeight:(HXPhotoView *)photoView
{
    return _photoViewAllHeight;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- photoView
- (HXPhotoView *)photoView
{
    if (!_photoView) {
        _photoView = [HXPhotoView photoManager:self.manager];
        _photoView.lineCount = 1;
        _photoView.delegate = self;
        _photoView.outerCamera = YES;
        _photoView.previewShowDeleteButton = YES;
        _photoView.showAddCell = YES;
        _photoView.backgroundColor = UIColor.whiteColor;
    }
    return _photoView;
}

- (void)photoListViewControllerDidDone:(HXPhotoView *)photoView allList:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photos videos:(NSArray<HXPhotoModel *> *)videos original:(BOOL)isOriginal
{
    
    _videoArray = NSMutableArray.alloc.init;
    
    __weak typeof(self) weakSelf = self;
    
    ///  返回回调加载状态
    [self videoCompletionWithCompletion:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /// 视频获取
        if (videos.count == 0) {
            weakSelf.userInteractionEnabled = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf videoCompletionWithCompletion:YES];
            });
        } else {
            weakSelf.userInteractionEnabled = NO;
            for (HXPhotoModel *model in videos) {
                [model exportVideoWithPresetName:AVAssetExportPresetMediumQuality startRequestICloud:^(PHImageRequestID iCloudRequestId, HXPhotoModel * _Nullable model) {
                    
                } iCloudProgressHandler:^(double progress, HXPhotoModel * _Nullable model) {
                    
                } exportProgressHandler:^(float progress, HXPhotoModel * _Nullable model) {
                    
                } success:^(NSURL * _Nullable videoURL, HXPhotoModel * _Nullable model) {
                    if (videoURL.path) {
                        [weakSelf.videoArray addObject:videoURL.path];
                    } else {
                        [weakSelf.videoArray addObject:@"1"];
                    }
                    
                    if (weakSelf.videoArray.count == videos.count) {
                        weakSelf.userInteractionEnabled = YES;
                        [weakSelf.videoArray removeObject:@"1"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf videoCompletionWithCompletion:YES];
                        });
                    }
                } failed:^(NSDictionary * _Nullable info, HXPhotoModel * _Nullable model) {
                    [weakSelf.videoArray addObject:@"1"];
                    if (weakSelf.videoArray.count == videos.count) {
                        weakSelf.userInteractionEnabled = YES;
                        [weakSelf.videoArray removeObject:@"1"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf videoCompletionWithCompletion:YES];
                        });
                    }
                }];
            }
        }
    });
}

#pragma mark -- set专区
- (void)addWithFrame:(CGRect)frame
{
    self.frame = frame;
    _photoView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)setPhotoViewAllHeight:(CGFloat)photoViewAllHeight
{
    _photoViewAllHeight = photoViewAllHeight;
    [self photoViewHeight:_photoView];
}

- (void)videoCompletionWithCompletion:(BOOL)completion
{
    if (self.videosCompletionBlock) {
        self.videosCompletionBlock(_videoArray, completion);
    }
}

@end
