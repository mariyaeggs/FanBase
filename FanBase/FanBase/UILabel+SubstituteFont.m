//
//  UILabel+SubstituteFont.m
//  LazyProgrammersGuideToDecentUI
//
//  Created by Timothy Clem on 4/12/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#import "UILabel+SubstituteFont.h"

@implementation UILabel (SubstituteFont)

-(void)setFis_substituteFontName:(NSString *)fis_substituteFontName
{
    self.font = [UIFont fontWithName:fis_substituteFontName size:self.font.pointSize];
}

-(NSString *)fis_substituteFontName
{
    return nil;
}

@end
