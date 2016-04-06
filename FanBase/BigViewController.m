//
//  BigViewController.m
//  FanBase
//
//  Created by Mariya Eggensperger on 4/5/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

#import "BigViewController.h"
#import "GenreCollectionView.h"
#import "CVCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FNBFirebaseClient.h"
#import <Firebase.h>


@interface BigViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;

@property (nonatomic, strong) NSArray *genreNames;
@property (nonatomic, strong) NSDictionary *artistsByGenre;
@property (nonatomic, strong) NSMutableDictionary *genreArtists;

@end

@implementation BigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _genreArtists = [NSMutableDictionary new];
    
    // Do any additional setup after loading the view from its nib.
    [FNBFirebaseClient getDictionaryOfAllArtistsInDatabaseWithCompletionBlock:^(BOOL completed, NSDictionary *artistsDictionary) {
        if (completed) {
            //self.artistData = artistsDictionary;
            self.artistsByGenre = artistsDictionary;
            
            for (NSString *artistName in artistsDictionary) {
                NSDictionary *valueForArtistName = artistsDictionary[artistName];
                
                NSArray *genres = valueForArtistName[@"genres"];
                
                    for (NSString *genre in genres) {
                        
                        if (self.genreArtists[genre]) {
                            NSMutableArray *genresInDict = self.genreArtists[genre];
                            [genresInDict addObject:artistName];
                            
                        } else {
                            NSMutableArray *genresFirstTimeThrough = [NSMutableArray new];
                            [genresFirstTimeThrough addObject:artistName];
                            self.genreArtists[genre] = genresFirstTimeThrough;
                        }
                    }
                
            }
            
            for (NSString *key in self.genreArtists) {
                NSArray *artists = self.genreArtists[key];
                
                if (artists.count > 10) {
                    NSLog(@"Genre: %@, Artists: %@", key, artists);
                }
            }
            
            
            
            //self.popArtists = [self filterArtistsArray:artistsDictionary ByGenre:@"pop"];
            self.genreNames = [self filterArtistsArray:artistsDictionary ByGenre:@"pop"];
            //NSLog(@"popArtists: %@", self.popArtists);
            NSLog(@"pop artists: %@", self.genreNames);
            //[self.traitCollection reloadData];
        }
        
    }];

    
    //self.genreNames = @[ @"pop", @"hip-hop", @"country",
//                         @"EDM/Dance", @"RnB", @"indie",
//                         @"rock", @"latino", @"fresh finds",
//                         @"soul", @"folk & american", @"jazz",
//                         @"classical", @"comedy", @"metal",@"k-pop",
//                         @"reggae",@"punk", @"funk", @"blues"];
//    
    //self.artistsByGenre = @{@"pop":@"BritneySpry"};
    
    for(NSString *genre in self.genreNames) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(200, 200);
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        
        
        GenreCollectionView *cv = [[GenreCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        
        [cv registerNib:[UINib nibWithNibName:@"DiscoverCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cvCell"];
        
        cv.genre = genre;
        cv.delegate = self;
        cv.dataSource = self;
        
        [self.stackView addArrangedSubview:cv];
        
        [cv.heightAnchor constraintEqualToConstant:200].active = YES;
        [cv.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(GenreCollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(GenreCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //return self.artistsByGenre.count;
    return self.genreNames.count;

}

-(UICollectionViewCell *)collectionView:(GenreCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //Reuse identifier
    static NSString *reuseIdentifier = @"cvCell";
    
    NSArray *artists = self.artistsByGenre[collectionView.genre];
    
    CVCell *cell = (CVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    //NSString *artistsValues = self.genreNames[indexPath.row];
    //NSString *nameForCell = artistsValues;
    NSString *artist = artists[indexPath.row];
    NSArray *imagesArray = self.artistsByGenre[artist][@"images"];
    NSString *imageURL = imagesArray[0][@"url"];
    
    [cell.artistImageView setImageWithURL:[NSURL URLWithString:imageURL]];
    [cell.labelTitle setText:artists[indexPath.row]];
    
    cell.clipsToBounds = YES;
    
    return cell;
    
}
- (NSArray *)filterArtistsArray:(NSDictionary *)artistDictionary ByGenre:(NSString *)genreInput {
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


@end
