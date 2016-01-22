//
//  FRPGalleryFlowLayout.m
//  FRPixels
//
//  Created by Dylan Shine on 1/21/16.
//  Copyright © 2016 Fuzz Productions. All rights reserved.
//

#import "FRPGalleryFlowLayout.h"

@implementation FRPGalleryFlowLayout

- (instancetype)init {
	if (self = [super  init]) {
		self.itemSize = CGSizeMake(145, 145);
		self.minimumLineSpacing = 10;
		self.minimumLineSpacing = 10;
		self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
	}
	return self;
}

@end
