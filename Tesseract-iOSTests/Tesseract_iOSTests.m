//
//  Tesseract_iOSTests.m
//  Tesseract-iOSTests
//
//  Created by jay on 2/10/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import "Tesseract_iOSTests.h"
#import "TesseractWrapper.h"

@interface Tesseract_iOSTests()
{
    TesseractWrapper *tesseract;
}
 
@end

@implementation Tesseract_iOSTests

- (void)setUp
{
    [super setUp];
    tesseract = [[TesseractWrapper alloc] initEngineWithLanguage:@"eng"];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)runSingleImage:(NSString*)expected imageName:(NSString*)imageName
{
    UIImage *image=[UIImage imageNamed:imageName];
    NSString *result=[tesseract analyseImage:image];
    expected = [expected stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    STAssertEqualObjects(result,expected,@"Error transforming using image %@", imageName);
}

- (void)testSimpleImages
{
    [self runSingleImage:@"Hola caracola!" imageName:@"HolaCaracola.tiff"];
    [self runSingleImage:@"Hola caracola!" imageName:@"HolaCaracola2.tiff"];
    [self runSingleImage:@"Hola caracola!" imageName:@"HolaCaracola3.tiff"];
    [self runSingleImage:@"gjpqy_" imageName:@"gjpqy_.tiff"];
    [self runSingleImage:@"gjpqy_" imageName:@"gjpqy_2.tiff"];
}

@end
