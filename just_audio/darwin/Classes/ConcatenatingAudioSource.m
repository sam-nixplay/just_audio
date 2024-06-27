#import "AudioSource.h"
#import "ConcatenatingAudioSource.h"
#import <AVFoundation/AVFoundation.h>
#import <stdlib.h>

@implementation ConcatenatingAudioSource {
    NSMutableArray<AudioSource *> *_audioSources;
    NSArray<NSNumber *> *_shuffleOrder;
}

// Initializer for ConcatenatingAudioSource with shuffle order and lazy loading support
- (instancetype)initWithId:(NSString *)sid audioSources:(NSMutableArray<AudioSource *> *)audioSources shuffleOrder:(NSArray<NSNumber *> *)shuffleOrder lazyLoading:(NSNumber *)lazyLoading {
    self = [super initWithId:sid];
    NSAssert(self, @"super init cannot be nil");
    _audioSources = audioSources;
    _shuffleOrder = shuffleOrder;
    self.lazyLoading = [lazyLoading boolValue];
    return self;
}

// Returns the count of audio sources
- (int)count {
    return (int)_audioSources.count;
}

// Indicates whether lazy loading is enabled, based on the first audio source
- (BOOL)lazyLoading {
    return [_audioSources count] > 0 ? _audioSources[0].lazyLoading : NO;
}

// Sets lazy loading for all audio sources
- (void)setLazyLoading:(BOOL)lazyLoading {
    for (int i = 0; i < [_audioSources count]; i++) {
        _audioSources[i].lazyLoading = lazyLoading;
    }
}

// Inserts a new audio source at the specified index
- (void)insertSource:(AudioSource *)audioSource atIndex:(int)index {
    [_audioSources insertObject:audioSource atIndex:index];
}

// Removes audio sources in the specified range
- (void)removeSourcesFromIndex:(int)start toIndex:(int)end {
    if (end == -1) end = (int)_audioSources.count;
    for (int i = start; i < end; i++) {
        [_audioSources removeObjectAtIndex:start];
    }
}

// Moves an audio source from one index to another
- (void)moveSourceFromIndex:(int)currentIndex toIndex:(int)newIndex {
    AudioSource *source = _audioSources[currentIndex];
    [_audioSources removeObjectAtIndex:currentIndex];
    [_audioSources insertObject:source atIndex:newIndex];
}

// Builds a sequence of audio sources and returns the updated tree index
- (int)buildSequence:(NSMutableArray *)sequence treeIndex:(int)treeIndex {
    for (int i = 0; i < [_audioSources count]; i++) {
        treeIndex = [_audioSources[i] buildSequence:sequence treeIndex:treeIndex];
    }
    return treeIndex;
}

// Finds audio sources by ID and adds matches to the provided array
- (void)findById:(NSString *)sourceId matches:(NSMutableArray<AudioSource *> *)matches {
    [super findById:sourceId matches:matches];
    for (int i = 0; i < [_audioSources count]; i++) {
        [_audioSources[i] findById:sourceId matches:matches];
    }
}

// Returns the shuffle indices for the audio sources
- (NSArray<NSNumber *> *)getShuffleIndices {
    NSMutableArray<NSNumber *> *order = [NSMutableArray new];
    int offset = (int)[order count];
    NSMutableArray<NSArray<NSNumber *> *> *childOrders = [NSMutableArray new]; // array of array of ints
    for (int i = 0; i < [_audioSources count]; i++) {
        AudioSource *audioSource = _audioSources[i];
        NSArray<NSNumber *> *childShuffleIndices = [audioSource getShuffleIndices];
        NSMutableArray<NSNumber *> *offsetChildShuffleOrder = [NSMutableArray new];
        for (int j = 0; j < [childShuffleIndices count]; j++) {
            [offsetChildShuffleOrder addObject:@([childShuffleIndices[j] integerValue] + offset)];
        }
        [childOrders addObject:offsetChildShuffleOrder];
        offset += [childShuffleIndices count];
    }
    for (int i = 0; i < [_audioSources count]; i++) {
        [order addObjectsFromArray:childOrders[[_shuffleOrder[i] integerValue]]];
    }
    return order;
}

// Sets the shuffle order for the audio sources
- (void)setShuffleOrder:(NSArray<NSNumber *> *)shuffleOrder {
    _shuffleOrder = shuffleOrder;
}

// Decodes and sets the shuffle order from a dictionary
- (void)decodeShuffleOrder:(NSDictionary *)dict {
    _shuffleOrder = (NSArray<NSNumber *> *)dict[@"shuffleOrder"];
    NSArray *dictChildren = (NSArray *)dict[@"children"];
    if (_audioSources.count != dictChildren.count) {
        NSLog(@"decodeShuffleOrder Concatenating children don't match");
        return;
    }
    for (int i = 0; i < [_audioSources count]; i++) {
        AudioSource *child = _audioSources[i];
        NSDictionary *dictChild = (NSDictionary *)dictChildren[i];
        [child decodeShuffleOrder:dictChild];
    }
}

@end
