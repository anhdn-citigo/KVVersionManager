//
//  KVVersionManager.h
//  KVManager
//
//  Created by citigo on 4/12/17.
//  Copyright © 2017 Citigo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KVVersionManagerDelegate <NSObject>

- (void)didSelectViewGuide;

@end

@interface KVVersionManager : NSObject
+ (KVVersionManager *)sharedInstance;
@property (weak,nonatomic) id<KVVersionManagerDelegate> delegate;
@property (assign,nonatomic) NSInteger numberOfDaysDelay;
@property (assign,nonatomic) BOOL shouldNotShowAlert;
@property (assign,nonatomic) NSString *currentAppVersion;

- (void)startManageVersion;
- (void)manualCheckVersion;
- (void)openUpdatePage;
@end
