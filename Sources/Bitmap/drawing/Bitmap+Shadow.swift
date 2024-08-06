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
import CoreGraphics

public extension Bitmap {
	/// Shadow definition
	struct Shadow {
		/// Specifies a translation in base-space
		public let offset: CGSize
		/// A non-negative number specifying the amount of blur.
		public let blur: Double
		/// Specifies the color of the shadow, which may contain a non-opaque alpha value. If NULL, then shadowing is disabled.
		public let color: CGColor
		/// Create a shadow style
		public init(offset: CGSize = .init(width: 3, height: -3), blur: Double = 5, color: CGColor = .standard.black) {
			self.offset = offset
			self.blur = blur
			self.color = color
		}
	}
}

// MARK: - Shadows

public extension Bitmap {
	/// Apply a shadow to a drawing block
	/// - Parameters:
	///   - shadow: The shadow style
	///   - draw: The drawing to apply the shadow to
	func applyingShadow(_ shadow: Shadow, _ draw: (Bitmap) -> Void) {
		self.savingGState { ctx in
			ctx.setShadow(offset: shadow.offset, blur: shadow.blur, color: shadow.color)
			draw(self)
		}
	}
}
