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
import AppKit.NSImage
#else
import UIKit
#endif

#if os(macOS)
import AppKit
typealias PlatformImage = NSImage
extension NSImage {
	public var cgImage: CGImage? { self.cgImage(forProposedRect: nil, context: nil, hints: nil) }
}
#else
import UIKit
typealias PlatformImage = UIImage
#endif

#if os(macOS)
public extension Bitmap {
	/// Create a bitmap using the specified NSImage
	convenience init(_ image: NSImage) throws {
		guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
			throw BitmapError.cannotCreateCGImage
		}
		try self.init(cgImage)
	}

	/// An NSImage representation of the bitmap
	var image: NSImage? {
		guard let cgImage = self.cgImage else { return nil }
		return NSImage(cgImage: cgImage, size: .zero)
	}
}
#else
public extension Bitmap {
	/// Create a bitmap using the specified UIImage
	convenience init(_ image: UIImage) throws {
		guard let cgImage = image.cgImage else { throw BitmapError.cannotCreateCGImage }
		try self.init(cgImage)
	}

	/// An UIImage representation of the bitmap
	var image: UIImage? {
		guard let cgImage = self.cgImage else { return nil }
		return UIImage(cgImage: cgImage)
	}
}
#endif

#if !os(macOS)
public struct NSEdgeInsets {
	public let top: CGFloat
	public let left: CGFloat
	public let bottom: CGFloat
	public let right: CGFloat
	public init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
		self.top = top
		self.left = left
		self.bottom = bottom
		self.right = right
	}
}
#endif
