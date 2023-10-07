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

import XCTest
@testable import Bitmap

let tempContainer = TestOutputContainer(title: "BitmapTestOutput")
private let markdown = MarkdownGenerator()

func imageResource(name: String, extension extn: String) -> CGImage {
	let url = Bundle.module.url(forResource: name, withExtension: extn)!
	return PlatformImage(contentsOfFile: url.path)!.cgImage!
}

func bitmapResource(name: String, extension extn: String) -> Bitmap {
	let image = imageResource(name: name, extension: extn)
	return try! Bitmap(image)
}

final class BitmapTests: XCTestCase {
	override class func setUp() {
		super.setUp()

		let name: String = {
#if os(macOS)
			DeviceModel
#elseif os(watchOS)
			"watchOS"
#elseif os(tvOS)
			"tvOS"
#else
			UIDevice.current.localizedModel
#endif
		}()

		markdown.h2("OS Version")
		markdown.text("\(name) (\(OperatingSystemVersion))")
		markdown.br()
	}

	override class func tearDown() {
		super.tearDown()

		let destination = try! tempContainer.testFilenameWithName("bitmap.markdown")
		try! markdown.write(to: destination)
	}

	func testExample() throws {

		markdown.h2("Creation")

		var bitmap = try Bitmap(width: 100, height: 100)
		XCTAssertEqual(100, bitmap.width)

		bitmap.setPixel(x: 0, y: 0, color: Bitmap.RGBA.red)
		bitmap.setPixel(x: 0, y: 99, color: Bitmap.RGBA.magenta)
		bitmap[99, 99] = Bitmap.RGBA.cyan
		bitmap.setPixel(x: 99, y: 0, color: Bitmap.RGBA.yellow)

		try markdown.image(bitmap, linked: true)

		let d2 = bitmap.getPixel(x: 10, y: 10)
		XCTAssertEqual(0, d2.r)
		XCTAssertEqual(0, d2.g)
		XCTAssertEqual(0, d2.b)
		XCTAssertEqual(0, d2.a)

		// Draw a square black rect
		bitmap.draw { ctx in
			ctx.setFillColor(.black)
			ctx.fill([CGRect(x: 5, y: 5, width: 20, height: 20)])
		}

		// Check the pixel has been updated
		let d3 = bitmap.getPixel(x: 10, y: 10)
		XCTAssertEqual(0, d3.r)
		XCTAssertEqual(0, d3.g)
		XCTAssertEqual(0, d3.b)
		XCTAssertEqual(255, d3.a)

		let data = bitmap.rawPixels
		XCTAssertEqual(10000, data.count)

		try markdown.image(bitmap, linked: true)

		let image = try XCTUnwrap(bitmap.cgImage)
		XCTAssertEqual(100, image.width)
		XCTAssertEqual(100, image.height)

		let paddedBitmap = try bitmap.padding(40, backgroundColor: .black)
		try markdown.image(paddedBitmap, linked: true)
		XCTAssertEqual(180, paddedBitmap.width)
		XCTAssertEqual(180, paddedBitmap.height)

		markdown.br()
	}

	func testLine() throws {
		markdown.h2("Drawing lines")

		var bitmap = try Bitmap(width: 200, height: 200)
		bitmap.drawLine(x1: 10, y1: 10, x2: 10, y2: 190, stroke: Bitmap.Stroke())

		let s1 = Bitmap.Stroke(color: CGColor(red: 1, green: 0, blue: 1, alpha: 0.5), lineWidth: 4, dash: .init(lengths: [2, 5]))
		bitmap.drawLine(x1: 50, y1: 50, x2: 100, y2: 120, stroke: s1)

		try markdown.image(bitmap, linked: true)

		markdown.br()
	}

