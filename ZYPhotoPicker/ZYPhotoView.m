//
//  ZYPhotoView.m
//  ZYPhotoPicker
//
//  Created by 张宇 on 2023/4/13.
//

#import "ZYPhotoView.h"

@interface ZYPhotoView () <HXPhotoViewDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) NSMutableArray *photoArray;
@end

@implementation ZYPhotoView

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
        _manager = [HXPhotoManager.alloc initWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.saveSystemAblum = YES;
        _manager.configuration.openCamera = YES;
        _manager.configuration.lookGifPhoto = NO;
        _manager.configuration.photoMaxNum = 0;
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
    }else  if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
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
    
    _photoArray = NSMutableArray.alloc.init;
    
    __weak typeof(self) weakSelf = self;
    
    ///  返回回调加载状态
    [self photoCompletionWithCompletion:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /// 图片获取
        if (photos.count == 0) {
            weakSelf.userInteractionEnabled = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf photoCompletionWithCompletion:YES];
            });
        } else {
            weakSelf.userInteractionEnabled = NO;
            for (HXPhotoModel *model in photos) {
                [model requestPreviewImageWithSize:PHImageManagerMaximumSize startRequestICloud:^(PHImageRequestID iCloudRequestId, HXPhotoModel *model) {
                } progressHandler:^(double progress, HXPhotoModel *model) {
                } success:^(UIImage *image, HXPhotoModel *model, NSDictionary *info) {
                    if (image) {
                        [weakSelf.photoArray addObject:image];
                    }else{
                        [weakSelf.photoArray addObject:@"1"];
                    }
                    if (weakSelf.photoArray.count == photos.count) {
                        weakSelf.userInteractionEnabled = YES;
                        [weakSelf.photoArray removeObject:@"1"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf photoCompletionWithCompletion:YES];
                        });
                    }
                } failed:^(NSDictionary *info, HXPhotoModel *model) {
                    [weakSelf.photoArray addObject:@"1"];
                    if (weakSelf.photoArray.count == photos.count) {
                        weakSelf.userInteractionEnabled = YES;
                        [weakSelf.photoArray removeObject:@"1"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf photoCompletionWithCompletion:YES];
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

- (void)photoCompletionWithCompletion:(BOOL)completion
{
    if (completion) {
        __weak typeof(self) weakSelf = self;
        if (_photoArray.count != 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                /// 获取被压缩大小。
                CGFloat ysSize = 400.;
                if (weakSelf.imageQualityType == ZYPhotoViewImageQualityType0) {
                    ysSize = 1.;
                }
                
                if (weakSelf.imageQualityType == ZYPhotoViewImageQualityType200) {
                    ysSize = 200. * 1024.;
                }
                
                if (weakSelf.imageQualityType == ZYPhotoViewImageQualityType400) {
                    ysSize = 400. * 1024.;
                }
                
                if (weakSelf.imageQualityType == ZYPhotoViewImageQualityType800) {
                    ysSize = 800. * 1024.;
                }
                
                if (weakSelf.imageQualityType == ZYPhotoViewImageQualityType1600) {
                    ysSize = 1600. * 1024.;
                }
                
                /// 子线程中压缩图片
                NSData *originData = UIImageJPEGRepresentation(weakSelf.photoArray.firstObject, 1.0);
                CGFloat ysRate = 1.0; /// 压缩比例
                if (originData.length > (ysSize / 2.)) { /// 控制位xK左右
                    ysRate = originData.length / ysSize;
                }
                NSData *imageData = UIImageJPEGRepresentation(weakSelf.photoArray.firstObject, 1 / ysRate);
                UIImage *compressedImage = [UIImage imageWithData:imageData];
                [weakSelf.photoArray removeAllObjects];
                [weakSelf.photoArray addObject:compressedImage];
                dispatch_async(dispatch_get_main_queue(), ^{ /// 压缩成功回到主线程中开始上传
                    weakSelf.photosCompletionBlock(weakSelf.photoArray, completion);
                });
            });
        } else {
            if (self.photosCompletionBlock) {
                self.photosCompletionBlock(_photoArray, completion);
            }
        }
    } else {
        if (self.photosCompletionBlock) {
            self.photosCompletionBlock(_photoArray, completion);
        }
    }
}

@end
