//
//  iCloudDocument.m
//  iCloud Document Sync
//
//  Created by iRare Media on June 27, 2013
//  Copyright (c) 2013 iRare Media. All rights reserved.
//
//

#import "iCloudDocument.h"

NSFileVersion *laterVersion (NSFileVersion *first, NSFileVersion *second) {
    NSDate *firstDate = first.modificationDate;
    NSDate *secondDate = second.modificationDate;
    return ([firstDate compare:secondDate] != NSOrderedDescending) ? second : first;
}

@implementation iCloudDocument
@synthesize contents, delegate;

//----------------------------------------------------------------------------------------------------------------//
//------------  Document Life Cycle ------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------//
#pragma mark - Document Life Cycle

+ (id)sharedCloudDocument {
    static iCloudDocument *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)initWithFileURL:(NSURL *)url {
	self = [super initWithFileURL:url];
	if (self) {
		self.contents = [[NSData alloc] init];
	}
	return self;
}

- (NSString *)localizedName {
	return [self.fileURL lastPathComponent];
}

- (NSString *)stateDescription {
    if (!self.documentState) return @"Document state is normal";
    
    NSMutableString *string = [NSMutableString string];
    if ((self.documentState & UIDocumentStateNormal) != 0) [string appendString:@"Document state is normal"];
    if ((self.documentState & UIDocumentStateClosed) != 0) [string appendString:@"Document is closed"];
    if ((self.documentState & UIDocumentStateInConflict) != 0) [string appendString:@"Document is in conflict"];
    if ((self.documentState & UIDocumentStateSavingError) != 0) [string appendString:@"Document is experiencing saving error"];
    if ((self.documentState & UIDocumentStateEditingDisabled) != 0) [string appendString:@"Document editing is disbled"];
    
    return string;
}

//----------------------------------------------------------------------------------------------------------------//
//------------  Loading and Saving -------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------//
#pragma mark - Loading and Saving

- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
    if (!self.contents) {
        self.contents = [[NSData alloc] init];
    }
    
	NSData *data = self.contents;
	return data;
}

- (BOOL)loadFromContents:(id)fileContents ofType:(NSString *)typeName error:(NSError **)outError {
    if ([fileContents length] > 0) {
        self.contents = [[NSData alloc] initWithData:fileContents];
    } else {
        self.contents = [[NSData alloc] init];
    }
    
    return YES;
}

- (void)setDocumentData:(NSData *)newData {
    NSData *oldData = contents;
    contents = [newData copy];
        
    // Register the undo operation
    [self.undoManager setActionName:@"Data Change"];
    [self.undoManager registerUndoWithTarget:self selector:@selector(setDocumentData:) object:oldData];
}

//----------------------------------------------------------------------------------------------------------------//
//------------  Error Handling ----------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------//
#pragma mark - Loading and Saving

- (void)handleError:(NSError *)error userInteractionPermitted:(BOOL)userInteractionPermitted {
    [super handleError:error userInteractionPermitted:userInteractionPermitted];
	NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    
    if ([delegate respondsToSelector:@selector(iCloudDocumentErrorOccured:)]) [delegate iCloudDocumentErrorOccured:error];
}

@end

