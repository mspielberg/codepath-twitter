//
//  LimitedWidthTextField.m
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/19/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "LimitedWidthTextField.h"

@implementation LimitedWidthTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect textRect = [super textRectForBounds:bounds];
    return CGRectMake(CGRectGetMinX(textRect),
                      CGRectGetMinY(textRect),
                      CGRectGetWidth(textRect) - self.rightInset,
                      CGRectGetHeight(textRect));
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect editingRect = [super editingRectForBounds:bounds];
    return CGRectMake(CGRectGetMinX(editingRect),
                      CGRectGetMinY(editingRect),
                      CGRectGetWidth(editingRect) - self.rightInset,
                      CGRectGetHeight(editingRect));
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
