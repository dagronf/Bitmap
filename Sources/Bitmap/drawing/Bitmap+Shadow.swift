//
//  Copyright © 2023 Darren Ford. All rights reserved.
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

public extension Bitmap {
	struct Shadow {
		public let offset: CGSize
		public let blur: Double
		public let color: CGColor
		public init(
			offset: CGSize = .init(width: 3, height: -3),
			blur: Double = 5,
			color: CGColor = .black
		) {
			self.offset = offset
			self.blur = blur
			self.color = color
		}
	}

	mutating func applyingShadow(_ shadow: Shadow, _ draw: (inout Bitmap) -> Void) {
		ctx.saveGState()
		defer { ctx.restoreGState() }
		ctx.setShadow(offset: shadow.offset, blur: shadow.blur, color: shadow.color)
		draw(&self)
	}

	mutating func clippingToPath(_ clippingPath: CGPath, _ drawBlock: (inout Bitmap) -> Void) {
		ctx.saveGState()
		defer { ctx.restoreGState() }
		ctx.addPath(clippingPath)
		ctx.clip()
		drawBlock(&self)
	}
}
