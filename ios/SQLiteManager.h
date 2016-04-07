#import <Foundation/Foundation.h>

@interface SQLiteManager : NSObject

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;
-(NSArray *)query:(NSString *)query params:(NSArray *)params withError:(NSError **)errorPtr;
-(void)exec:(NSString *)query params:(NSArray *)params withError:(NSError **)errorPtr;
-(NSDictionary *)insert:(NSString *)query params:(NSArray *)params withError:(NSError **)errorPtr;


@end