	private func complexPath() -> CGPath {
		let bezierPath = CGMutablePath()
		bezierPath.move(to: CGPoint(x: 207, y: 42))
		bezierPath.addCurve(to: CGPoint(x: 196.8, y: 25.71), control1: CGPoint(x: 207, y: 34.8), control2: CGPoint(x: 202.83, y: 28.59))
		bezierPath.addLine(to: CGPoint(x: 196.44, y: 25.55))
		bezierPath.addCurve(to: CGPoint(x: 192.77, y: 24.36), control1: CGPoint(x: 195.28, y: 25.02), control2: CGPoint(x: 194.05, y: 24.62))
		bezierPath.addCurve(to: CGPoint(x: 191.97, y: 18.62), control1: CGPoint(x: 192.78, y: 22.12), control2: CGPoint(x: 192.49, y: 20.32))
		bezierPath.addCurve(to: CGPoint(x: 186.02, y: 9.88), control1: CGPoint(x: 190.89, y: 15.13), control2: CGPoint(x: 188.79, y: 12.09))
		bezierPath.addCurve(to: CGPoint(x: 182.57, y: 7.71), control1: CGPoint(x: 184.96, y: 9.03), control2: CGPoint(x: 183.8, y: 8.3))
		bezierPath.addCurve(to: CGPoint(x: 175, y: 6), control1: CGPoint(x: 180.27, y: 6.61), control2: CGPoint(x: 177.71, y: 6))
		bezierPath.addCurve(to: CGPoint(x: 157.22, y: 24), control1: CGPoint(x: 165.18, y: 6), control2: CGPoint(x: 157.22, y: 14.06))
		bezierPath.addLine(to: CGPoint(x: 157.23, y: 24.36))
		bezierPath.addCurve(to: CGPoint(x: 147.95, y: 29.54), control1: CGPoint(x: 153.62, y: 25.1), control2: CGPoint(x: 150.4, y: 26.95))
		bezierPath.addCurve(to: CGPoint(x: 143, y: 42), control1: CGPoint(x: 144.88, y: 32.77), control2: CGPoint(x: 143, y: 37.16))
		bezierPath.addCurve(to: CGPoint(x: 160.78, y: 60), control1: CGPoint(x: 143, y: 51.94), control2: CGPoint(x: 150.96, y: 60))
		bezierPath.addCurve(to: CGPoint(x: 175, y: 52.8), control1: CGPoint(x: 166.59, y: 60), control2: CGPoint(x: 171.76, y: 57.17))
		bezierPath.addCurve(to: CGPoint(x: 189.22, y: 60), control1: CGPoint(x: 178.24, y: 57.17), control2: CGPoint(x: 183.41, y: 60))
		bezierPath.addCurve(to: CGPoint(x: 207, y: 42), control1: CGPoint(x: 199.04, y: 60), control2: CGPoint(x: 207, y: 51.94))
		bezierPath.closeSubpath()
		bezierPath.move(to: CGPoint(x: 175.5, y: 43))
		bezierPath.addCurve(to: CGPoint(x: 166, y: 33.5), control1: CGPoint(x: 170.25, y: 43), control2: CGPoint(x: 166, y: 38.75))
		bezierPath.addCurve(to: CGPoint(x: 166.76, y: 29.76), control1: CGPoint(x: 166, y: 32.17), control2: CGPoint(x: 166.27, y: 30.91))
		bezierPath.addCurve(to: CGPoint(x: 175.5, y: 24), control1: CGPoint(x: 168.22, y: 26.37), control2: CGPoint(x: 171.58, y: 24))
		bezierPath.addCurve(to: CGPoint(x: 185, y: 33.5), control1: CGPoint(x: 180.75, y: 24), control2: CGPoint(x: 185, y: 28.25))
		bezierPath.addCurve(to: CGPoint(x: 175.5, y: 43), control1: CGPoint(x: 185, y: 38.75), control2: CGPoint(x: 180.75, y: 43))
		bezierPath.closeSubpath()
		return bezierPath
	}

#if canImport(CoreImage)
	func testCheckerboard() throws {

		markdown.h2("Checkerboard generate")

		markdown.raw("| check 1 | check 2 |\n")
		markdown.raw("|----|----|\n")
		markdown.raw("|")

		let check1 = try Bitmap.Checkerboard(width: 300, height: 300)
		try markdown.image(check1, linked: true)

		markdown.raw("|")

		let check2 = try Bitmap.Checkerboard(
			width: 640,
			height: 480,
			checkSize: 100,
			color0: .clear,
			color1: .init(gray: 0.5, alpha: 0.3)
		)
		try markdown.image(check2, linked: true)

		markdown.raw("|")

		markdown.br()
	}
#endif

