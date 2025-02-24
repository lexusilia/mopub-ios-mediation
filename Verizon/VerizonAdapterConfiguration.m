#import <VerizonAdsStandardEdition/VerizonAdsStandardEdition.h>
#import <VerizonAdsCore/VerizonAdsCore.h>
#import "VerizonAdapterConfiguration.h"

NSString * const kMoPubVASAdapterVersion = @"1.2.1.1";

NSString * const kMoPubVASAdapterErrorWho = @"MoPubVASAdapter";
NSString * const kMoPubVASAdapterPlacementId = @"placementId";
NSString * const kMoPubVASAdapterSiteId = @"siteId";

NSErrorDomain const kMoPubVASAdapterErrorDomain = @"com.verizon.ads.mopubvasadapter.ErrorDomain";
NSTimeInterval kMoPubVASAdapterSATimeoutInterval = 600;

@implementation VerizonAdapterConfiguration

+ (NSString *)appMediator
{
    return [NSString stringWithFormat:@"MoPubVAS-%@", kMoPubVASAdapterVersion];
}

+ (void)updateInitializationParameters:(NSDictionary *)parameters {}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete
{
    NSString *siteId = configuration[kMoPubVASAdapterSiteId];
    if (siteId.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([VASStandardEdition initializeWithSiteId:siteId]) {
                MPLogInfo(@"VAS adapter version: %@", kMoPubVASAdapterVersion);
            }
            if (complete) {
                complete(nil);
            }
        });
    } else {
        if (complete) {
            complete(nil);
        }
    }
    
    if (MPLogging.consoleLogLevel == MPBLogLevelDebug) {
        [VASAds setLogLevel:VASLogLevelDebug];
    } else if (MPLogging.consoleLogLevel == MPBLogLevelInfo) {
        [VASAds setLogLevel:VASLogLevelInfo];
    }
}

- (NSString *)adapterVersion
{
    return kMoPubVASAdapterVersion;
}

- (NSString *)biddingToken
{
    return nil;
}

- (NSString *)moPubNetworkName
{
    return @"Verizon";
}

- (NSString *)networkSdkVersion
{
    NSString *editionName = [[[VASAds sharedInstance] configuration] stringForDomain:@"com.verizon.ads"
                                                                                 key:@"editionName"
                                                                         withDefault:nil];

    NSString *editionVersion = [[[VASAds sharedInstance] configuration] stringForDomain:@"com.verizon.ads"
                                                                                    key:@"editionVersion"
                                                                            withDefault:nil];
    if (editionName.length > 0 && editionVersion.length > 0) {
        return [NSString stringWithFormat:@"%@-%@", editionName, editionVersion];
    }
    
    NSString *adapterVersion = [self adapterVersion];
    NSRange range = [adapterVersion rangeOfString:@"." options:NSBackwardsSearch];
    
    return adapterVersion.length > range.location ? [adapterVersion substringToIndex:range.location] : @"";
}

@end
