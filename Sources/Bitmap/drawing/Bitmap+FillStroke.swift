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

public extension Bitmap {
	/// Stroke drawing properties
	struct Stroke {
		/// Stroke dash
		public struct Dash {
			public let lengths: [CGFloat]
			public let phase: CGFloat
			public init(lengths: [CGFloat], phase: CGFloat = 0.0) {
				self.lengths = lengths
				self.phase = phase
			}
		}

		public let color: CGColor
		public let lineWidth: Double
		public let dash: Dash?
		public init(color: CGColor = .standard.black, lineWidth: Double = 1.0, dash: Dash? = nil) {
			self.color = color
			self.lineWidth = lineWidth
			self.dash = dash
		}
	}

	/// Fill/stroke a path on a copy of this image
	/// - Parameters:
	///   - path: The path to fill/stroke
	///   - fillColor: The fill color
	///   - stroke: The stroke style
	/// - Returns: A new bitmap
	func drawingPath(_ path: CGPath, fillColor: CGColor? = nil, stroke: Stroke? = nil) throws -> Bitmap {
		let copy = try self.copy()
		copy.drawPath(path, fillColor: fillColor, stroke: stroke)
		return copy
	}

	/// Draw on the current image
	/// - Parameters:
	///   - path: The path to fill/stroke
	///   - fillColor: The fill color
	///   - stroke: The stroke style
	@inlinable func drawPath(_ path: CGPath, fillColor: CGColor? = nil, stroke: Stroke? = nil) {
		self.drawPaths([path], fillColor: fillColor, stroke: stroke)
	}

	/// Draw on the current image
	/// - Parameters:
	///   - rect: The rect to fill/stroke
	///   - fillColor: The fill color
	///   - stroke: The stroke style
	@inlinable func drawRect(_ rect: CGRect, fillColor: CGColor? = nil, stroke: Stroke? = nil) {
		self.drawPaths([CGPath(rect: rect, transform: nil)], fillColor: fillColor, stroke: stroke)
	}

	/// Draw on the current image
	/// - Parameters:
	///   - paths: The path(s) to fill/stroke
	///   - fillColor: The fill color
	///   - stroke: The stroke style
	@inlinable func drawPaths(_ paths: [CGPath], fillColor: CGColor?, stroke: Stroke?) {
		self.draw { ctx in
			paths.forEach {
				if let c = fillColor {
					ctx.setFillColor(c)
					ctx.addPath($0)
					ctx.fillPath()
				}
				if let s = stroke {
					ctx.setStrokeColor(s.color)
					if let dash = s.dash {
						ctx.setLineDash(phase: dash.phase, lengths: dash.lengths)
					}
					ctx.setLineWidth(s.lineWidth)
					paths.forEach {
						ctx.addPath($0)
						ctx.strokePath()
					}
				}
			}
		}
	}
}

public extension Bitmap {
	/// Fill the entire bitmap with a color
	/// - Parameter fillColor: The color to fill
	@inlinable func fill(_ fillColor: CGColor) {
		self.fill(self.bounds.path, fillColor)
	}

	/// Create a new bitmap by filling this bitmap with a color
	/// - Parameter fillColor: The color to fill
	/// - Returns: A new bitmap
	@inlinable func filling(with fillColor: CGColor) throws -> Bitmap {
		let copy = try self.copy()
		copy.fill(self.bounds.path, fillColor)
		return copy
	}
}

public extension Bitmap {
	/// Fill a rect in this bitmap
	/// - Parameters:
	///   - path: The path to fill
	///   - fillColor: The color to fill
	@inlinable func fill(_ rect: CGRect, _ fillColor: CGColor) {
		self.fill([rect], fillColor)
	}

	/// Fill rects in this bitmap
	/// - Parameters:
	///   - path: The path to fill
	///   - fillColor: The color to fill
	func fill(_ rects: [CGRect], _ fillColor: CGColor) {
		self.draw { ctx in
			ctx.setFillColor(fillColor)
			ctx.fill(rects)
		}
	}

	/// Fill a path in this bitmap
	/// - Parameters:
	///   - path: The path to fill
	///   - fillColor: The color to fill
	func fill(_ path: CGPath, _ fillColor: CGColor) {
		self.draw { ctx in
			ctx.addPath(path)
			ctx.setFillColor(fillColor)
			ctx.fillPath()
		}
	}

