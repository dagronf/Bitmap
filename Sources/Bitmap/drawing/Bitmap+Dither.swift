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

// https://surma.dev/things/ditherpunk/

public extension Bitmap {
	/// Types of dithering
	enum DitherType {
		case atkinson
		case floydSteinberg
		case jarvisJudiceNinke
	}

	/// Black/white dither the image
	/// - Parameter ditherType: The type of dithering to apply
	/// - Returns: New bitmap
	func dithering(_ ditherType: DitherType) throws -> Bitmap {
		var gray = try self.grayscaling()

		for y in (0 ..< self.height) {
			for x in (0 ..< self.width) {
				// The existing grayscale color at the pixel
				let oldPixel = gray[x, y].r

				// Determine new pixel value (0 or 255)
				let newPixel: Int = oldPixel < 128 ? 0 : 255

				// Calculate error
				let error = Int(oldPixel) - Int(newPixel)

				gray[x, y] = RGBA(r: UInt8(newPixel), g: UInt8(newPixel), b: UInt8(newPixel))

				switch ditherType {
				case .atkinson:
					atkinsonDither(x: x, y: y, error: error, bitmap: &gray)
				case .floydSteinberg:
					floydSteinbergDither(x: x, y: y, error: error, bitmap: &gray)
				case .jarvisJudiceNinke:
					jarvisJudiceNinkeDither(x: x, y: y, error: error, bitmap: &gray)
				}
			}
		}
		return gray
	}
}

public extension Bitmap {
	/// Black/white dither this image
	/// - Parameter ditherType: The type of dithering to apply
	@inlinable func dither(_ ditherType: DitherType) throws {
		try self.replaceContent(with: try self.dithering(ditherType))
	}
}

// MARK: - Implementation

private func atkinsonDither(x: Int, y: Int, error: Int, bitmap: inout Bitmap) {
	// Atkinson distribution matrix - distribute 3/8ths of error to surrounding pixels
	// 1/8 error goes to each of these neighbors: (x+1,y), (x+2,y), (x-1,y+1), (x,y+1), (x+1,y+1), (x,y+2)
	let errorFraction = error / 8

	// Distribute the error to neighboring pixels
	spreadError(x: x + 1, y: y, error: errorFraction, bitmap: &bitmap)
	spreadError(x: x + 2, y: y, error: errorFraction, bitmap: &bitmap)
	spreadError(x: x - 1, y: y + 1, error: errorFraction, bitmap: &bitmap)
	spreadError(x: x, y: y + 1, error: errorFraction, bitmap: &bitmap)
	spreadError(x: x + 1, y: y + 1, error: errorFraction, bitmap: &bitmap)
	spreadError(x: x, y: y + 2, error: errorFraction, bitmap: &bitmap)
}

private func floydSteinbergDither(x: Int, y: Int, error: Int, bitmap: inout Bitmap) {
	// Atkinson distribution matrix - distribute 3/8ths of error to surrounding pixels
	// 1/8 error goes to each of these neighbors: (x+1,y), (x+2,y), (x-1,y+1), (x,y+1), (x+1,y+1), (x,y+2)
	let errorFraction = error / 16

	// Distribute the error to neighboring pixels
	spreadError(x: x + 1, y: y, error:  7 * errorFraction, bitmap: &bitmap)
	spreadError(x: x - 1, y: y + 1, error: 3 * errorFraction, bitmap: &bitmap)
	spreadError(x: x, y: y + 1 , error: 5 * errorFraction, bitmap: &bitmap)
	spreadError(x: x + 1, y: y + 1 , error: 1 * errorFraction, bitmap: &bitmap)
}

private func jarvisJudiceNinkeDither(x: Int, y: Int, error: Int, bitmap: inout Bitmap) {
	// Atkinson distribution matrix - distribute 3/8ths of error to surrounding pixels
	// 1/8 error goes to each of these neighbors: (x+1,y), (x+2,y), (x-1,y+1), (x,y+1), (x+1,y+1), (x,y+2)
	let errorFraction = error / 48

	// Distribute the error to neighboring pixels
	spreadError(x: x + 1, y: y, error:  7 * errorFraction, bitmap: &bitmap)
	spreadError(x: x + 2, y: y, error:  5 * errorFraction, bitmap: &bitmap)

	spreadError(x: x - 2, y: y + 1, error: 3 * errorFraction, bitmap: &bitmap)
	spreadError(x: x - 1, y: y + 1, error: 5 * errorFraction, bitmap: &bitmap)
	spreadError(x: x    , y: y + 1, error: 7 * errorFraction, bitmap: &bitmap)
	spreadError(x: x + 1, y: y + 1, error: 5 * errorFraction, bitmap: &bitmap)
	spreadError(x: x + 2, y: y + 1, error: 3 * errorFraction, bitmap: &bitmap)

	spreadError(x: x - 2, y: y + 2, error: 1 * errorFraction, bitmap: &bitmap)
	spreadError(x: x - 1, y: y + 2, error: 3 * errorFraction, bitmap: &bitmap)
	spreadError(x: x    , y: y + 2, error: 5 * errorFraction, bitmap: &bitmap)
	spreadError(x: x + 1, y: y + 2, error: 3 * errorFraction, bitmap: &bitmap)
	spreadError(x: x + 2, y: y + 2, error: 1 * errorFraction, bitmap: &bitmap)
}

/// Helper function to distribute error to a specific pixel
private func spreadError(x: Int, y: Int, error: Int, bitmap: inout Bitmap) {
	// Check boundaries
	guard x >= 0 && x < bitmap.width && y >= 0 && y < bitmap.height else { return }

	let og = Int(bitmap[x, y].r)

	// Add error and clip to valid range
	let ng = UInt8((og + error).clamped(to: 0 ... 255))
	bitmap[x, y] = Bitmap.RGBA(r: ng, g: ng, b: ng)
}
