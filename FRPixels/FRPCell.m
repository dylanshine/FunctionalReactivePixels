//
//  FRPCellCollectionViewCell.m
//  FRPixels
//
//  Created by Dylan Shine on 1/21/16.
//  Copyright © 2016 Fuzz Productions. All rights reserved.
//

#import "FRPCell.h"
#import "FRPPhotoModel.h"
#import "NSData+AFDecompression.h"

@interface FRPCell ()

@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation FRPCell

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (!self) return nil;
	
	// Configure self
	self.backgroundColor = [UIColor darkGrayColor];
	
	// Configure subivews
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
	imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.contentView addSubview:imageView];
	self.imageView = imageView;
	
	RAC(self.imageView, image) = [[[RACObserve(self, photoModel.thumbnailData) ignore:nil] map:^id(id value) {
		return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
			[value af_decompressedImageFromJPEGDataWithCallback:
			 ^(UIImage *decompressedImage) {
				 [subscriber sendNext:decompressedImage];
				 [subscriber sendCompleted];
			 }];
			return nil;
		}] subscribeOn:[RACScheduler scheduler]];
	}] switchToLatest];
	
	[self.rac_prepareForReuseSignal subscribeNext:^(id x) {
		self.imageView.image = nil;
	}];
	
	return self;
}

@end