	func testPunchHole() throws {

		markdown.h2("Punch hole")

		markdown.raw("| original | punched |\n")
		markdown.raw("|----|----|\n")
		markdown.raw("|")

		let bitmap = bitmapResource(name: "gps-image", extension: "jpg")
		try markdown.image(bitmap.cgImage!, linked: true)

		markdown.raw("|")

		let punch = CGRect(x: 50, y: 50, width: 70, height: 150).insetBy(dx: 0.5, dy: 0.5)
		let punched = try bitmap.punchingTransparentHole(path: punch.path)
			.drawingPath(
				CGPath(rect: punch, transform: nil),
				fillColor: nil,
				stroke: Bitmap.Stroke(color: .white, lineWidth: 1)
			)
			.punchingTransparentHole(path: complexPath())

		var total = try Bitmap(size: bitmap.size) { ctx in
			ctx.setFillColor(red: 1, green: 0, blue: 0, alpha: 0.3)
			ctx.fill([bitmap.bounds])
		}

		try total.drawBitmap(punched, atPoint: .zero)
		try markdown.image(total, linked: true)

		markdown.raw("|")

		markdown.br()
	}

	func testPixelAccesses() throws {

		markdown.h2("Pixel access")

		let arr = [
			Bitmap.RGBA(r: 255, g: 0, b: 0, a: 255),
			Bitmap.RGBA(r: 0, g: 0, b: 255, a: 255),
			Bitmap.RGBA(r: 0, g: 255, b: 0, a: 255),
			Bitmap.RGBA(r: 255, g: 0, b: 255, a: 255),
			Bitmap.RGBA(r: 0, g: 255, b: 255, a: 255),
			Bitmap.RGBA(r: 255, g: 255, b: 0, a: 255),
		]
		let ra = Bitmap.RGBAData(width: 2, height: 3, pixelsData: arr)
		XCTAssertEqual(24, ra.rgbaBytes.count)

		let bitmap = try Bitmap(ra)
		let image = try XCTUnwrap(bitmap.cgImage)
		try markdown.image(image, linked: true)

		// The subscript works with bottom left coordinates

		XCTAssertEqual(arr[0], bitmap[0, 2])
		XCTAssertEqual(arr[1], bitmap[1, 2])
		XCTAssertEqual(arr[2], bitmap[0, 1])
		XCTAssertEqual(arr[3], bitmap[1, 1])
		XCTAssertEqual(arr[4], bitmap[0, 0])
		XCTAssertEqual(arr[5], bitmap[1, 0])

		let raw = bitmap.rawPixels
		XCTAssertEqual(6, raw.count)
		XCTAssertEqual(arr, raw)

		let pix = bitmap.rgbaBytes
		XCTAssertEqual(24, pix.count)

		markdown.br()
	}

	func testDrawing() throws {
		markdown.h2("Basic drawing")

		markdown.raw("A basic red square, stroked with gray, on a transparent background")
		markdown.br()

		var bitmap = try Bitmap(width: 255, height: 255)
		assert(bitmap.width == 255)
		assert(bitmap.width == 255)

		bitmap.drawRect(
			CGRect(x: 50, y: 50, width: 50, height: 50),
			fillColor: CGColor.red,
			stroke: Bitmap.Stroke(color: CGColor(gray: 0.5, alpha: 1.0), lineWidth: 2)
		)
		let image = try XCTUnwrap(bitmap.cgImage)
		try markdown.image(image, linked: true)
		markdown.br()
	}

	func testShadow() throws {
		markdown.h2("Shadow drawing")

		var bitmap = try Bitmap(width: 255, height: 255)
		bitmap.applyingShadow(Bitmap.Shadow()) { bitmap in
			bitmap.fill(CGRect(x: 10, y: 10, width: 100, height: 100).path, .init(gray: 0.5, alpha: 1))
		}

		bitmap.applyingShadow(Bitmap.Shadow(offset: CGSize(width: -3, height: 3), color: CGColor.blue)) { bitmap in
			bitmap.stroke(
				CGRect(x: 110, y: 110, width: 100, height: 100).path,
				Bitmap.Stroke(color: CGColor.red, lineWidth: 2)
			)
		}

		let image = try XCTUnwrap(bitmap.cgImage)
		try markdown.image(image, linked: true)
		markdown.br()
	}

