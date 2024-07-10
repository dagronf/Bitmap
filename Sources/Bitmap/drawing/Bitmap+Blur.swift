//
//  Copyright © 2024 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Accelerate
import CoreGraphics
import Foundation

public extension Bitmap {
	/// Blur this bitmap using a radius
	/// - Parameter inputRadius: The blur radius
	@inlinable func blur(_ inputRadius: Int32 = 5) throws {
		let update = try self.blurring(inputRadius)
		try self.assign(update.bitmapData)
	}

	/// Return a blurred version of this bitmap using a box convolve
	/// - Parameter inputRadius: The blur radius
	/// - Returns: A blurred bitmap
	///
	/// See: [UIImageEffects example code](https://developer.apple.com/library/archive/samplecode/UIImageEffects/Listings/UIImageEffects_UIImageEffects_m.html#//apple_ref/doc/uid/DTS40013396-UIImageEffects_UIImageEffects_m-DontLinkElementID_9)
	func blurring(_ inputRadius: Int32 = 5) throws -> Bitmap {
		guard let data = self.bitmapContext.data else {
			throw BitmapError.invalidContext
		}

		var radius = UInt32(floor((Double(inputRadius) * 3 * sqrt(2 * Double.pi) / 4 + 0.5) / 2))
		radius |= 1 // force radius to be odd so that the three box-blur methodology works.

		let bytesPerRow = self.width * 4
		let size = MemoryLayout<UInt8>.size * self.width * self.height * 4
		let bufferOut = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
		defer { bufferOut.deallocate() }
		var src = vImage_Buffer(
			data: data,
			height: vImagePixelCount(self.height),
			width: vImagePixelCount(self.width),
			rowBytes: bytesPerRow
		)
		var dst = vImage_Buffer(
			data: bufferOut,
			height: vImagePixelCount(self.height),
			width: vImagePixelCount(self.width),
			rowBytes: bytesPerRow
		)
		vImageBoxConvolve_ARGB8888(&src, &dst, nil, 0, 0, radius, radius, nil, vImage_Flags(kvImageCopyInPlace))

		let result = self
		guard let _ = result.bitmapContext.data else {
			throw BitmapError.invalidContext
		}
		result.bitmapContext.data!.copyMemory(from: bufferOut, byteCount: size)
		return result
	}
}
