//
//  KVVersionManager.m
//  KVManager
//
//  Created by citigo on 4/12/17.
//  Copyright © 2017 Citigo. All rights reserved.
//

#import <iVersion/iVersion.h>

#import "KVVersionManager.h"

#define KVUserDefault [[NSUserDefaults alloc] initWithSuiteName:@"group.net.citigo.kvmanager"]
typedef NS_ENUM(NSInteger,KVVersionAlertType) {
    KVVersionAllertNone      = 1,
    KVVersionAlertOption     = 2,
    KVVersionAlertForce      = 3,
};

@interface KVVersionManager()<iVersionDelegate>
@property (strong,nonatomic) NSString *storeVersion;
@end


@implementation KVVersionManager

+ (KVVersionManager *)sharedInstance {
    static KVVersionManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)startManageVersion {
    iVersion *versionManager = [iVersion sharedInstance];
    versionManager.delegate = self;
    self.storeVersion = @"";
}

- (void)manualCheckVersion {
    iVersion *versionManager = [iVersion sharedInstance];
    [versionManager checkForNewVersion];
}

#pragma mark show alert
- (KVVersionAlertType)checkTypeAlertWithVersion:(NSString *)versionString {
    KVVersionAlertType currentType = KVVersionAllertNone;
    NSString *lastChar = [versionString substringFromIndex:[versionString length] - 1];
    currentType = [lastChar integerValue];
    return currentType;
}

- (void)showAlertToUser {
    KVVersionAlertType alertType = [self checkTypeAlertWithVersion:self.storeVersion];
    switch (alertType) {
        case KVVersionAllertNone:
            [self showAlertWithTypeNone];
            break;
        case KVVersionAlertOption:
            [self showAlertWithTypeOption];
            break;
        case KVVersionAlertForce:
            [self showAlertWithTypeForce];
            break;
            
        default:
            break;
    }
}

- (void)showAlertWithTypeNone {
}

- (void)showAlertWithTypeOption {
   [self showAlertWithOption:YES];
}

- (void)showAlertWithTypeForce {
    [self showAlertWithOption:NO];
}

- (void)showAlertWithOption:(BOOL)shouldShowOption {
    //Check if update alert is already showed once
    BOOL updateAlertShowed = [[KVUserDefault objectForKey:@"UpdateAlertShowed"] boolValue];
    if (!updateAlertShowed) {
        [KVUserDefault setObject:@(YES) forKey:@"UpdateAlertShowed"];
    }
    NSString *msg;
    if (shouldShowOption) {
        msg = [NSString stringWithFormat:@"Chúng tôi vừa cập nhật phiên bản %@ với nhiều cải tiến. Bạn có muốn tải về không?", self.storeVersion];
    } else {
        msg = [NSString stringWithFormat:@"Chúng tôi vừa cập nhật phiên bản %@ với nhiều cải tiến. %@", self.storeVersion,updateAlertShowed?@"":@" Chọn ""Cập nhật"" để tải về."];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cập nhật"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Không" style:UIAlertActionStyleCancel handler:NULL];
    
    UIAlertAction *updateAction = [UIAlertAction actionWithTitle:updateAlertShowed?@"Hướng dẫn cập nhật":@"Cập nhật" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        if (updateAlertShowed) {
            //Incase already showed update alert for user once
            if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectViewGuide)]) {
                [self.delegate didSelectViewGuide];
            }
        } else {
            //First time show update alert
            [self openUpdatePage];
        }
        
    }];
    
    
    if (shouldShowOption) {
        [alert addAction:cancelAction];
    }
    [alert addAction:updateAction];

    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    if (!self.shouldNotShowAlert) {
        [topViewController presentViewController:alert animated:YES completion:nil];
    }
}

- (void)openUpdatePage {
    NSURL *updateURL = [[iVersion sharedInstance] updateURL];
    [[UIApplication sharedApplication] openURL:updateURL];
}

- (NSInteger)dayFrom:(NSDate *)startDate to :(NSDate *)endDate{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    return [components day];
}

#pragma mark - iVersion delegate

- (void)iVersionDidDetectNewVersion:(NSString *)version details:(NSString *)versionDetails {
    self.storeVersion = version;
    NSDate *date = [KVUserDefault objectForKey:version];
    if (!date) {
        [KVUserDefault setObject:[NSDate date] forKey:version];
        return;
    }
    
    NSDate *currentDate = [NSDate date];
    NSInteger numberOfDay = [self dayFrom:date to:currentDate]; //[currentDate daysFrom:date];
    if (numberOfDay >= self.numberOfDaysDelay) {
        //Show alert update to user
        [self showAlertToUser];
    }
}

- (BOOL)iVersionShouldDisplayNewVersion:(NSString *)version details:(NSString *)versionDetails {
    return NO;
}

- (BOOL)iVersionShouldDisplayCurrentVersionDetails:(NSString *)versionDetails {
    return NO;
}

@end