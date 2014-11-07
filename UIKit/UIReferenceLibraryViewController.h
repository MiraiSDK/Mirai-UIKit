//
//  UIReferenceLibraryViewController.h
//  UIKit
//
//  Created by Chen Yonghui on 11/7/14.
//  Copyright (c) 2014 Shanghai Tinynetwork Inc. All rights reserved.
//

#import <UIKit/UIViewController.h>

@interface UIReferenceLibraryViewController : UIViewController
+ (BOOL)dictionaryHasDefinitionForTerm:(NSString *)term;

- (instancetype)initWithTerm:(NSString *)term;
@end
