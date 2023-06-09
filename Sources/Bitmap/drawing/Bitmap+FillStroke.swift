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

	struct Stroke {
		public let color: CGColor
		public let lineWidth: Double
	}

	/// Draw on the current image
	@inlinable mutating func draw(
		rect: CGRect,
		fillColor: CGColor?,
		stroke: Stroke?
	) {
		draw(rects: [rect], fillColor: fillColor, stroke: stroke)
	}

	/// Draw on the current image
	@inlinable mutating func draw(
		rects: [CGRect],
		fillColor: CGColor?,
		stroke: Stroke?
	) {
		self.draw { ctx in
			rects.forEach {
				if let c = fillColor {
					ctx.setFillColor(c)
					ctx.fill([$0])
				}
				if let s = stroke {
					ctx.setStrokeColor(s.color)
					ctx.setLineWidth(s.lineWidth)
					rects.forEach {
						ctx.stroke($0)
					}
				}
			}
		}
	}
}

public extension Bitmap {

	/// Fill the entire bitmap with a color
	mutating func fill(_ fillColor: CGColor) {
		let dest = CGRect(x: 0, y: 0, width: width, height: height)
		self.savingGState { ctx in
			ctx.setFillColor(fillColor)
			ctx.addPath(CGPath(rect: dest, transform: nil))
			ctx.fillPath()
		}
	}

	/// Fill a path in the bitmap
	mutating func fill(_ path: CGPath, _ fillColor: CGColor) {
		self.draw { ctx in
			ctx.addPath(path)
			ctx.setFillColor(fillColor)
			ctx.fillPath()
		}
	}

	/// Stroke a path in the bitmap
	mutating func stroke(_ path: CGPath, _ stroke: Stroke) {
		self.savingGState { ctx in
			ctx.addPath(path)
			ctx.setStrokeColor(stroke.color)
			ctx.setLineWidth(stroke.lineWidth)
			ctx.strokePath()
		}
	}

	mutating func fillStroke(_ path: CGPath, fillColor: CGColor, stroke: Stroke) {
		self.savingGState { ctx in
			ctx.addPath(path)
			ctx.setFillColor(fillColor)
			ctx.fillPath()
			ctx.addPath(path)
			ctx.setStrokeColor(stroke.color)
			ctx.setLineWidth(stroke.lineWidth)
			ctx.strokePath()
		}
	}
}
