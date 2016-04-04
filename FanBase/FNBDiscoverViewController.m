//
//  ViewController.m
//  MariyaCollectionView
//
//  Created by Mariya Eggensperger on 4/1/16.
//  Copyright © 2016 Mariya Eggensperger. All rights reserved.
//

#import "FNBDiscoverViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FNBFirebaseClient.h"
#import <Firebase.h>
#import "CVCell.h"

@interface FNBDiscoverViewController ()

@property (nonatomic,strong) NSDictionary *artistData;
@property (nonatomic,strong) NSArray *popArtists;

@end

@implementation FNBDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [FNBFirebaseClient getDictionaryOfAllArtistsInDatabaseWithCompletionBlock:^(BOOL completed, NSDictionary *artistsDictionary) {
        if (completed) {
            self.artistData = artistsDictionary;
            
            self.popArtists = [self filterArtistsArray:artistsDictionary ByGenre:@"pop"];
            NSLog(@"popArtists: %@", self.popArtists);
            [self.collectionView reloadData];
        }

    }];
}
-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}
-(BOOL)prefersStatusBarHidden {
    
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    self.collectionView = nil;
    self.popArtists = nil;

}
#pragma mark collection view
//Format collection view
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.popArtists.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //Reuse identifier
    static NSString *reuseIdentifier = @"cvCell";
    
    CVCell *cell = (CVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    NSDictionary *artistsValues = self.popArtists[indexPath.row];
    NSString *nameForCell = artistsValues[@"name"];
    NSArray *imagesArray = artistsValues[@"images"];
    NSString *imageURL = imagesArray[0][@"url"];
    
    [cell.artistImageView setImageWithURL:[NSURL URLWithString:imageURL]];
    [cell.labelTitle setText:nameForCell];
    
    cell.clipsToBounds = YES;
    
    return cell;

}
- (NSArray *) filterArtistsArray:(NSDictionary *)artistDictionary ByGenre:(NSString *)genreInput {
    NSMutableArray *genreArray = [NSMutableArray new];
    for (NSString *artistName in artistDictionary) {
        NSDictionary *artistValues = [artistDictionary objectForKey:artistName];
        for (NSString *genre in artistValues[@"genres"]) {
            if ([genre containsString:genreInput]) {
                [genreArray addObject:artistValues];
                
                NSLog(@"%@", artistName);
                break;
            }
        }
    }
    return genreArray;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
