//
//  ViewController.m
//  album
//
//  Created by hanli on 2023/2/9.
//

#import "ViewController.h"

#import "HXPhotoPicker.h"

#import "PHAsset+NOVImagePickerHelper.h"

#import "WAVideoBox.h"






#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (strong, nonatomic) HXPhotoManager *manager;
 
@property (strong, nonatomic) AVPlayer *player ;

@property (strong,nonatomic)  AVAssetExportSession *session;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
//    [self test];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self showAlbum];
}



- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhotoAndVideo];

        
    }
    return _manager;
}


- (void)showAlbum {
    
    self.manager.type = HXPhotoManagerSelectedTypePhotoAndVideo;
    self.manager.configuration.singleJumpEdit = NO;
    self.manager.configuration.singleSelected = NO;
    self.manager.configuration.lookGifPhoto = YES;
    self.manager.configuration.lookLivePhoto = YES;
//    self.manager.configuration.photoEditConfigur.aspectRatio = x;
    self.manager.configuration.photoEditConfigur.onlyCliping = NO;
    
    self.manager.configuration.bottomViewBgColor = [UIColor redColor];
    self.manager.selectPhotoFinishDismissAnimated = NO;
    self.manager.cameraFinishDismissAnimated = NO;
    
    self.manager.configuration.type = HXConfigurationTypeWXChat;


    [self hx_presentSelectPhotoControllerWithManager:self.manager didDone:^(NSArray<HXPhotoModel *> *allList, NSArray<HXPhotoModel *> *photoList, NSArray<HXPhotoModel *> *videoList, BOOL isOriginal, UIViewController *viewController, HXPhotoManager *manager) {
    //    weakSelf.total.text = [NSString stringWithFormat:@"总数量：%ld   ( 照片：%ld   视频：%ld )",allList.count, photoList.count, videoList.count];
    //    weakSelf.original.text = isOriginal ? @"YES" : @"NO";
        NSSLog(@"block - all - %@",allList);
        NSSLog(@"block - photo - %@",photoList);
        NSSLog(@"block - video - %@",videoList);
        
        HXPhotoModel * videoModel = videoList.firstObject;
    
        
        NSLog(@" the first video url = %@", videoModel.asset.movieURL);
        
//        [self videoToM4aWithVideoFilePath:videoModel.asset.movieURL.path];
        
//        [self extractVideoSoundWithVideoURl:videoModel.asset.movieURL];
        
        [self extractAuidoWithVideoPath:videoModel.asset.movieURL.path];
        
    } cancel:^(UIViewController *viewController, HXPhotoManager *manager) {
        NSSLog(@"block - 取消了");
        
       
    }];
    
}



- (void)extractVideoSoundWithVideoURl : (NSURL *)videoURL {
    
    NSString *filePath = @"/var/mobile/Media/PhotoData/Metadata/DCIM/114APPLE/IMG_4524.medium.MP4";
    videoURL = [NSURL URLWithString:filePath];
    
    WAVideoBox  *box = [[WAVideoBox alloc]init];
    [box clean];
    [box appendVideoByPath:videoURL.path];
    [box extractVideoSound];
    NSString *audioPath = [self buildFilePath];
    [box asyncFinishEditByFilePath:audioPath progress:^(float progress) {

//        [NOVToast showHubProgress:progress title:@"音频提取中"];

    } complete:^(NSError *error) {

        if (error) {
            
            
//            [NOVToast showFailToast:@"音视频提取失败"];
            
        } else {
//            [NOVToast showFailToast:@"音视频提取成功"];
            [self saveTheExtractAudio:audioPath];
        }

    }];

}

//截取视频的背景音乐


