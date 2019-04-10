//
//  KVVersionManager.h
//  KVVersionManager
//
//  Created by Tran Manh Tuan on 4/10/19.
//  Copyright © 2019 Citigo. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for KVVersionManager.
FOUNDATION_EXPORT double KVVersionManagerVersionNumber;

//! Project version string for KVVersionManager.
FOUNDATION_EXPORT const unsigned char KVVersionManagerVersionString[];

@protocol KVVersionManagerDelegate <NSObject>

- (void)didSelectViewGuide;

@end

@interface KVVersionManager : NSObject

@property (weak,nonatomic) id<KVVersionManagerDelegate> delegate;
@property (assign,nonatomic) NSInteger numberOfDaysDelay;
@property (assign,nonatomic) BOOL shouldNotShowAlert;

+ (KVVersionManager *)sharedInstance;
- (void)startManageVersion;
- (void)manualCheckVersion;
- (void)openUpdatePage;

@end
