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
#define KVLatestVersion @"net.citigo.setting.app.version"
#define KVLatestVersionDetails @"net.citigo.setting.app.versionDetails"

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
    if ([KVUserDefault objectForKey:KVLatestVersion]) {
        self.storeVersion = [KVUserDefault objectForKey:KVLatestVersion];
    } else {
        self.storeVersion = @"";
    }
}

- (void)manualCheckVersion {
    KVVersionAlertType alertType = [self checkTypeAlertWithVersion:self.storeVersion];
    iVersion *versionManager = [iVersion sharedInstance];
    [versionManager checkForNewVersion];
}

#pragma mark show alert

- (KVVersionAlertType)checkTypeAlertWithVersion:(NSString *)versionString {
    KVVersionAlertType currentType = KVVersionAllertNone;
    //Check if current version is valid or not
    if (![self isValidVersionString:versionString]) {
        return KVVersionAllertNone;
    }
    
    NSString *lastChar = [versionString substringFromIndex:[versionString length] - 1];
    currentType = [lastChar integerValue];
    return currentType;
}

- (BOOL)isValidVersionString :(NSString *)version {
    NSArray<NSString *> *chars = [version componentsSeparatedByString:@"."];
    
    //Check if contain 3 number and 2 "." only
    if (chars.count != 3) {
        return NO;
    }
    
    //Check all string between "." is number
    for (NSString *stringNumber in chars) {
        if (![self isNumber:stringNumber]) {
            return NO;
        }
    }
    
    //Check if version number is between 1 and 3
    NSString *versionTypeString = [chars[2] substringFromIndex:chars[2].length - 1];
    NSNumberFormatter *formater = [[NSNumberFormatter alloc] init];
    formater.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSNumber *versionTypeNumber = [formater numberFromString:versionTypeString];
    if (versionTypeNumber.integerValue < 1 || versionTypeNumber.integerValue > 3) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isNumber:(NSString *)valueString {
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([valueString rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
        return YES;
    }
    return NO;
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
        msg = [NSString stringWithFormat:@"KiotViet vừa nâng cấp phiên bản %@ với những cải tiến đáng kể. Cập nhật và trải nghiệm ngay!", self.storeVersion];
    } else {
        msg = [NSString stringWithFormat:@"KiotViet vừa nâng cấp phiên bản %@ với những cải tiến đáng kể. %@", self.storeVersion,updateAlertShowed?@"":@" Chọn ""Cập nhật"" để tải về."];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cập nhật"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Để sau" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.shouldNotShowAlert = YES;
    }];
    
    UIAlertAction *updateAction = [UIAlertAction actionWithTitle:updateAlertShowed?@"Hướng dẫn cập nhật":@"Cập nhật"
                                                           style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                                                               
                                                               if (updateAlertShowed) {
                                                                   //Incase already showed update alert for user once
                                                                   if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectViewGuide)]) {
                                                                       [self.delegate didSelectViewGuide];
                                                                   }
                                                               } else {
                                                                   //First time show update alert
                                                                   [self openUpdatePage];
                                                                   self.shouldNotShowAlert = NO;
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
        self.shouldNotShowAlert = NO;
        /// Kiểm tra nếu đang hiện thị popup báo cập nhật thì không hiện nữa
        if (![topViewController.title isEqualToString:@"Cập nhật"]) {
            [topViewController presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)openUpdatePage {
    NSURL *updateURL = [[iVersion sharedInstance] updateURL];
    [[UIApplication sharedApplication] openURL:updateURL];
}

- (NSInteger)dayFrom:(NSDate *)startDate to:(NSDate *)endDate{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    return [components day];
}

#pragma mark - iVersion delegate

- (void)iVersionVersionCheckDidFailWithError:(NSError *)error {
    NSString *version = [KVUserDefault objectForKey:KVLatestVersion];
    [self showAlerIfNeedWithVersion:version];
}

- (void)showAlerIfNeedWithVersion:(NSString *)version {
    NSDate *date = [KVUserDefault objectForKey:version];
    if (!date) {
        date = [NSDate date];
        [KVUserDefault setObject:date forKey:version];
    }
    
    NSDate *currentDate = [NSDate date];
    NSInteger numberOfDay = [self dayFrom:date to:currentDate];
    if (numberOfDay >= self.numberOfDaysDelay) {
        //Show alert update to user
        [self showAlertToUser];
    }
}

- (void)iVersionDidDetectNewVersion:(NSString *)version details:(NSString *)versionDetails {
    self.storeVersion = version;
    [KVUserDefault setObject:self.storeVersion forKey:KVLatestVersion];
    [KVUserDefault setObject:versionDetails forKey:KVLatestVersionDetails];
    [KVUserDefault synchronize];
    [self showAlerIfNeedWithVersion:version];
}

- (BOOL)iVersionShouldDisplayNewVersion:(NSString *)version details:(NSString *)versionDetails {
    return NO;
}

- (BOOL)iVersionShouldDisplayCurrentVersionDetails:(NSString *)versionDetails {
    return NO;
}

@end