	func testImage() throws {
		markdown.h2("Drawing images")

		let image = imageResource(name: "apple-logo-dark", extension: "png")

		markdown.raw("| axes-independent | aspect-fit | aspect-fill |\n")
		markdown.raw("|----|----|----|\n")

		markdown.raw("|")

		do {
			var bitmap = try Bitmap(width: 200, height: 200)
			bitmap.drawImage(image, in: CGRect(x: 50, y: 50, width: 100, height: 100))
			try markdown.image(bitmap, linked: true)
		}
		markdown.raw("|")
		do {
			var bitmap = try Bitmap(width: 200, height: 200)
			bitmap.drawImage(image, in: CGRect(x: 50, y: 50, width: 100, height: 100), scaling: .aspectFit)
			try markdown.image(bitmap, linked: true)
		}
		markdown.raw("|")
		do {
			var bitmap = try Bitmap(width: 200, height: 200)
			bitmap.drawImage(image, in: CGRect(x: 50, y: 50, width: 100, height: 100), scaling: .aspectFill)
			try markdown.image(bitmap, linked: true)
		}
		markdown.raw("|")
		markdown.br()
	}

	func testTintRect() throws {
		markdown.h2("Tinting a rectange within a bitmap")

		markdown.raw("| original | tint1 | tint2 |\n")
		markdown.raw("|-----|-----|-----|\n")
		markdown.raw("|")

		let orig = bitmapResource(name: "gps-image", extension: "jpg")
		let cgorig = try XCTUnwrap(orig.cgImage)
		try markdown.image(cgorig, linked: true)

		markdown.raw("|")

		let tint1 = try orig.tinting(with: CGColor(red: 1, green: 0, blue: 0, alpha: 1),
											  in: CGRect(x: 50, y: 50, width: 200, height: 200))
		try markdown.image(tint1, linked: true)

		markdown.raw("|")

		let tint2 = try tint1.tinting(with: CGColor(red: 0, green: 0, blue: 1, alpha: 1),
												in: CGRect(x: 150, y: 150, width: 40, height: 60))
		try markdown.image(tint2, linked: true)

		markdown.raw("|")

		markdown.br()
	}

	func testRemoveTransparency() throws {
		markdown.h2("Removing transparency information from an image")

		markdown.raw("| original | transparency removed |\n")
		markdown.raw("|-----|-----|\n")
		markdown.raw("|")
		var orig = bitmapResource(name: "apple-logo-dark", extension: "png")
		try markdown.image(orig, linked: true)
		markdown.raw("|")
		try orig.removeTransparency(backgroundColor: CGColor.red)
		try markdown.image(orig, linked: true)
		markdown.raw("|")
		markdown.br()
	}

	func testRotating() throws {
		markdown.h2("Rotating an image")

		markdown.raw("| original | rotated1 | rotated2 |\n")
		markdown.raw("|-----|-----|-----|\n")
		markdown.raw("|")
		let orig = bitmapResource(name: "gps-image", extension: "jpg")
		try markdown.image(orig, linked: true)
		markdown.raw("|")
		let rotated1 = try orig.rotating(by: 1.4)
		try markdown.image(rotated1, linked: true)
		markdown.raw("|")
		let rotated2 = try orig.rotating(by: -2.6)
		try markdown.image(rotated2, linked: true)
		markdown.raw("|")
		markdown.br()
	}

	func testGrayscale() throws {
		markdown.h2("Grayscale")

		markdown.raw("| original | grayscale |\n")
		markdown.raw("|-----|-----|\n")
		markdown.raw("|")
		let bitmap = bitmapResource(name: "gps-image", extension: "jpg")
		try markdown.image(bitmap, linked: true)
		markdown.raw("|")
		let gr = try bitmap.grayscaling()
		try markdown.image(gr, linked: true)
		markdown.raw("|")
		markdown.br()
	}

