#import <Foundation/Foundation.h>

@interface ExtractedAudioData : NSObject
    @property NSMutableArray* mfcc;
    @property NSMutableArray* mb96;
    - (id)init;
@end

@interface EssentiaWrapper : NSObject
- (ExtractedAudioData*) extract:(NSArray*) buffer;
@end
