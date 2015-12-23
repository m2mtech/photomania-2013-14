//
//  URLViewController.m
//  Photomania
//
//  Created by Martin Mandl on 08.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "URLViewController.h"

@interface URLViewController ()

@property (weak, nonatomic) IBOutlet UITextView *urlTextView;

@end

@implementation URLViewController

- (void)setUrl:(NSURL *)url
{
    _url = url;
    [self updateUI];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
}

- (void)updateUI
{
    self.urlTextView.text = [self.url absoluteString];
}


@end
