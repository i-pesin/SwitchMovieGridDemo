//
//  MovieImageDownloader.m
//  SwitchMovieGridDemo
//
//  Created by Igor Pesin on 6/21/15.
//  Copyright (c) 2015 Igor Pesin. All rights reserved.
//

#import "MovieImagesSource.h"
#import "MoviesPlistParser.h"

static NSArray *imagesURL;

NSString *kNewBatchOfImagesReadyToDownload = @"kNewBatchOfImagesReadyToDownload";

@interface MovieImagesSource()<NSXMLParserDelegate>
@property (nonatomic, strong) NSCache *imagesCache;
@property (nonatomic, assign) NSUInteger numberOfRequestedImages;
@property (nonatomic, strong) NSMutableSet *urlsOfDownloadingImages;
@property (nonatomic, assign) BOOL shouldNotifyWhenNewImagesAreReadyToDownload;
@end

@implementation MovieImagesSource

+ (instancetype)sharedImageSource {
    static dispatch_once_t once;
    static id sharedImageSource;
    dispatch_once(&once, ^{
        sharedImageSource = [[self alloc] init];
    });
    return sharedImageSource;
}


+ (void)initialize {
    imagesURL = [MoviesPlistParser moviesURL];
}

- (id)init {
    if (self = [super init]) {
        _imagesCache = [NSCache new];
        _hasMoreImagesToDownload = YES;
        _urlsOfDownloadingImages = [NSMutableSet set];
    }
    
    return self;
}

- (void)setBatchSize:(NSUInteger)batchSize {
    _batchSize = batchSize;
    _numberOfRequestedImages = batchSize;
}

- (NSUInteger)imagesCount {
    return self.numberOfRequestedImages;
}

- (UIImage *)imageAtIndex:(NSUInteger)index {
    if (index >= imagesURL.count) {
        return nil;
    }
    
    NSString *imageURLString = imagesURL[index];
    
    return [self.imagesCache objectForKey:imageURLString];
}

- (void)downloadImageAtIndex:(NSUInteger)index completion:(void(^)(UIImage *image))completion {
    if (index >= imagesURL.count) {
        completion(nil);
    }
    
    if (index == imagesURL.count - 1) {
        _hasMoreImagesToDownload = NO;
    }
    
    NSString *imageURLString = imagesURL[index];
    
    if ([self.urlsOfDownloadingImages containsObject:imageURLString]) {
        return;
    }
    
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    
    [self.urlsOfDownloadingImages addObject:imageURLString];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            UIImage *downloadedImage = [UIImage imageWithData:data];
            
            if (downloadedImage) {
                [self.imagesCache setObject:downloadedImage forKey:imageURLString];
            }
            
            if ((self.urlsOfDownloadingImages.count <= self.batchSize - 1) && self.shouldNotifyWhenNewImagesAreReadyToDownload) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNewBatchOfImagesReadyToDownload object:nil];
                self.shouldNotifyWhenNewImagesAreReadyToDownload = NO;
            }
            
            completion(downloadedImage);
        }
        else {
            completion(nil);
        }
        
        [self.urlsOfDownloadingImages removeObject:imageURLString];
    }];
}

- (BOOL)requestToDownloadNewBatchOfImages {
    BOOL readyToLoadMoreImages = self.urlsOfDownloadingImages.count < self.batchSize;
    if (readyToLoadMoreImages) {
        self.numberOfRequestedImages += MIN(imagesURL.count - self.numberOfRequestedImages, self.batchSize);
    }
    else {
        self.shouldNotifyWhenNewImagesAreReadyToDownload = YES;
    }
    
    return readyToLoadMoreImages;
}

@end
