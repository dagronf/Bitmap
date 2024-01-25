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

// CoreImage additions

#if canImport(CoreImage)

import Foundation
import CoreImage

public extension Bitmap {
	init(_ image: CIImage, context: CIContext? = nil, size: CGSize? = nil) throws {
		let context = context ?? CIContext(options: nil)
		let rect: CGRect
		if let size = size {
			rect = CGRect(origin: .zero, size: size)
		}
		else {
			rect = image.extent
			// Arbitrary 'large' values here.
			if rect.width > 20000 || rect.height > 20000 {
				throw BitmapError.invalidContext
			}
		}
		guard let cgImage = context.createCGImage(image, from: rect) else {
			throw BitmapError.cannotCreateCGImage
		}
		try self.init(cgImage)
	}

	/// Returns a CIImage representation of the bitmap
	@inlinable var ciImage: CIImage? {
		guard let cgImage = self.cgImage else { return nil }
		return CIImage(cgImage: cgImage)
	}
}

#endif
