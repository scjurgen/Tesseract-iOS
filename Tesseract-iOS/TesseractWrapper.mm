//
//  TesseractWrapper.m
//  tesseract-try
//
//  Created by Jürgen Schwietering on 2/9/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import "TesseractWrapper.h"
#include "baseapi.h"
#include "environ.h"


@interface TesseractWrapper()
{
    tesseract::TessBaseAPI *tesseract;
}
@end

@implementation TesseractWrapper

-(id)initEngineWithLanguage:(NSString*)language
{
    self=[super self];
    if (self)
    {
        // copy bundle data
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = ([documentPaths count] > 0) ? [documentPaths objectAtIndex:0] : nil;
        
        NSString *dataPath = [documentPath stringByAppendingPathComponent:@"tessdata"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // If the expected store doesn't exist, copy the default store.
        if (![fileManager fileExistsAtPath:dataPath]) {
            // get the path to the app bundle (with the tessdata dir)
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            NSString *tessdataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
            if (tessdataPath) {
                NSError *error;
                [fileManager copyItemAtPath:tessdataPath toPath:dataPath error:&error];
                NSLog(@"%@",error);
            }
        }
        
        setenv("TESSDATA_PREFIX", [[documentPath stringByAppendingString:@"/"] UTF8String], 1);
        
        // init the tesseract engine.
        tesseract = new tesseract::TessBaseAPI();
        int initRet=tesseract->Init([dataPath cStringUsingEncoding:NSUTF8StringEncoding], [language UTF8String]);
        NSLog(@"init returns: %d",initRet);
    }
    return self;
}


- (NSString*)analyseImage:(UIImage *)image
{
    @synchronized(self)
    {
        CGSize size = [image size];
        int width = size.width;
        int baseWidth=width* sizeof(uint32_t);
        int height = size.height;
        
        if (width <= 0 || height <= 0)
            return nil;
        
        uint32_t *pixels = (uint32_t *) malloc(baseWidth * height);
        memset(pixels, 0, baseWidth * height); // alpha will be deleted too, this is needed if transparent png used
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, baseWidth, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        
        tesseract->SetImage((const unsigned char *) pixels, width, height, sizeof(uint32_t), baseWidth);
        
        tesseract->Recognize(NULL);
        const char *utf8Text = tesseract->GetUTF8Text();
        
        free(pixels);
        
        if (utf8Text)
        {
            NSLog(@"T=[%s]",utf8Text);
            return [NSString stringWithUTF8String:utf8Text];
        }
        
        return nil;
    }
}



@end
