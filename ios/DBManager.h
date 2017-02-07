#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#else
#import <RCTBridgeModule.h>
#endif

#import "SQLiteManager.h"

@interface DBManager : NSObject <RCTBridgeModule>

@property (nonatomic, strong) SQLiteManager *db;

- (void)init:(NSString *)dbName callback:(RCTResponseSenderBlock)callback;
- (void)query:(NSString *)sql params:(NSArray *)params callback:(RCTResponseSenderBlock)callback;
// - (void)execute:(NSString *)sql callback:(RCTResponseSenderBlock)callback;

@end