	func testTinting() throws {
		markdown.h2("Tinting with transparency")

		let bitmap = bitmapResource(name: "gps-image", extension: "jpg")
		let bitmap2 = bitmapResource(name: "apple-logo-white", extension: "png")

		markdown.raw("| original | tinted |\n")
		markdown.raw("|-----|-----|\n")

		do {
			markdown.raw("|")
			try markdown.image(bitmap, linked: true)
			markdown.raw("|")

			// No transparency
			let gr = try bitmap.tinting(with: CGColor(red: 0, green: 1, blue: 0, alpha: 1))
			try markdown.image(gr, linked: true)
		}
		markdown.raw("|\n")
		do {
			markdown.raw("|")
			try markdown.image(bitmap2, linked: true)
			markdown.raw("|")

			// transparency
			let gr = try bitmap2.tinting(with: CGColor(red: 0 , green: 1, blue: 0, alpha: 1))
			try markdown.image(gr, linked: true)
		}
		markdown.raw("|\n")
		markdown.br()
	}

	func testClipping() throws {
		markdown.h2("Clipping")

		var bitmap = bitmapResource(name: "gps-image", extension: "jpg")
		let bounds = bitmap.bounds

		markdown.raw("| original | clip 1 | clip 2\n")
		markdown.raw("|-----|-----|-----|\n")
		markdown.raw("|")

		try markdown.image(bitmap, linked: true)

		markdown.raw("|")

		bitmap.clipped(to: CGRect(x: 10, y: 10, width: 50, height: 50).ellipsePath) { ctx in
			ctx.setFillColor(.white)
			ctx.fill([bounds])
		}

		try markdown.image(bitmap, linked: true)

		markdown.raw("|")

		let n = try bitmap.clipping(to: CGPath(roundedRect: CGRect(x: 50, y: 150, width: 150, height: 50), cornerWidth: 4, cornerHeight: 3, transform: nil)) { ctx in
			ctx.setFillColor(CGColor(red: 1, green: 0, blue: 1, alpha: 0.7))
			ctx.fill([bounds])
		}

		try markdown.image(n, linked: true)

		markdown.raw("|")
		markdown.br()
	}

	func testrgbaByteComponents() throws {
		let pixel = Bitmap.RGBA(rgbaByteComponents: [10, 30, 50, 90])
		XCTAssertEqual(pixel, Bitmap.RGBA(r: 10, g: 30, b: 50, a: 90))

		let pixels = try XCTUnwrap(Bitmap.RGBA.from(rgbaArray: [10, 30, 50, 90, 110, 130, 150, 190]))
		XCTAssertEqual(pixels.count, 2)
		XCTAssertEqual(pixels[0], Bitmap.RGBA(r: 10, g: 30, b: 50, a: 90))
		XCTAssertEqual(pixels[1], Bitmap.RGBA(r: 110, g: 130, b: 150, a: 190))
	}

	func testPut() throws {

		var bitmap = try Bitmap(width: 3, height: 3)
		bitmap.setPixel(x: 0, y: 0, color: .red)
		bitmap.setPixel(x: 1, y: 1, color: .green)
		bitmap.setPixel(x: 2, y: 2, color: .blue)

		let ima = try XCTUnwrap(bitmap.cgImage)
		Swift.print(ima)

		// pixels are represented from top-left to bottom-right
		let pixels = bitmap.rawPixels
		XCTAssertEqual(pixels[2], .blue)
		XCTAssertEqual(pixels[4], .green)
		XCTAssertEqual(pixels[6], .red)
	}

