//
//  ViewController.m
//  SwitchMovieGridDemo
//
//  Created by Igor Pesin on 6/20/15.
//  Copyright (c) 2015 Igor Pesin. All rights reserved.
//

#import "ViewController.h"
#import "MovieCollectionViewCell.h"
#import "MovieImagesSource.h"

static NSString * const kMovieCellReuseId = @"movieCellReuseId";
static CGFloat itemSpacing;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[MovieCollectionViewCell class] forCellWithReuseIdentifier:kMovieCellReuseId];
    self.collectionView.dataSource = self;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationItem.title = @"MOVIES";
    self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self calculateItemSpacing];
}

- (void)calculateItemSpacing {
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    CGFloat itemWidth = flowLayout.itemSize.width;
    
    NSUInteger itemsPerRow = truncf(screenWidth / itemWidth);
    itemSpacing = (screenWidth - itemWidth * itemsPerRow) / (itemsPerRow + 1);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [MovieImagesSource sharedImageSource].imagesCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionViewCell *cell = (MovieCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kMovieCellReuseId forIndexPath:indexPath];
    
    UIImage *movieImage = [[MovieImagesSource sharedImageSource] imageAtIndex:indexPath.row];
    cell.movieImage = movieImage;
    
    if (!movieImage) {
        [self downloadImageAtIndexPath:indexPath];
    }
    
    return cell;
}

- (void)downloadImageAtIndexPath:(NSIndexPath *)indexPath {
    [[MovieImagesSource sharedImageSource] downloadImageAtIndex:indexPath.row completion:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        });
    }];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return itemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return itemSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(itemSpacing, itemSpacing, itemSpacing, itemSpacing);
}

@end