- (void)videoToM4aWithVideoFilePath:(NSString *)filePath {
   
   NSLog(@"videoToM4aWithVideoFilePath filePath = %@",filePath);
    
    filePath = @"/var/mobile/Media/PhotoData/Metadata/DCIM/114APPLE/IMG_4524.medium.MP4";
   // 1. 获取音频源
   AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
   
   
   // 2. 创建一个音频会话, 并且,设置相应的配置
   AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
    self.session = session;
   session.outputFileType = AVFileTypeAppleM4A;
    
    session.outputURL = [NSURL URLWithString:[self buildFilePath]];
   NSString *outputPath = [self outputFilePathWithInputFilePath:filePath];
//   if (!outputPath) {
//       dispatch_async(dispatch_get_main_queue(), ^{
////           [self mbShowToast:@"转码失败~"];
//
//           NSLog(@"转码失败");
//           return;
//       });
//   }
//   if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
//       [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
//   }
    
//    NSString *audioPath = [self buildFilePath];
//   session.outputURL = [NSURL fileURLWithPath:audioPath];
   CMTime startTime = CMTimeMake(0, 1);
   CMTime endTime = CMTimeMake(asset.duration.value, 1);
    
    session.timeRange = CMTimeRangeMake(startTime, endTime);
//   session.timeRange = CMTimeRangeFromTimeToTime(startTime, endTime);
   // 3. 导出
//   NSString *relativePath = [NSString stringWithFormat:@"/VideoToM4a/%@",outputPath.lastPathComponent];
   [session exportAsynchronouslyWithCompletionHandler:^{
       AVAssetExportSessionStatus status = session.status;
       
       //        导出成功
       if (status == AVAssetExportSessionStatusCompleted) {
           
           NSLog(@"导出成功");
           
           [self playeWithAudioPath:outputPath];
           
           dispatch_async(dispatch_get_main_queue(), ^{
               [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
              
           });
       } else {
           //             导出失败
           dispatch_async(dispatch_get_main_queue(), ^{
               
               NSLog(@"导出失败");
           });
       }
   }];
}

- (NSString *)outputFilePathWithInputFilePath:(NSString *)inputFilePath {
   NSString *fileName = [[[inputFilePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"m4a"];
   NSString *outputFilePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
   outputFilePath = [outputFilePath stringByAppendingPathComponent:@"VideoToM4a"];
   NSFileManager *fileManager = [NSFileManager defaultManager];
   BOOL exists = [fileManager fileExistsAtPath:outputFilePath];
   if (exists) {
       return [outputFilePath stringByAppendingPathComponent:fileName];
   }
   BOOL createResult = [fileManager createDirectoryAtPath:outputFilePath withIntermediateDirectories:YES attributes:nil error:nil];
   if (createResult) {
       return [outputFilePath stringByAppendingPathComponent:fileName];
   }
   return nil;
}


- (void)saveTheExtractAudio : (NSString *)extractAuidoPath {
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *document=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *folder = [document stringByAppendingPathComponent:@"myMusic"];
    
    NSError *err ;
    
    if (![fileManager fileExistsAtPath:folder]) {
           [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&err];
       };

    NSString *tagertFilePath = [folder stringByAppendingString:[NSString stringWithFormat:@"/%f.m4a", [[NSDate date] timeIntervalSinceReferenceDate]]];
    
   
    NSError *testerr ;

    [fileManager moveItemAtPath:extractAuidoPath toPath:tagertFilePath error:&testerr];
    
//    [self navToCutAuidioViewController:[NSURL URLWithString:tagertFilePath]];
    
    NSLog(@"targetPath = %@",tagertFilePath);
        
    NSLog(@"提取音频 path = %@ ,err = %@",extractAuidoPath,err);
    
    
    [self playeWithAudioPath: tagertFilePath];
    
//    [self.dataArr removeAllObjects];
//    [self getFinalMusicCategoryMenuData];
}



- (NSString *)buildFilePath{
    
    return [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%f.m4a", [[NSDate date] timeIntervalSinceReferenceDate]]];
}


// 这里只是简单演示，只是为了验证 是否提取成功
- (void)playeWithAudioPath:(NSString *)path {
    

    NSURL *url = [NSURL fileURLWithPath:path];
    
    self.player = [AVPlayer playerWithURL:url];
    

    [self.player play];
}

//这里的音频提取是没有bug的，上面两个都有bug
- (void)extractAuidoWithVideoPath: (NSString *)videoPath{
    
    
    /*
    输出路径
    self.cachePath: 获取缓存路径
    */
    NSString *outPath = [self buildFilePath];
    // 创建组合文件
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    
//    NSString *video_path =  @"/var/mobile/Media/PhotoData/Metadata/DCIM/114APPLE/IMG_4524.medium.MP4";
    
//    NSString *video_path = @"/var/mobile/Media/PhotoData/Metadata/DCIM/114APPLE/IMG_4155.medium.MP4";
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    AVMutableCompositionTrack *comTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSError *error;
    [comTrack insertTimeRange:track.timeRange ofTrack:track atTime:kCMTimeZero error:&error];
    if (error) {
        NSLog(@"创建失败");
    }
    // 创建只包含原始文件的音频音轨
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetPassthrough];
    // 导出文件类型.m4a格式
    session.outputFileType = AVFileTypeAppleM4A;
    session.outputURL = [NSURL fileURLWithPath:outPath];
    // 音频导出
    [session exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = session.status;
        if(AVAssetExportSessionStatusCompleted == status) {
            
            [self playeWithAudioPath:outPath];
            NSLog(@"音频导出成功");
        } else {
            NSLog(@"音频导出失败");
        }
    }];
}
@end
