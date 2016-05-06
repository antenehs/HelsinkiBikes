//
//  LabelWithBackground.m
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 5/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "LabelWithBackground.h"

@implementation LabelWithBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

#pragma mark - Instance methods

- (UIEdgeInsets)titleEdgeInsets
{
    return UIEdgeInsetsMake(3.f,
                            5.f,
                            3.f,
                            5.f);
}

- (CGSize)intrinsicContentSize
{
    CGSize s = [super intrinsicContentSize];
    
    return CGSizeMake(s.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
                      s.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
    
}

#pragma mark - Private instance methods

- (void)setup
{
    self.layer.cornerRadius = 4.f;
    self.layer.masksToBounds = YES;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor lightGrayColor];
    self.textColor = [UIColor whiteColor];
}

@end
