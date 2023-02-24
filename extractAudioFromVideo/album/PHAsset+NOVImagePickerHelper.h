//
//  PHAsset+NOVImagePickerHelper.h
//  shortVideoEditor
//
//  Created by 左衡 on 2019/5/31.
//  Copyright © 2019 hali. All rights reserved.
//
#import <Photos/Photos.h>

@interface PHAsset (NOVImagePickerHelper)

- (NSURL *)movieURL;

- (UIImage *)imageURL:(PHAsset *)phAsset targetSize:(CGSize)targetSize;

- (NSURL *)getImageURL:(PHAsset *)phAsset;

- (NSData *)getImageData:(PHAsset *)phAsset;

@end

