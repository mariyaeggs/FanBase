//
//  FNBInstagramCollectionViewController.m
//  FanBase
//
//  Created by Angelica Bato on 3/31/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "FNBInstagramCollectionViewController.h"
#import "FNBInstagramAPIClient.h"

@interface FNBInstagramCollectionViewController ()

@property (strong, nonatomic) NSArray *instagramPosts;

@end

@implementation FNBInstagramCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

# pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [FNBInstagramAPIClient generateInstagramPostsByKeyword:@"nofilter" completion:^(NSDictionary *returnDictionary) {
//        self.instagramPosts = returnedArray;
        
        NSLog(@"Have the array!");
        NSLog(@"%@",returnDictionary[@"data"]);
        
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            [self.collectionView reloadData];
//        }];
    }];
    
//    [FNBInstagramAPIClient generateInstagramPostsByUser:@"adele" completion:^(NSDictionary *returnedDictionary) {
//        NSLog(@"%@",returnedDictionary);
//    }];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
}

# pragma mark - Delegate Methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.instagramPosts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"instagramPost" forIndexPath:indexPath];
    
    UIImage *currentIGPost = self.instagramPosts[indexPath.row];
    cell.backgroundColor = [UIColor grayColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [self viewWidth]*0.5, [self viewWidth]*0.5)];
    imageView.image = currentIGPost;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell.contentView addSubview:imageView];
    
    return cell;
}

- (CGFloat) viewWidth {
    return self.collectionView.bounds.size.width;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([self viewWidth]*0.5, [self viewWidth]*0.5);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark <UICollectionViewDelegate>


// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


@end
