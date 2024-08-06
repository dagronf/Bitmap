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

import Foundation
import CoreText

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension Bitmap {
	/// The minimum size to contain the string
	/// - Parameter string: The string
	/// - Returns: The size required to contain the string
	@inlinable func requiredBounds(for string: String) -> CGSize {
		self.requiredBounds(for: NSAttributedString(string: string))
	}

	/// The minimum size to contain the string
	/// - Parameter attributedString: The string
	/// - Returns: The size required to contain the string
	func requiredBounds(for attributedString: NSAttributedString) -> CGSize {
		var ascent: CGFloat = 0
		var descent: CGFloat = 0
		var leading: CGFloat = 0
		let line = CTLineCreateWithAttributedString(attributedString as CFAttributedString)
		let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
		return CGSize(width: width, height: ascent + descent)
	}

	/// Draw text inside the given path
	/// - Parameters:
	///   - string: The string to draw
	///   - color: The text color
	///   - path: The position to draw the text
	@inlinable func drawText(_ string: String, color: CGColor = .standard.black, position: CGPoint) {
		let astr = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: color])
		self.drawText(astr, position: position)
	}

	/// Draw text inside the given path
	/// - Parameters:
	///   - string: The string to draw
	///   - color: The text color
	///   - path: The path containing the text, or nil for the entire image
	@inlinable func drawText(_ string: String, color: CGColor = .standard.black, path: CGPath? = nil) {
		let astr = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: color])
		self.drawText(astr, path: path)
	}

	/// Draw text at a position within the bitmap
	/// - Parameters:
	///   - attributedString: The attributed string to draw
	///   - position: The position to draw the text
	func drawText(_ attributedString: NSAttributedString, position: CGPoint) {
		self.savingGState { ctx in
			let line = CTLineCreateWithAttributedString(attributedString as CFAttributedString)
			ctx.textPosition = position
			CTLineDraw(line, ctx)
		}
	}

	/// Draw text inside the given path
	/// - Parameters:
	///   - attributedString: The string to draw
	///   - path: The path containing the text, or nil for the entire image
	func drawText(
		_ attributedString: NSAttributedString,
		path: CGPath? = nil
	) {
		let w = self.width
		let h = self.height
		self.savingGState { ctx in
			let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
			let path = path ?? CGPath(rect: CGRect(x: 0, y: 0, width: w, height: h), transform: nil)
			let frameRef = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: 0), path, nil)
			CTFrameDraw(frameRef, ctx)
		}
	}
}
