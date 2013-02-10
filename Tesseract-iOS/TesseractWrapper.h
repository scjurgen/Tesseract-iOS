//
//  TesseractWrapper.h
//  tesseract-try
//
//  Created by Jürgen Schwietering on 2/9/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TesseractWrapper : NSObject

- (id)initEngineWithLanguage:(NSString*)language;
- (NSString*)analyseImage:(UIImage *)image;

@end