	func testDrawStrings() throws {

		markdown.h2("Drawing text")
		markdown.text("\(#function)")
		markdown.br()

		markdown.raw("| 1 | 2 | 3 | 4 |\n")
		markdown.raw("|-----|-----|-----|-----|\n")
		markdown.raw("|")

		do {
			var bitmap = try Bitmap(width: 400, height: 400)
			bitmap.drawText("Hello", color: .init(gray: 0.5, alpha: 1.0), position: .zero)
			try markdown.image(bitmap, linked: true)
		}

		markdown.raw("|")

		do {
			var bitmap = try Bitmap(width: 400, height: 400)
			bitmap.drawText(
				"Hello there, how are you? This is exciting",
				color: CGColor(gray: 0.5, alpha: 1.0),
				path: CGRect(x: 100, y: 100, width: 50, height: 50).path
			)
			try markdown.image(bitmap, linked: true)

		}
		markdown.raw("|")
		do {
			var bitmap2 = try Bitmap(width: 400, height: 400)
			bitmap2.drawText(
				"Hello there, how are you? This is exciting",
				color: CGColor(gray: 0.5, alpha: 1.0)
			)
			try markdown.image(bitmap2, linked: true)
		}
		markdown.raw("|")
		do {
			var bitmap3 = try Bitmap(width: 400, height: 400)
			bitmap3.applyingShadow(Bitmap.Shadow()) { bitmap in
				let f = CTFont(.label, size: 24)
				let atr = NSAttributedString(
					string: "Hello there, how are you? This is exciting",
					attributes: [.font: f]
				)
				bitmap.drawText(atr)
			}
			try markdown.image(bitmap3, linked: true)
		}
		markdown.raw("|")
		markdown.br()
	}

	func testMasking() throws {
		markdown.h2("Masking using image")

		markdown.raw("| original | masked 1 |\n")
		markdown.raw("|----|----|\n")
		markdown.raw("|")

		let cmykImage = bitmapResource(name: "cmyk", extension: "jpg")
		try markdown.image(cmykImage, linked: true)

		markdown.raw("|")

		let maskImage = bitmapResource(name: "cat-icon", extension: "png")
		let masked = try cmykImage.masking(using: maskImage)

		try markdown.image(masked, linked: true)

		markdown.raw("|")
		markdown.br()
	}

	func testResize() throws {
		markdown.h2("Adjust bitmap size")

		markdown.text("Adjust a bitmap maintaining the original image content")
		markdown.br()

		markdown.raw("| original | adjust 1 |\n")
		markdown.raw("|----|----|\n")
		markdown.raw("|")

		let maskImage = bitmapResource(name: "gps-image", extension: "jpg")

		try markdown.image(maskImage, linked: true)

		markdown.raw("|")

		let resized = try maskImage.adjustingSize(to: CGSize(width: 100, height: 100))
		try markdown.image(resized, linked: true)

		markdown.raw("|")
		markdown.br()
	}

	func testFlip() throws {
		markdown.h2("Flipping an image")

		markdown.raw("| original | flip h | flip v | flip both |\n")
		markdown.raw("|----|----|----|----|\n")
		markdown.raw("|")

		let orig = bitmapResource(name: "apple-logo-dark", extension: "png")
		try markdown.image(orig, linked: true)

		markdown.raw("|")

		let fh = try orig.flipping(.horizontally)
		try markdown.image(fh, linked: true)

		markdown.raw("|")

		let fv = try orig.flipping(.vertically)
		try markdown.image(fv, linked: true)

		markdown.raw("|")

		let fb = try orig.flipping(.both)
		try markdown.image(fb, linked: true)

		markdown.raw("|")
		markdown.br()
	}

	func testStrokeDash() throws {

		markdown.h2("Stroke/dash")

		markdown.raw("| 1 | 2 |\n")
		markdown.raw("|----|----|\n")
		markdown.raw("|")

		var image = try Bitmap(width: 200, height: 200)
		image.stroke(
			CGRect(x: 50, y: 50, width: 100, height: 100).path,
			Bitmap.Stroke(
				color: CGColor.red,
				lineWidth: 3.0,
				dash: Bitmap.Stroke.Dash(lengths: [6, 6], phase: 0)
			)
		)

		try markdown.image(image, linked: true)

		markdown.raw("|")

		image.fillStroke(
			CGPath(ellipseIn: CGRect(x: 10, y: 10, width: 30, height: 30), transform: nil),
			fillColor: CGColor(srgbRed: 0, green: 0.5, blue: 0.8, alpha: 0.6),
			stroke: Bitmap.Stroke(
				color: CGColor.yellow,
				lineWidth: 1.0,
				dash: Bitmap.Stroke.Dash(lengths: [3, 1], phase: 0.6)
			)
		)

		try markdown.image(image, linked: true)
		
		markdown.raw("|")
		markdown.br()
	}

