# CS295D-final

## Dependencies
This project has the following Swift Dependencies (installed through the Swift package manager)
- [Alamofire](https://github.com/Alamofire/Alamofire)
- [SwiftPlot](https://github.com/KarthikRIyer/swiftplot)
- [NotificationBannerSwift](https://github.com/Daltron/NotificationBanner)

Additionally, it makes use of the following C/C++ libraries in the Objective C++ wrapper for audio processing
- [Essentia](https://github.com/MTG/essentia)
- [Eigen](https://gitlab.com/libeigen/eigen)
- [FreeType2](https://www.freetype.org/)

### Dependency installation
The C/C++ libraries should be cross compiled for iOS (or the simulator) and placed in `Conversation Analysis/libs/` (which will have `bin`, `include`, `share`, `lib` after successful installation)

Essentia can be compiled for the simulator with the following (more info [here](https://essentia.upf.edu/FAQ.html#cross-compiling-for-ios))
```
./waf configure --cross-compile-ios-sim --lightweight= --fft=ACCELERATE --build-static --prefix Conversation Analysis/libs/
./waf
./waf install
```
Note: When compiling for a physical iOS device, the line in nnlschroma.cpp containing `nnls(curr_dict, nNote, nNote, signifIndex.size(), b, x, &rnorm, w, zz, indx, &mode);` must be commented out for successful iOS build ([issue](https://github.com/MTG/essentia/issues/916))

Eigen's headers can be simply symlinked or coped from [the repository](https://gitlab.com/libeigen/eigen.git). Both the `Eigen` and `unsupported` directories should be included.

FreeType2 must be installed on the system (`brew install freetype`) and also cross compiled for iOS. The [freetype2-ios](https://github.com/cdave1/freetype2-ios) repository contains a script to do this easily.
