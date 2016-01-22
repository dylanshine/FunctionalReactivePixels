//
//  FRPGalleryViewController.m
//  FRPixels
//
//  Created by Dylan Shine on 1/21/16.
//  Copyright © 2016 Fuzz Productions. All rights reserved.
//

#import "FRPGalleryViewController.h"
#import "FRPGalleryFlowLayout.h"
#import "FRPPhotoImporter.h"
#import "FRPCell.h"

@interface FRPGalleryViewController ()
@property (nonatomic, strong) NSArray *photosArray;
@end

static NSString *const CellIdentifier = @"Cell";

@implementation FRPGalleryViewController

- (instancetype)init {
	if (!(self = [self initWithCollectionViewLayout:[[FRPGalleryFlowLayout alloc] init]])) return nil;
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Popular on 500px";
	
	[self.collectionView registerClass:[FRPCell class] forCellWithReuseIdentifier:CellIdentifier];
	
	@weakify(self);
	[RACObserve(self, photosArray) subscribeNext:^(id x) {
		@strongify(self)
		[self.collectionView reloadData];
	}];
	
	[self loadPopularPhotos];
}

- (void)loadPopularPhotos {
	[[FRPPhotoImporter importPhotos] subscribeNext:^(id x) {
		self.photosArray =x ;
	} error:^(NSError *error) {
		NSLog(@"Couldn't fetch photos from 500px: %@", error);
	}];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	FRPCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
	
	[cell setPhotoModel: self.photosArray[indexPath.row]];
	
	return cell;
}

@end
