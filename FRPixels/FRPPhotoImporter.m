//
//  FRPPhotoImporter.m
//  FRPixels
//
//  Created by Dylan Shine on 1/21/16.
//  Copyright © 2016 Fuzz Productions. All rights reserved.
//

#import "FRPPhotoImporter.h"
#import "FRPPhotoModel.h"

@implementation FRPPhotoImporter

+ (RACSignal *)requestPhotoData {
	return [[NSURLConnection rac_sendAsynchronousRequest:[self popularURLRequest]] reduceEach:^id(NSURLResponse *response, NSData *data) {
		return data;
	}];
}

+ (RACSignal *)importPhotos {
	
	return [[[[[self requestPhotoData] deliverOn:[RACScheduler mainThreadScheduler]] map:^id(NSData *data) {
		NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		
		return [[[resultsDict[@"photos"] rac_sequence] map:^id(NSDictionary *photoDictionary) {
			FRPPhotoModel *model = [FRPPhotoModel new];
			[self configurePhotoModel:model withDictionary:photoDictionary];
			[self downloadThumbnailForPhotoModel:model];
			return model;
		}] array];
		
	}] publish] autoconnect];
	
}

+(NSURLRequest *)popularURLRequest {
	return [[PXRequest apiHelper] urlRequestForPhotoFeature:PXAPIHelperPhotoFeaturePopular
											 resultsPerPage:100
													   page:0
												 photoSizes:PXPhotoModelSizeThumbnail
												  sortOrder:PXAPIHelperSortOrderRating
													 except:PXPhotoModelCategoryNude];
}

+ (void)configurePhotoModel:(FRPPhotoModel *)photoModel withDictionary:(NSDictionary *)dict {
	photoModel.photoName = dict[@"name"];
	photoModel.identifier = dict[@"id"];
	photoModel.photographerName = dict[@"user"][@"username"];
	photoModel.rating = dict[@"rating"];
	
	photoModel.thumbnailURL = [self urlForImageSize:3 inDictionary:dict[@"images"]];
	
	if (dict[@"voted"]) {
		photoModel.votedFor = [dict[@"voted"] boolValue];
	}
	
	// Extended attributes fetched with subsequent request
	if (dict[@"comments_count"]) {
		photoModel.fullsizedURL = [self urlForImageSize:4 inDictionary:dict[@"images"]];
	}
}

+(NSString *)urlForImageSize:(NSInteger)size inDictionary:(NSArray *)array {
	return [[[[[array rac_sequence] filter:^BOOL(NSDictionary *value) {
		return [value[@"size"] integerValue] == size;
	}] map:^id(id value) {
		return value[@"url"];
	}] array] firstObject];
}

+(RACSignal *)download:(NSString *)urlString {
	NSAssert(urlString, @"URL must not be nil");
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	
	return [[[NSURLConnection rac_sendAsynchronousRequest:request] reduceEach:^id(NSURLResponse *response, NSData *data){
		return data;
	}] deliverOn:[RACScheduler mainThreadScheduler]];
}

+(void)downloadThumbnailForPhotoModel:(FRPPhotoModel *)photoModel {
	RAC(photoModel, thumbnailData) = [self download:photoModel.thumbnailURL];
}

@end
