# hangman
This package was created for academic use. It contains a Swift implementation of a strategic game and a CLI tool for creating game simulations.

## Requirements
This is used on Mac OS, but it might also run on Linux. You should have Swift 4.2 installed.

You need the protoc compiler and the swift plugin to build the included protocol buffers schema. See the [plugin repo](https://github.com/apple/swift-protobuf) for more information.

```sh
# Install via homebrew
brew install swift-protobuf
```


## Installation
### Manual (Swift)
```sh
# Clone this repo
cd ~/documents/code
git clone --recurse-submodules git@github.com:strategic-games/hangman.git
cd hangman
# Generate proto schema
./Scripts/generate-proto.sh
# Build with swift
swift build -c release
# Run hangman
swift run -c release hangman --help
# Copy hangman to a binary search path where it is found from anywhere (optional)
cp .build/release/hangman ~/bin/
hangman --help
```

### Xcode
* Clone this repo
* Generate proto schema
* Open hangman.xcodeproj in the directory
* Build
* In project navigator, go to Products > hangman
* Right-click > show in finder
* Copy the contents of the opened directory to a binary search path or where you can find it again
