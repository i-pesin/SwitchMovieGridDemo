//
//  MovieImageDownloader.h
//  SwitchMovieGridDemo
//
//  Created by Igor Pesin on 6/21/15.
//  Copyright (c) 2015 Igor Pesin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MovieImagesSource : NSObject

+ (instancetype)sharedImageSource;
- (NSUInteger)imagesCount;
- (UIImage *)imageAtIndex:(NSUInteger)index;
- (void)downloadImageAtIndex:(NSUInteger)index completion:(void(^)(UIImage *image))completion;

@end
