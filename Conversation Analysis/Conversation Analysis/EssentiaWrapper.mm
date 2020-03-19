#import "EssentiaWrapper.h"
#include <vector>

#include <iostream>
#include <fstream>
#include <essentia/algorithmfactory.h>
#include <essentia/essentiamath.h>
#include <essentia/pool.h>


using namespace std;
using namespace essentia;
using namespace essentia::standard;
using namespace essentia::scheduler;

using namespace std;

@implementation ExtractedAudioData
- (id) init {
    if ( self = [super init] ) {
        self.mfcc = [NSMutableArray new];
        self.mb96 = [NSMutableArray new];
        return self;
    }
    return nil;
}
@end

@implementation EssentiaWrapper

- (ExtractedAudioData *) extract:(NSArray*) audio_input {
    // convert input data to vector
    std::vector<float> audio_buffer;
    for(int i = 0; i < audio_input.count; ++i){
        id val = audio_input[i];
        audio_buffer.push_back([val floatValue]);
    }
    // init output
    ExtractedAudioData* data = [[ExtractedAudioData alloc] init];
    
    // parameters
    int FRAME_SIZE = 1024;
    int HOP_SIZE = 512;
    int NUM_BANDS = 96;
    int NUM_MFCC_BANDS = 48;
    int NUM_MFCC_COEFFS = 20;
    
    essentia::init();
    
    // create the following: audioloader -> framecutter -> windowing -> FFT -> MFCC/mb96
    AlgorithmFactory& factory = standard::AlgorithmFactory::instance();
    Algorithm* fc = factory.create("FrameCutter", "frameSize", FRAME_SIZE, "hopSize", HOP_SIZE);
    Algorithm* w = factory.create("Windowing", "type", "blackmanharris62");
    Algorithm* spec = factory.create("Spectrum");
    Algorithm* mfcc = factory.create("MFCC", "numberBands", NUM_MFCC_BANDS, "numberCoefficients", NUM_MFCC_COEFFS);
    Algorithm* melbands = factory.create("MelBands", "numberBands", NUM_BANDS, "log", false);
    
    vector<Real> frame, windowed_frame, spectrum, mfcc_coeffs, mfcc_bands, melbands_data;
    fc->input("signal").set(audio_buffer);
    
    fc->output("frame").set(frame);
    w->input("frame").set(frame);
    
    w->output("frame").set(windowed_frame);
    spec->input("frame").set(windowed_frame);
    
    spec->output("spectrum").set(spectrum);
    mfcc->input("spectrum").set(spectrum);
    melbands->input("spectrum").set(spectrum);
    
    mfcc->output("bands").set(mfcc_bands);
    mfcc->output("mfcc").set(mfcc_coeffs);
    melbands->output("bands").set(melbands_data);
    
    // compute
    while (true) {
        fc->compute();
        
        // last frame
        if (!frame.size()) {
            break;
        }
        
        // if the frame is silent, just drop it and go on processing
        if (isSilent(frame)) continue;
        
        w->compute();
        spec->compute();
        mfcc->compute();
        melbands->compute();
        
        // add to return data arrays
        NSMutableArray* mb96_tmp = [NSMutableArray new];
        for(auto const &value: melbands_data) {
            [mb96_tmp addObject:@(value)];
        }
        [data.mb96 addObject:mb96_tmp];
        
        NSMutableArray* mfcc_tmp = [NSMutableArray new];
        for(auto const &value: mfcc_coeffs) {
            [mfcc_tmp addObject:@(value)];
        }
        [data.mfcc addObject:mfcc_tmp];        
    }
    
    // cleanup
    delete fc;
    delete w;
    delete spec;
    delete mfcc;
    delete melbands;
    
    essentia::shutdown();
    
    return data;
}

@end
