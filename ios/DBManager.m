#if __has_include(<React/RCTBridge.h>)
#import "React/RCTLog.h"
#import "React/RCTUtils.h"
#import "React/RCTBridge.h"
#import "React/RCTEventDispatcher.h"
#else
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#endif
#import <Foundation/Foundation.h>
#import "DBManager.h"
#import "SQLiteManager.h"

#import <sqlite3.h>

// // From RCTAsyncLocalStorage, make a queue so we can serialise our interactions
// static dispatch_queue_t AIBSQLiteQueue(void)
// {
//     static dispatch_queue_t sqliteQueue = NULL;
//     static dispatch_once_t onceToken;
//     dispatch_once(&onceToken, ^{
//         // All JS is single threaded, so a serial queue is our only option.
//         sqliteQueue = dispatch_queue_create("com.activeinboxhq.sqlite", DISPATCH_QUEUE_SERIAL);
//         dispatch_set_target_queue(sqliteQueue,
//                                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
//     });

//     return sqliteQueue;
// }

static dispatch_queue_t JBRQueue()
{
  // We want all instances to share the same queue since they will be reading/writing the same files.
  static dispatch_queue_t queue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    queue = dispatch_queue_create("io.jbrodriguez.evtapp", DISPATCH_QUEUE_SERIAL);
  });
  return queue;
}

@implementation DBManager

RCT_EXPORT_MODULE();

- (id) init
{
	self = [super init];
	return self;
}

RCT_EXPORT_METHOD(init:(NSString *)dbName callback:(RCTResponseSenderBlock)callback)
{
	NSLog(@"Initializing db: %@", dbName);

    if (!callback) {
        RCTLogError(@"Called init without a callback.");
        return;
    }

    dispatch_async(JBRQueue(), ^{
	    if (self) {
	    	self.db = [[SQLiteManager alloc] initWithDatabaseFilename:dbName];
	    }

	    callback(@[[NSNull null], @"System is nominal"]);
    });
}

RCT_EXPORT_METHOD(query:(NSString *)sql params:(NSArray *)params callback:(RCTResponseSenderBlock)callback)
{
    if (!callback) {
        RCTLogError(@"Called query without a callback.");
        return;
    }

	NSLog(@"Calling query: %@", sql);

    dispatch_async(JBRQueue(), ^{
	    if (self) {
	    	NSError *error = nil;
	    	NSArray *items = [self.db query:sql params:params withError:&error];
	    	if (error)
	    	{
	    		NSLog(@"Error querying db: %@",error);
	    		callback(@[error, [NSNull null]]);
	    	}
	    	else
	    	{
	    		// NSLog(@"Is this it: %@", items);
	    		if (items == nil)
	    		{
	    		// NSLog(@"first.one: %@", items);
				    callback(@[[NSNull null], [NSNull null]]);
	    		}
	    		else
	    		{
	    		// NSLog(@"second.one: %@", items);
				    callback(@[[NSNull null], items]);
	    		}
	    	}
	    }
    });
}

RCT_EXPORT_METHOD(exec:(NSString *)sql params:(NSArray *)params callback:(RCTResponseSenderBlock)callback)
{
    if (!callback) {
        RCTLogError(@"Called query without a callback.");
        return;
    }

	NSLog(@"Calling exec: %@", sql);

    dispatch_async(JBRQueue(), ^{
	    if (self) {
	    	NSError *error = nil;
	    	[self.db exec:sql params:params withError:&error];
	    	if (error)
	    	{
	    		NSLog(@"Error execing db: %@",error);
	    		callback(@[error, [NSNull null]]);
	    	}
	    	else
	    	{
			    callback(@[[NSNull null], @""]);
	    	}
	    }
    });
}

RCT_EXPORT_METHOD(insert:(NSString *)sql params:(NSArray *)params index:(nonnull NSNumber *)index callback:(RCTResponseSenderBlock)callback)
{
    if (!callback) {
        RCTLogError(@"Called query without a callback.");
        return;
    }

	NSLog(@"Calling exec: %@", sql);

    dispatch_async(JBRQueue(), ^{
	    if (self) {
	    	NSError *error = nil;
	    	NSDictionary *map = [self.db insert:sql params:params withError:&error];
	    	if (error)
	    	{
	    		NSLog(@"Error execing db: %@",error);
	    		callback(@[error, [NSNull null]]);
	    	}
	    	else
	    	{
			    callback(@[[NSNull null], map[@"lastInsertedRowID"], map[@"affectedRows"]]);
	    	}
	    }
    });
}

@end
