//
//  MovieImageDownloader.m
//  SwitchMovieGridDemo
//
//  Created by Igor Pesin on 6/21/15.
//  Copyright (c) 2015 Igor Pesin. All rights reserved.
//

#import "MovieImagesSource.h"

static NSArray *imagesURL;

@interface MovieImagesSource()
@property (nonatomic, strong) NSCache *imagesCache;
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
    NSString *plistFilePath = [[NSBundle mainBundle] pathForResource:@"nyt_movie_data" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    
    NSMutableArray *tempURLArray = [NSMutableArray arrayWithCapacity:dict.count];
    __weak typeof (dict) weakDict = dict;
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [tempURLArray addObject:weakDict[key]];
    }];
    
    imagesURL = [NSArray arrayWithArray:tempURLArray];
}

- (id)init {
    if (self = [super init]) {
        _imagesCache = [NSCache new];
    }
    
    return self;
}

- (NSUInteger)imagesCount {
    return imagesURL.count;
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
    
    NSString *imageURLString = imagesURL[index];
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:imageURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            UIImage *downloadedImage = [UIImage imageWithData:data];
            
            if (downloadedImage) {
                [self.imagesCache setObject:downloadedImage forKey:imageURLString];
            }
            
            completion(downloadedImage);
        }
    }];
}

@end
