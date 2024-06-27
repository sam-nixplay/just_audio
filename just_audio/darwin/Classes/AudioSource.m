#import "AudioSource.h"
#import <AVFoundation/AVFoundation.h>

@implementation AudioSource {
    NSString *_sourceId;
}

- (instancetype)initWithId:(NSString *)sid {
    self = [super init];
    NSAssert(self, @"super init cannot be nil");
    _sourceId = sid;
    return self;
}

// Returns the ID of the audio source.
- (NSString *)sourceId {
    return _sourceId;
}

// Indicates whether lazy loading is supported. Default is NO.
- (BOOL)lazyLoading {
    return NO;
}

// Sets lazy loading. No-op for default implementation.
- (void)setLazyLoading:(BOOL)lazyLoading {
    // No-op as default implementation does not support lazy loading.
}

// Builds a sequence of audio sources. Default implementation does not modify the sequence.
- (int)buildSequence:(NSMutableArray *)sequence treeIndex:(int)treeIndex {
    // Default implementation does not modify the sequence.
    return treeIndex;
}

// Finds audio sources by ID and adds matches to the provided array.
- (void)findById:(NSString *)sourceId matches:(NSMutableArray<AudioSource *> *)matches {
    if ([_sourceId isEqualToString:sourceId]) {
        [matches addObject:self];
    }
}

// Returns an array of shuffle indices. Default implementation returns an empty array.
- (NSArray<NSNumber *> *)getShuffleIndices {
    // Default implementation returns an empty array.
    return @[];
}

// Decodes shuffle order from the provided dictionary. Default implementation does nothing.
- (void)decodeShuffleOrder:(NSDictionary *)dict {
    // Default implementation does nothing.
}

// Optional: Logs the current state of the audio source for debugging purposes.
- (void)logState {
    NSLog(@"AudioSource ID: %@", _sourceId);
    NSLog(@"Lazy Loading: %@", self.lazyLoading ? @"Enabled" : @"Disabled");
}

@end
