//
//  DetailViewController.m
//  Tesseract-iOS
//
//  Created by jay on 2/10/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import "DetailViewController.h"
#import "TesseractWrapper.h"

@interface DetailViewController ()
{
    TesseractWrapper *tesseract;

}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    if (self.resultTextView)
    {
        self.resultTextView.text = @"analysis...";
        UIImage *image=[UIImage imageNamed:[[self.detailItem valueForKey:@"name"] description]];
        self.imageSampleView.image = image;
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        
        dispatch_async(queue, ^{
            NSString *result = [tesseract analyseImage:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultTextView.text = result;
            });
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tesseract = [[TesseractWrapper alloc] initEngineWithLanguage:@"eng"];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