	/// Create a new bitmap by filling a path in this bitmap with a color
	/// - Parameters:
	///   - path: The path to fill
	///   - fillColor: The color to fill
	/// - Returns: A new bitmap with the path filled
	func filling(_ path: CGPath, _ fillColor: CGColor) throws -> Bitmap {
		let copy = try self.copy()
		copy.fill(path, fillColor)
		return copy
	}
}

public extension Bitmap {
	/// Stroke a path in the bitmap
	/// - Parameters:
	///   - path: The path to stroke
	///   - stroke: Stroke parameters
	func stroke(_ path: CGPath, _ stroke: Stroke) {
		self.savingGState { ctx in
			ctx.addPath(path)
			ctx.stroke(stroke)
		}
	}

	/// Stroke a path in the bitmap
	/// - Parameters:
	///   - path: The path to stroke
	///   - stroke: Stroke parameters
	/// - Returns: A new bitmap with the path stroked
	func stroking(_ path: CGPath, _ stroke: Stroke) throws -> Bitmap {
		let copy = try self.copy()
		copy.stroke(path, stroke)
		return copy
	}

	/// Return a new bitmap by stroking a rect on this bitmap
	/// - Parameters:
	///   - rect: The rect to stroke
	///   - stroke: Stroke style
	/// - Returns: A new bitmap
	@inlinable func stroking(_ rect: CGRect, _ stroke: Stroke) throws -> Bitmap {
		try self.stroking(rect.path, stroke)
	}
}

public extension Bitmap {
	/// Stroke multiple rects within the bitmap
	/// - Parameters:
	///   - rects: The rects to stroke
	///   - stroke: Stroke parameters
	func stroke(_ rects: [CGRect], _ stroke: Stroke) {
		self.savingGState { ctx in
			ctx.addRects(rects)
			ctx.stroke(stroke)
		}
	}

	/// Stroke a single rect within the bitmap
	/// - Parameters:
	///   - rect: The rect to stroke
	///   - stroke: Stroke parameters
	@inlinable func stroke(_ rect: CGRect, _ stroke: Stroke) {
		self.stroke([rect], stroke)
	}
}

public extension Bitmap {
	/// Fill and stroke a path on this bitmap
	/// - Parameters:
	///   - path: The path
	///   - fillColor: Fill color
	///   - stroke: Stroke style
	/// - Returns: A new bitmap
	func fillStroke(_ path: CGPath, fillColor: CGColor, stroke: Stroke) {
		self.savingGState { ctx in
			ctx.addPath(path)
			ctx.setFillColor(fillColor)
			ctx.fillPath()

			self.stroke(path, stroke)
		}
	}

	/// Return a new bitmap by filling and stroking a path on this bitmap
	/// - Parameters:
	///   - path: The path
	///   - fillColor: Fill color
	///   - stroke: Stroke style
	/// - Returns: A new bitmap
	func fillingStroking(_ path: CGPath, fillColor: CGColor, stroke: Stroke) throws -> Bitmap {
		let copy = try self.copy()
		copy.fillStroke(path, fillColor: fillColor, stroke: stroke)
		return copy
	}
}

public extension Bitmap {
	/// Draw a simple line on the bitmap
	/// - Parameters:
	///   - from: The start position of the line
	///   - to: The end position of the line
	///   - stroke: The stroke style
	func drawLine(from: CGPoint, to: CGPoint, stroke: Stroke) {
		let pth = CGMutablePath()
		pth.move(to: from)
		pth.addLine(to: to)
		pth.closeSubpath()
		self.stroke(pth, stroke)
	}

	/// Draw a simple line on the bitmap
	@inlinable func drawLine(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, stroke: Stroke) {
		self.drawLine(from: CGPoint(x: x1, y: y1), to: CGPoint(x: x2, y: y2), stroke: stroke)
	}
}

public extension CGContext {
	/// Stroke using the specified stroke style
	func stroke(_ stokeStyle: Bitmap.Stroke) {
		self.setStrokeColor(stokeStyle.color)
		self.setLineWidth(stokeStyle.lineWidth)
		if let dash = stokeStyle.dash {
			self.setLineDash(phase: dash.phase, lengths: dash.lengths)
		}
		self.strokePath()
	}
}
