# MTImage

[![License](https://img.shields.io/github/license/mntone/MTImage.svg?style=flat-square)](https://github.com/mntone/MTImage/blob/master/LICENSE.txt)

MTImage is a extended image format for iOS, tvOS, and macOS.

- Supports animation GIF image format, Animation PNG image format with `MTAnimatedImage`.
- Supports WebP image format
  - Supports ICC Profile in WebP file.


## Requirements

- OS: iOS 2.0+ / tvOS 9.0+ / macOS 10.5+
- language: Objective-C or Swift


## Usage

You should replace the following class:

- `UIImage` / `NSImage` → `MTImage`.
- `UIImageView` / `NSImageView` → `MTImageView`.

This is only support for still image. If you use animation formats, you use `MTAnimatedImage` and `MTAnimatedImageView`. But, it has minor bug now.

## Installation

### Carthage

You can integrate MTImage to your project on the Carthage.

```
github "mntone/MTImage"
```

Run `carthage update --use-submodules` to build the framework.

***Don't forget to use `--use-submodules` flag!***


## LICENSE

[MIT License](https://github.com/mntone/MTImage/blob/master/LICENSE.txt)


## Author

mntone
- GitHub: https://github.com/mntone
- Twitter: https://twitter.com/mntone (Japanese)
