//
//  FRPPhotoImporter.h
//  FRPixels
//
//  Created by Dylan Shine on 1/21/16.
//  Copyright © 2016 Fuzz Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRPPhotoImporter : NSObject

+ (RACSignal *)importPhotos;

@end
