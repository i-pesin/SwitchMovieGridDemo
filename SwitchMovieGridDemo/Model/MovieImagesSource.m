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

@interface MovieImagesSource()
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
    /*
     According to the task images have to be loaded in the same order that they appear in the plist file.
     Plist file consists of dictionary that is deserialized into NSDictionary. NSDictionary is not ordered by definition so it's impossible to get the image URLs in initial order. The only option I've found to
     achieve it is to parse plist file like XML. That is done in MoviesPlistParser class.
     */
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
    
    /*
        check if image was already downloaded and cached
     */
    if ([self.urlsOfDownloadingImages containsObject:imageURLString]) {
        return;
    }
    
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    //specially disable cache for testing
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    
    /*
     in order not to start the same download multiple times
     need to store URL of the image which download task is currently in progress
     */
    [self.urlsOfDownloadingImages addObject:imageURLString];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            UIImage *downloadedImage = [UIImage imageWithData:data];
            
            if (downloadedImage) {
                /*
                    cache downloaded image
                 */
                [self.imagesCache setObject:downloadedImage forKey:imageURLString];
            }
            
            /*
             Check if caller should be notified when ready to download new images and if it's actually possible. Notify if it's true.
             */
            if (self.shouldNotifyWhenNewImagesAreReadyToDownload && (self.urlsOfDownloadingImages.count <= self.batchSize - 1)) {
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
