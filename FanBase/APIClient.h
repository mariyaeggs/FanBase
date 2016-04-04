//
//  APIClient.h
//  MariyaCollectionView
//
//  Created by Mariya Eggensperger on 4/4/16.
//  Copyright © 2016 Mariya Eggensperger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APIClient : NSObject

+ (void)downloadImageAtUrl:(NSURL *)url
            withCompletion:(void (^)(UIImage *image, BOOL success))block;


@end
