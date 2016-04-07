#import <RCTBridgeModule.h>
#import "SQLiteManager.h"

@interface DBManager : NSObject <RCTBridgeModule>

@property (nonatomic, strong) SQLiteManager *db;

- (void)init:(NSString *)dbName callback:(RCTResponseSenderBlock)callback;
- (void)query:(NSString *)sql params:(NSArray *)params callback:(RCTResponseSenderBlock)callback;
// - (void)execute:(NSString *)sql callback:(RCTResponseSenderBlock)callback;

@end