	func testCropping() throws {

		markdown.h2("Cropping/Masking to a path")

		markdown.raw("| original | cropped | bezier within image | path mask |\n")
		markdown.raw("|----|----|----|----|\n")
		markdown.raw("|")

		let orig = bitmapResource(name: "food", extension: "jpg")
		let origcg = try XCTUnwrap(orig.cgImage)

		try markdown.image(origcg, linked: true)

		markdown.raw("|")

		let bezierPath = CGMutablePath()
		bezierPath.move(to: CGPoint(x: 146.5, y: 91.5))
		bezierPath.addCurve(to: CGPoint(x: 222.5, y: 36.5), control1: CGPoint(x: 159.5, y: 49.5), control2: CGPoint(x: 222.5, y: 36.5))
		bezierPath.addLine(to: CGPoint(x: 238.5, y: 91.5))
		bezierPath.addCurve(to: CGPoint(x: 215.5, y: 169.5), control1: CGPoint(x: 238.5, y: 91.5), control2: CGPoint(x: 315.5, y: 174.5))
		bezierPath.addCurve(to: CGPoint(x: 183.5, y: 111.5), control1: CGPoint(x: 115.5, y: 164.5), control2: CGPoint(x: 183.5, y: 111.5))
		bezierPath.addLine(to: CGPoint(x: 146.5, y: 91.5))
		bezierPath.closeSubpath()

		let cropped = try orig.cropping(to: bezierPath)
		try markdown.image(cropped, linked: true)

		markdown.raw("|")

		var copy = try orig.copy()
		let tinted = try cropped.tinting(with: CGColor(red: 0, green: 0, blue: 1, alpha: 1))
		
		try copy.drawBitmap(tinted, atPoint: bezierPath.boundingBoxOfPath.origin)

		try markdown.image(copy, linked: true)

		markdown.raw("|")

		var masked = try orig.copy()
		try masked.mask(using: bezierPath)
		try markdown.image(masked, linked: true)

		markdown.raw("|")

		markdown.br()
	}

	func testColors() throws {
		let c1 = try Bitmap.RGBA(.red)
		XCTAssertEqual(Bitmap.RGBA.red, c1)
		let c2 = try Bitmap.RGBA(.red.copy(alpha: 0.1)!)
		XCTAssertEqual(Bitmap.RGBA(r: 255, g: 0, b: 0, a: 25), c2)
		let c3 = try Bitmap.RGBA(.cyan)
		XCTAssertEqual(Bitmap.RGBA.cyan, c3)

		let c4 = try Bitmap.RGBA(CGColor(gray: 0.5, alpha: 1))
		XCTAssertEqual(Bitmap.RGBA(r: 145, g: 145, b: 145, a: 255), c4)
		let c5 = try Bitmap.RGBA(CGColor(genericCMYKCyan: 0, magenta: 1, yellow: 0, black: 0, alpha: 0.2))
		XCTAssertEqual(Bitmap.RGBA(r: 216, g: 17, b: 125, a: 51), c5)
	}

	func testEraseAll() throws {
		markdown.h2("Erasing")

		markdown.raw("| original | erased |\n")
		markdown.raw("|----|----|\n")
		markdown.raw("|")

		var orig = bitmapResource(name: "food", extension: "jpg")
		try markdown.image(orig, linked: true)
		markdown.raw("|")
		orig.eraseAll()
		try markdown.image(orig, linked: true)
		markdown.raw("|")
		markdown.br()
	}

	func testFillAll() throws {
		markdown.h2("Fill All")

		markdown.raw("| original | filled |\n")
		markdown.raw("|----|----|\n")
		markdown.raw("|")

		var orig = bitmapResource(name: "food", extension: "jpg")
		try markdown.image(orig, linked: true)
		markdown.raw("|")
		orig.fill(.yellow.copy(alpha: 0.3)!)
		try markdown.image(orig, linked: true)
		markdown.raw("|")
		markdown.br()
	}
}
