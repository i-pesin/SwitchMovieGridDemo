//
//  MovieImageDownloader.h
//  SwitchMovieGridDemo
//
//  Created by Igor Pesin on 6/21/15.
//  Copyright (c) 2015 Igor Pesin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *kNewBatchOfImagesReadyToDownload;

@interface MovieImagesSource : NSObject

@property (nonatomic, assign, readonly) BOOL hasMoreImagesToDownload;
/*
 max number of images to download simultaneously
 */
@property (nonatomic, assign) NSUInteger batchSize;

+ (instancetype)sharedImageSource;
- (NSUInteger)imagesCount;
- (UIImage *)imageAtIndex:(NSUInteger)index;
- (void)downloadImageAtIndex:(NSUInteger)index completion:(void(^)(UIImage *image))completion;

/*
 Check if amount of images that are currently being downloaded is less than batch size.
 If it is - increase an amount of displayed images by batch size.
 If it isn't - set the flag to notify the caller when this amount is less than batch size
 */
- (BOOL)requestToDownloadNewBatchOfImages;

@end
