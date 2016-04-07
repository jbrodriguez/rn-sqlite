#import "SQLiteManager.h"
#import <sqlite3.h>


@interface SQLiteManager()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableArray *arrResults;

-(void)copyDatabaseIntoDocumentsDirectory;
-(void)runQuery:(const char *)query params:(NSArray *)params isQueryExecutable:(BOOL)queryExecutable withError:(NSError **)error;

@end


@implementation SQLiteManager

#pragma mark - Initialization

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename{
    self = [super init];
    if (self) {
        // Set the documents directory path to the documentsDirectory property.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        
        // Keep the database filename.
        self.databaseFilename = dbFilename;
        
        // Copy the database file into the documents directory if necessary.
        [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}


#pragma mark - Private method implementation

-(void)copyDatabaseIntoDocumentsDirectory{
    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    NSLog(@"location: %@", destinationPath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // The database file does not exist in the documents directory, so copy it from the main bundle now.
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        // Check if any error occurred during copying and display it.
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}



-(void)runQuery:(const char *)query params:(NSArray *)params isQueryExecutable:(BOOL)queryExecutable withError:(NSError **)errorPtr {
	// Create a sqlite object.
	sqlite3 *sqlite3Database;
	
    // Set the database file path.
	NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    
    // Initialize the results array.
    if (self.arrResults != nil) {
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
	self.arrResults = [[NSMutableArray alloc] init];
    
    // Initialize the column names array.
    if (self.arrColumnNames != nil) {
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [[NSMutableArray alloc] init];
    
    
	// Open the database.
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
	if(openDatabaseResult == SQLITE_OK) {
		// Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
		sqlite3_stmt *compiledStatement;
		
        // Load all data from database to memory.
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
		if(prepareStatementResult == SQLITE_OK) {

			// Bind sql query arguments
	        for (int i=0; i < [params count]; i++){
	            NSObject *param = [params objectAtIndex: i];

	            if ([param isKindOfClass: [NSString class]]) {
	                NSString *str = (NSString*) param;
	                int strLength = (int) [str lengthOfBytesUsingEncoding: NSUTF8StringEncoding];
	                sqlite3_bind_text(compiledStatement, i+1, [str UTF8String], strLength, SQLITE_TRANSIENT);
	            } else if ([param isKindOfClass: [NSNumber class]]) {
	                sqlite3_bind_double(compiledStatement, i+1, [(NSNumber *)param doubleValue]);
	            } else if ([param isKindOfClass: [NSNull class]]) {
	                sqlite3_bind_null(compiledStatement, i+1);
	            } else {
	                sqlite3_finalize(compiledStatement);
		
					NSString *domain = @"@io.jbrodriguez.evtapp.ErrorDomain";
					NSString *desc = @"Parameters must be either numbers or strings";
		            // In the database cannot be opened then show the error message on the debugger.
		            NSDictionary *info = [[NSDictionary alloc] 
		            					initWithObjectsAndKeys:desc,
		            					@"NSLocalizedDescriptionKey",
		            					NULL
		            					];
		            *errorPtr = [NSError errorWithDomain:domain code:-103 userInfo:info];	                
	                // callback(@[@"Parameters must be either numbers or strings" ]);
	    
	                return;
	            }
	        }

			// Check if the query is non-executable.
			if (!queryExecutable){
                // In this case data must be loaded from the database.
                
                // Declare an array to keep the data for each fetched row.
                // NSMutableArray *arrDataRow;
                NSMutableDictionary *rowData;
                
				// Loop through the results and add them to the results array row by row.
				while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
					// // Initialize the mutable array that will contain the data of a fetched row.
     //                arrDataRow = [[NSMutableArray alloc] init];
                    
     //                // Get the total number of columns.
     //                int totalColumns = sqlite3_column_count(compiledStatement);
                    
     //                // Go through all columns and fetch each column data.
					// for (int i=0; i<totalColumns; i++){
     //                    // Convert the column data to text (characters).
					// 	char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        
     //                    // If there are contents in the currenct column (field) then add them to the current row array.
					// 	if (dbDataAsChars != NULL) {
     //                        // Convert the characters to string.
					// 		[arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
					// 	}
                        
     //                    // Keep the current column name.
     //                    if (self.arrColumnNames.count != totalColumns) {
     //                        dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
     //                        [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
     //                    }
     //                }

		            int totalColumns = sqlite3_column_count(compiledStatement);
		            rowData = [NSMutableDictionary dictionaryWithCapacity: totalColumns];
		            // Go through all columns and fetch each column data.
		            for (int i=0; i<totalColumns; i++){
		                // Convert the column data to text (characters).
		                
		                NSObject *value;
		                NSData *data;
		                switch (sqlite3_column_type(compiledStatement, i)) {
		                    case SQLITE_INTEGER:
		                        value = [NSNumber numberWithLongLong: sqlite3_column_int64(compiledStatement, i)];
		                        break;
		                    case SQLITE_FLOAT:
		                        value = [NSNumber numberWithDouble: sqlite3_column_double(compiledStatement, i)];
		                        break;
		                    case SQLITE_NULL:
		                        value = [NSNull null];
		                        break;
		                    // case SQLITE_BLOB:
		                    //     sqlite3_finalize(compiledStatement);
		                    //     // TODO: How should we support blobs? Maybe base64 encode them?
		                    //     callback(@[@"BLOBs not supported", [NSNull null]]);
		                    //     return;
		                    //     break;
		                    case SQLITE_TEXT:
		                    default:
		                        data = [NSData dataWithBytes: sqlite3_column_blob(compiledStatement, i) length: sqlite3_column_bytes16(compiledStatement, i)];
		                        value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		                        break;
		                }
		                char *columnName = (char *)sqlite3_column_name(compiledStatement, i);
		                // Convert the characters to string.
		                [rowData setValue: value forKey: [NSString stringWithUTF8String: columnName]];
		            }
		            // callback(@[[NSNull null], rowData]);					
					
					// Store each fetched data row in the results array, but first check if there is actually data.
					if (rowData.count > 0) {
                        [self.arrResults addObject:rowData];
					}
				}
			}
			else {
                // This is the case of an executable query (insert, update, ...).
                
				// Execute the query.
                int executeQueryResults = sqlite3_step(compiledStatement);
                if (executeQueryResults == SQLITE_DONE) {
                    // Keep the affected rows.
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    
                    // Keep the last inserted row ID.
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
				}
				else {
					// If could not execute the query show the error message on the debugger.
					NSString *domain = @"@io.jbrodriguez.evtapp.ErrorDomain";
					NSString *desc = [[NSString alloc] initWithUTF8String:sqlite3_errmsg(sqlite3Database)];
		            // In the database cannot be opened then show the error message on the debugger.
		            NSDictionary *info = [[NSDictionary alloc] 
		            					initWithObjectsAndKeys:desc,
		            					@"NSLocalizedDescriptionKey",
		            					NULL
		            					];
		            *errorPtr = [NSError errorWithDomain:domain code:-102 userInfo:info];					
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
				}
			}
		}
		else {
			NSString *domain = @"@io.jbrodriguez.evtapp.ErrorDomain";
			NSString *desc = [[NSString alloc] initWithUTF8String:sqlite3_errmsg(sqlite3Database)];
            // In the database cannot be opened then show the error message on the debugger.
            NSDictionary *info = [[NSDictionary alloc] 
            					initWithObjectsAndKeys:desc,
            					@"NSLocalizedDescriptionKey",
            					NULL
            					];
            *errorPtr = [NSError errorWithDomain:domain code:-103 userInfo:info];
			NSLog(@"Unable to open db:%s", sqlite3_errmsg(sqlite3Database));
		}
		
		// Release the compiled statement from memory.
		sqlite3_finalize(compiledStatement);
	}
    
    // Close the database.
	sqlite3_close(sqlite3Database);
}


#pragma mark - Public method implementation

-(NSArray *)query:(NSString *)query params:(NSArray *)params  withError:(NSError **)errorPtr {
    // Run the query and indicate that is not executable.
    // The query string is converted to a char* object.
    [self runQuery:[query UTF8String] params:params isQueryExecutable:NO withError:errorPtr];
    
    // Returned the loaded results.
    return (NSArray *)self.arrResults;
}


-(void)exec:(NSString *)query params:(NSArray *)params  withError:(NSError **)errorPtr {
    // Run the query and indicate that is executable.
    [self runQuery:[query UTF8String] params:params isQueryExecutable:YES withError:errorPtr];
}

-(NSDictionary *)insert:(NSString *)query params:(NSArray *)params  withError:(NSError **)errorPtr {
    // Run the query and indicate that is executable.
    [self runQuery:[query UTF8String] params:params isQueryExecutable:YES withError:errorPtr];

    NSDictionary *map = @{
    	@"lastInsertedRowID" : [NSNumber numberWithInt:self.lastInsertedRowID],
    	@"affectedRows" : [NSNumber numberWithInt:self.affectedRows],
    };

    return map;
}


@end
