//
//  Copyright © 2025 Darren Ford. All rights reserved.
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

import Foundation
import CoreGraphics

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Extensions for known image format types (eg. `NSImage`, `UIImage`, `Bitmap` etc)
public protocol ImageRepresentationType {
	/// Returns a CGImage representation of the bitmap image format
	func imageRepresentation() throws -> CGImage
}

extension CGImage: ImageRepresentationType {
	/// Returns a CGImage representation of the bitmap image format
	@inlinable @inline(__always)
	public func imageRepresentation() throws -> CGImage { self }
}

extension Bitmap: ImageRepresentationType {
	/// Returns a CGImage representation of the bitmap
	@inlinable public func imageRepresentation() throws -> CGImage {
		guard let snapshot = self.cgImage else { throw Bitmap.BitmapError.cannotCreateCGImage }
		return snapshot
	}
}

#if os(macOS)
import AppKit
extension NSImage: ImageRepresentationType {
	/// Returns a CGImage representation of the NSImage
	@inlinable public func imageRepresentation() throws -> CGImage {
		guard let snapshot = self.cgImage else { throw Bitmap.BitmapError.cannotCreateCGImage }
		return snapshot
	}
}
#else
import UIKit
extension UIImage: ImageRepresentationType {
	/// Returns a CGImage representation of the UIImage
	public func imageRepresentation() throws -> CGImage {
		guard let snapshot = self.cgImage else { throw Bitmap.BitmapError.cannotCreateCGImage }
		return snapshot
	}
}
#endif
