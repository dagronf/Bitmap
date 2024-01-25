# Bitmap

![tag](https://img.shields.io/github/v/tag/dagronf/Bitmap)
![Swift](https://img.shields.io/badge/Swift-5.4-orange.svg)
[![License MIT](https://img.shields.io/badge/license-MIT-magenta.svg)](https://github.com/dagronf/Bitmap/blob/master/LICENSE) 
![SPM](https://img.shields.io/badge/spm-compatible-maroon.svg)

![macOS](https://img.shields.io/badge/macOS-10.13+-darkblue)
![iOS](https://img.shields.io/badge/iOS-13+-crimson)
![tvOS](https://img.shields.io/badge/tvOS-13+-forestgreen)
![watchOS](https://img.shields.io/badge/watchOS-6+-indigo)
![macCatalyst](https://img.shields.io/badge/macCatalyst-2+-orangered)

A Swift-y convenience for loading/saving and manipulating bitmap images.

## Why?

I wanted a simple Swift interface for wrapping some of the common image manipulations
that I come across in my day-to-day image needs, the primary being easily being able to draw directly into a
bitmap image.

* Supports all Apple platforms (with some limitations on watchOS)
* supports loading non-RGBA format images (eg. CMYK) by converting the image to RGBA during load.
* objects are easily saved via its `representation` property.
* supports both mutable and immutable methods (functional-style) for manipulating bitmaps.
* bitmap manipulation functions
* `Sendable` support to push bitmap information between tasks.

## Definitions

The `Bitmap` object represents an RGBA image. The image data is stored internally in a simple 1-D array of bytes
representing the R,G,B,A sequence of pixels. 

The bitmap object holds and manages a `CGContext` representation of the bitmap to allow CG- operations directly 
on the bitmap itself. 

* `Bitmap`s coordinate system starts at (0, 0) in the bottom left. 
* All operations/manipulations/coordinates occur from the bottom left.

## Creating a new image

Nice and simple :-)

```swift
var bitmap = try Bitmap(width: 640, height: 480)
```

## Loading an image into a Bitmap

Supports any file formats that `NSImage`, `UIImage` and `CGImageSource` support when loading.

```swift
// From a file...
var bitmap = try Bitmap(fileURL: ...)

// From image data
var bitmap = try Bitmap(imageData: ...)
```

## Saving a bitmap

Supports any file formats that `NSImage`, `UIImage` and `CGImageSource` support when saving.

`Bitmap` provides methods for writing to some different formats, such as `png`.
The `representation` property on the bitmap contains the methods for generating
image data in different formats

```swift
var bitmap = try Bitmap(fileURL: ...)
...
let pngData = bitmap.representation?.png()
```

## Drawing into a bitmap

### Drawing into the bitmap's context using CG methods

```swift
var bitmap = try Bitmap(width: 640, height: 480)
bitmap.draw { ctx in
   ctx.setFillColor(.black)
   ctx.fill([CGRect(x: 5, y: 5, width: 20, height: 20)])
}
```

### Drawing an image into the bitmap

```swift
var bitmap = try Bitmap(width: 640, height: 480)
// Draw an image into a defined rectangle (with optional scaling types aspectFit, aspectFill, axes independent)
bitmap.drawImage(image, in: CGRect(x: 50, y: 50, width: 100, height: 100))
// Draw a bitmap at a point
bitmap.drawBitmap(bitmap, at: CGPoint(x: 300, y: 300))
```

## Getting/setting individual pixels

You can directly access pixel information in the bitmap using subscripts or the get/setPixel methods on `Bitmap`

```swift
var bitmap = Bitmap(...)

// Retrieve the color of the pixel at x = 4, y = 3.
let rgbaPixel = bitmap[4, 3]   // or bitmap.getPixel(x: 4, y: 3)

// Set the color of the pixel at x = 4, y = 3. Only available when `bitmap` is mutable
bitmap[4, 3] = Bitmap.RGBA(r: 255, g: 0, b: 0, a: 255)   // or bitmap.setPixel(x: 4, y: 3, ...)
```

## Bitmap operations

`Bitmap` provides a number of built-in operations (such as rotate, tint) that operate on a `Bitmap` instance. 

### Mutable

Mutable functions operate on a Bitmap variable. Each method modifies the original bitmap instance.

```swift
// Load an image, rotate it and convert it to grayscale
var bitmap = try Bitmap(fileURL: ...)
try bitmap.rotate(by: 1.4)
try bitmap.grayscale()
```

### Immutable

Immutable functions work on a copy of the bitmap and return the copy. The original bitmap (which can be a `let` variable
remains untouched.

Immutable function variations are named with 'ing' in the title, such as `tinting()` or `scaling()`.

```swift
// Load an image, rotate it and convert it to grayscale
let bitmap = try Bitmap(fileURL: ...)
let rotated = try bitmap.rotating(by: 1.4)
let grayscale = try rotated.grayscaling()
```

This allows functional-style chaining on a bitmap.

```swift
// Functional style
let bitmap = try Bitmap(fileURL: ...)
	.rotating(by: 1.4)
	.grayscaling()
```

### Available bitmap manipulation functions

* Resizing/scaling
* Padding/inset
* Clipping/masking
* Rotation
* Scrolling
* Transparency removal
* Punching holes
* Color manipulation (eg. grayscale, tinting, gamma adjustment, saturation etc)
* Flipping
* Drawing (eg. lines, shapes, paths, fill/stroke)
* Drawing text
* Drawing borders

… and more!

## Sendable support

You will not be able to directly send a `Bitmap` object between Tasks.
This is due to `Bitmap` internally caching a `CGContext` instance in order to increase performance and 
reduce the memory footprint.

Internally, `Bitmap` keeps pixel information inside a `Bitmap.RGBAData` object which conforms to `Sendable`. 
This object can be passed safely between tasks and are easily reconstituted into a new `Bitmap` object.

```swift
var myBitmap = try Bitmap(...)
let bitmapData = myBitmap.bitmapData

// Pass `bitmapData` to another Task

var myBitmap = try Bitmap(bitmapData)
```

--------

# License

```
MIT License

Copyright (c) 2023 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
