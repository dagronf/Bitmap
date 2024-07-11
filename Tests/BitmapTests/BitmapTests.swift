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

func checked(_ size: CGSize) throws -> Bitmap { try checked(Int(size.width), Int(size.height)) }
func checked(_ width: Int, _ height: Int) throws -> Bitmap {
	try Bitmap.Checkerboard(
		width: width,
		height: height,
		checkSize: 4,
		color0: CGColor(gray: 0, alpha: 0.05),
		color1: CGColor(gray: 0, alpha: 0.15)
	)
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

		let bitmap = try Bitmap(width: 100, height: 100)
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

		let bitmap = try Bitmap(width: 200, height: 200)
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

		let bitmap = try Bitmap(width: 255, height: 255)
		assert(bitmap.width == 255)
		assert(bitmap.width == 255)

		bitmap.drawRect(
			CGRect(x: 50, y: 50, width: 80, height: 100),
			fillColor: CGColor.red,
			stroke: Bitmap.Stroke(color: CGColor(gray: 0.5, alpha: 1.0), lineWidth: 2)
		)
		let image = try XCTUnwrap(bitmap.cgImage)
		try markdown.image(image, linked: true)
		markdown.br()
	}

	func testShadow() throws {
		markdown.h2("Shadow drawing")

		let bitmap = try Bitmap(width: 255, height: 255)
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
			let bitmap = try Bitmap(width: 200, height: 200)
			bitmap.drawImage(image, in: CGRect(x: 50, y: 50, width: 100, height: 100))
			try markdown.image(bitmap, linked: true)
		}
		markdown.raw("|")
		do {
			let bitmap = try Bitmap(width: 200, height: 200)
			bitmap.drawImage(image, in: CGRect(x: 50, y: 50, width: 100, height: 100), scaling: .aspectFit)
			try markdown.image(bitmap, linked: true)
		}
		markdown.raw("|")
		do {
			let bitmap = try Bitmap(width: 200, height: 200)
			bitmap.drawImage(image, in: CGRect(x: 50, y: 50, width: 100, height: 100), scaling: .aspectFill)
			try markdown.image(bitmap, linked: true)
		}
		markdown.raw("|")
		markdown.br()
	}

	func testTintRect() throws {
		markdown.h2("Tinting a rectangle within a bitmap")

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

		do {
			markdown.raw("| original | transparency removed |\n")
			markdown.raw("|-----|-----|\n")
			markdown.raw("|")
			let orig = bitmapResource(name: "apple-logo-dark", extension: "png")
			try markdown.image(orig, linked: true)
			markdown.raw("|")
			try orig.removeTransparency(backgroundColor: CGColor.red)
			try markdown.image(orig, linked: true)
			markdown.raw("|")
			markdown.br()
		}

		do {
			markdown.raw("| original | black mapped to transparency |\n")
			markdown.raw("|-----|-----|\n")
			markdown.raw("|")
			let orig = bitmapResource(name: "p3test", extension: "ppm")
			try markdown.image(orig.scaling(multiplier: 32), linked: true)
			markdown.raw("|")
			let px = try orig.mappingColorToTransparency(Bitmap.RGBA(r: 0, g: 0, b: 0))
			try markdown.image(px.scaling(multiplier: 32), linked: true)

			markdown.raw("|")
			markdown.br()
		}
	}

	func testRotating() throws {
		markdown.h2("Rotating an image")

		markdown.raw("| original | rotated1 | rotated2 | rotated3 |\n")
		markdown.raw("|-----|-----|-----|-----|\n")
		markdown.raw("|")
		let orig = bitmapResource(name: "gps-image", extension: "jpg")
		try markdown.image(orig, linked: true)
		markdown.raw("|")
		let rotated1 = try orig.rotating(by: .radians(1.4))
		try markdown.image(rotated1, linked: true)
		markdown.raw("|")
		let rotated2 = try orig.rotating(by: .radians(-2.6))
		try markdown.image(rotated2, linked: true)
		markdown.raw("|")
		let rotated3 = try orig.rotating(by: .degrees(270))
		try markdown.image(rotated3, linked: true)
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

		let bitmap = bitmapResource(name: "gps-image", extension: "jpg")
		let bounds = bitmap.bounds

		markdown.raw("| original | clip 1 | clip 2\n")
		markdown.raw("|-----|-----|-----|\n")
		markdown.raw("|")

		try markdown.image(bitmap, linked: true)

		markdown.raw("|")

		bitmap.clip(to: CGRect(x: 10, y: 10, width: 50, height: 50).ellipsePath) { ctx in
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

		let bitmap = try Bitmap(width: 3, height: 3)
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
			let bitmap = try Bitmap(width: 400, height: 400)
			bitmap.drawText("Hello", color: .init(gray: 0.5, alpha: 1.0), position: .zero)
			try markdown.image(bitmap, linked: true)
		}

		markdown.raw("|")

		do {
			let bitmap = try Bitmap(width: 400, height: 400)
			bitmap.drawText(
				"Hello there, how are you? This is exciting",
				color: CGColor(gray: 0.5, alpha: 1.0),
				path: CGRect(x: 100, y: 100, width: 50, height: 50).path
			)
			try markdown.image(bitmap, linked: true)

		}
		markdown.raw("|")
		do {
			let bitmap2 = try Bitmap(width: 400, height: 400)
			bitmap2.drawText(
				"Hello there, how are you? This is exciting",
				color: CGColor(gray: 0.5, alpha: 1.0)
			)
			try markdown.image(bitmap2, linked: true)
		}
		markdown.raw("|")
		do {
			let bitmap3 = try Bitmap(width: 400, height: 400)
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

		let image = try Bitmap(width: 200, height: 200)
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

		try markdown.image(orig, linked: true)

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

		do {
			let copy = try orig.copy()
			let tinted = try cropped.tinting(with: CGColor(red: 0, green: 0, blue: 1, alpha: 1))
			try copy.drawBitmap(tinted, atPoint: bezierPath.boundingBoxOfPath.origin)
			try markdown.image(copy, linked: true)
		}

		markdown.raw("|")

		do {
			let masked = try orig.copy()
			try masked.mask(using: bezierPath)
			try markdown.image(masked, linked: true)
		}

		markdown.raw("|")
		markdown.br()
	}

	func testDrawBitmap() throws {
		
		markdown.h2("Check bitmap draw coordinate zero")

		let orig = bitmapResource(name: "16-squares", extension: "png")
		let c1 = try orig.cropping(to: CGRect(x: 0, y: 0, width: 12, height: 12))

		let made = try Bitmap(size: orig.size)

		try made.drawBitmap(c1, atPoint: .zero)
		try made.drawBitmap(c1, atPoint: CGPoint(x: 12, y: 12))
		try made.drawBitmap(c1, atPoint: CGPoint(x: 24, y: 24))
		try made.drawBitmap(c1, atPoint: CGPoint(x: 36, y: 36))

		markdown.raw("| original (48x48) | Drawing |\n")
		markdown.raw("|----|----|\n")
		markdown.raw("|")
		try markdown.image(orig.scaling(multiplier: 4), linked: true)
		markdown.raw("|")
		try markdown.image(made.scaling(multiplier: 4), linked: true)
		markdown.raw("|")
		markdown.br()
	}

	func testCropping2() throws {

		markdown.h2("Crop checking")

		let orig = bitmapResource(name: "16-squares", extension: "png")
		
		markdown.raw("| original (48x48) | (0,0->24,24) | (12,12->36,36) | (24,24->48,48) |\n")
		markdown.raw("|----|----|----|----|\n")
		markdown.raw("|")

		try markdown.image(orig.scaling(multiplier: 4), linked: true)

		markdown.raw("|")

		do {
			// Lower 2x2
			let c1 = try orig.cropping(to: CGRect(x: 0, y: 0, width: 24, height: 24))
			try markdown.image(c1.scaling(multiplier: 4), linked: true)
		}

		markdown.raw("|")

		do {
			// Middle 2x2
			let c1 = try orig.cropping(to: CGRect(x: 12, y: 12, width: 24, height: 24))
			try markdown.image(c1.scaling(multiplier: 4), linked: true)
		}

		markdown.raw("|")

		do {
			// top left 2x2
			let c1 = try orig.cropping(to: CGRect(x: 24, y: 24, width: 24, height: 24))
			try markdown.image(c1.scaling(multiplier: 4), linked: true)
		}

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

		let orig = bitmapResource(name: "food", extension: "jpg")
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

		let orig = bitmapResource(name: "food", extension: "jpg")
		try markdown.image(orig, linked: true)
		markdown.raw("|")
		orig.fill(.yellow.copy(alpha: 0.3)!)
		try markdown.image(orig, linked: true)
		markdown.raw("|")
		markdown.br()
	}

	func testTintExample() throws {
		markdown.h2("Tint Example 2")

		markdown.raw("| original | tinted |\n")
		markdown.raw("|----|----|\n")
		markdown.raw("|")

		let orig = bitmapResource(name: "cmyk", extension: "jpg")
		try markdown.image(orig, linked: true)

		markdown.raw("|")

		let tintedImage: CGImage? = try {
			try orig
				.tinting(with: CGColor(red: 0, green: 0, blue: 1, alpha: 1))
				.cgImage
		}()
		let u = try XCTUnwrap(tintedImage)
		try markdown.image(u, linked: true)
		markdown.raw("|")
		markdown.br()
	}

	func testOrientation() throws {
		// Verify that CG* drawing still starts at 0,0 in the bottom left
		// Note that if Apple changed the orientation for CGContext drawing it would stuff _everything_ up,
		// but hey, lets check it.

		let bmp = try Bitmap(width: 20, height: 20)

		bmp.draw { ctx in
			ctx.setFillColor(.red)
			ctx.fill([CGRect(x: 0, y: 0, width: 1, height: 1)])
			ctx.setFillColor(.blue)
			ctx.fill([CGRect(x: 19, y: 0, width: 1, height: 1)])
			ctx.setFillColor(.green)
			ctx.fill([CGRect(x: 19, y: 19, width: 1, height: 1)])
			ctx.setFillColor(.white)
			ctx.fill([CGRect(x: 0, y: 19, width: 1, height: 1)])
			ctx.setFillColor(.black)
			ctx.fill([
				CGRect(x: 3, y: 17, width: 1, height: 1),
				CGRect(x: 16, y: 17, width: 1, height: 1),
				CGRect(x: 0, y: 3, width: 1, height: 1),
			])
		}

		let arr = bmp.pixels()
		XCTAssertEqual(400, arr.count)

		XCTAssertEqual(bmp[0, 0], Bitmap.RGBA.red)
		XCTAssertEqual(bmp[19, 0], Bitmap.RGBA.blue)
		XCTAssertEqual(bmp[19, 19], Bitmap.RGBA.green)
		XCTAssertEqual(bmp[0, 19], Bitmap.RGBA.white)
		XCTAssertEqual(bmp[3, 17], Bitmap.RGBA.black)

		let mb = bmp.coordinatesMatching(.blue)
		XCTAssertEqual(1, mb.count)
		XCTAssertEqual(.init(x: 19, y: 0), mb[0])

		let mr = bmp.coordinatesMatching(.red)
		XCTAssertEqual(1, mr.count)
		XCTAssertEqual(.init(x: 0, y: 0), mr[0])

		let mg = bmp.coordinatesMatching(.green)
		XCTAssertEqual(1, mg.count)
		XCTAssertEqual(.init(x: 19, y: 19), mg[0])

		let mw = bmp.coordinatesMatching(.white)
		XCTAssertEqual(1, mw.count)
		XCTAssertEqual(.init(x: 0, y: 19), mw[0])

		// Sorted to give consistent ordering for test
		let mbl = bmp.coordinatesMatching(.black).sorted()
		XCTAssertEqual(3, mbl.count)
		XCTAssertEqual(.init(x: 0, y: 3), mbl[0])
		XCTAssertEqual(.init(x: 3, y: 17), mbl[1])
		XCTAssertEqual(.init(x: 16, y: 17), mbl[2])
	}

	func testPPMExport() throws {
		let bmp = try Bitmap(width: 2, height: 3)

		bmp[0, 0] = .red
		bmp[0, 1] = .green
		bmp[0, 2] = .blue
		bmp[1, 0] = .cyan
		bmp[1, 1] = .magenta
		bmp[1, 2] = .yellow

		do {
			let p3Data = try XCTUnwrap(bmp.representation?.p3())
			let p3 = try XCTUnwrap(String(data: p3Data, encoding: .ascii))
			XCTAssert(p3.count > 0)

			let p3url = try tempContainer.testFilenameWithName("p3test.ppm")
			try p3Data.write(to: p3url)

			let bitmap = try Bitmap(fileURL: p3url)
			XCTAssertEqual(bitmap, bmp)
		}

		do {
			let p6Data = try XCTUnwrap(bmp.representation?.p6())
			XCTAssert(p6Data.count > 0)

			let p6url = try tempContainer.testFilenameWithName("p6test.ppm")
			try p6Data.write(to: p6url)

			let bitmap = try Bitmap(fileURL: p6url)
			XCTAssertEqual(bitmap, bmp)
		}
	}

	func testPPMImport() throws {
		let url = try XCTUnwrap(Bundle.module.url(forResource: "p3test", withExtension: "ppm"))
		let bitmap = try Bitmap(fileURL: url)
		XCTAssert(bitmap.width == 4)
		XCTAssert(bitmap.height == 4)
		XCTAssertEqual(bitmap[0, 0], Bitmap.RGBA(r: 255, g: 0, b: 255, a: 255))
		XCTAssertEqual(bitmap[0, 1], Bitmap.RGBA.black)
		XCTAssertEqual(bitmap[1, 0], Bitmap.RGBA.black)
		XCTAssertEqual(bitmap[1, 2], Bitmap.RGBA(r: 0, g: 255, b: 119, a: 255))

		let i1 = bitmap.cgImage!
		Swift.print(i1)
	}

	func testPPMP6Import() throws {
		let url = try XCTUnwrap(Bundle.module.url(forResource: "p6test", withExtension: "ppm"))
		let data = try Data(contentsOf: url)
		let bitmap = try Bitmap(imageData: data)
		XCTAssertEqual(2, bitmap.width)
		XCTAssertEqual(3, bitmap.height)
		XCTAssertEqual(bitmap[0, 0], Bitmap.RGBA(r: 255, g: 0, b: 0, a: 255))
		XCTAssertEqual(bitmap[0, 1], Bitmap.RGBA(r: 0, g: 255, b: 0, a: 255))
		XCTAssertEqual(bitmap[0, 2], Bitmap.RGBA(r: 0, g: 0, b: 255, a: 255))
		XCTAssertEqual(bitmap[1, 0], Bitmap.RGBA(r: 0, g: 255, b: 255, a: 255))
		XCTAssertEqual(bitmap[1, 1], Bitmap.RGBA(r: 255, g: 0, b: 255, a: 255))
		XCTAssertEqual(bitmap[1, 2], Bitmap.RGBA(r: 255, g: 255, b: 0, a: 255))
	}

	func testSimpleBorder() throws {

		markdown.h2("Simple bordering")

		do {
			markdown.h3("Drawing into original size")

			markdown.raw("| original | 0.5px | 1px | 2px |  dotted 1px  |  dotted 2px  |\n")
			markdown.raw("|----|----|----|----|----|----|\n")
			markdown.raw("|")

			let orig = bitmapResource(name: "food", extension: "jpg")
			try markdown.image(orig, linked: true)
			markdown.raw("<br/>\(orig.size)")

			markdown.raw("|")

			let p1 = try orig.drawingBorder(stroke: Bitmap.Stroke(color: .red, lineWidth: 0.5))
			try markdown.image(p1, linked: true)
			markdown.raw("<br/>\(p1.size)")

			markdown.raw("|")

			let p2 = try orig.drawingBorder(stroke: Bitmap.Stroke(color: .red, lineWidth: 1.0))
			try markdown.image(p2, linked: true)
			markdown.raw("<br/>\(p2.size)")

			markdown.raw("|")

			let p3 = try orig.drawingBorder(stroke: Bitmap.Stroke(color: .red, lineWidth: 2.0))
			try markdown.image(p3, linked: true)
			markdown.raw("<br/>\(p3.size)")

			markdown.raw("|")

			let p4 = try orig.drawingBorder(stroke: Bitmap.Stroke(color: .green, lineWidth: 1.0, dash: .init(lengths: [1, 2])))
			try markdown.image(p4, linked: true)
			markdown.raw("<br/>\(p4.size)")

			markdown.raw("|")

			let p5 = try orig.drawingBorder(stroke: Bitmap.Stroke(color: .red, lineWidth: 2.0, dash: .init(lengths: [2, 2])))
			try markdown.image(p5, linked: true)
			markdown.raw("<br/>\(p5.size)")

			markdown.raw("|")

			markdown.br()
		}

		do {
			markdown.h3("Drawing into expanded size")

			markdown.raw("| original | 0.5px | 1px | 2px |  dotted 1px  |  dotted 2px  |\n")
			markdown.raw("|----|----|----|----|----|----|\n")
			markdown.raw("|")

			let orig = bitmapResource(name: "food", extension: "jpg")
			try markdown.image(orig, linked: true)
			markdown.raw("<br/>\(orig.size)")

			markdown.raw("|")

			let p1 = try orig.drawingBorder(stroke: Bitmap.Stroke(color: .red, lineWidth: 0.5), expanding: true)
			try markdown.image(p1, linked: true)
			markdown.raw("<br/>\(p1.size)")

			markdown.raw("|")

			let p2 = try orig.drawingBorder(stroke: Bitmap.Stroke(color: .red, lineWidth: 1.0), expanding: true)
			try markdown.image(p2, linked: true)
			markdown.raw("<br/>\(p2.size)")

			markdown.raw("|")

			let p3 = try orig.drawingBorder(stroke: Bitmap.Stroke(color: .red, lineWidth: 2.0), expanding: true)
			try markdown.image(p3, linked: true)
			markdown.raw("<br/>\(p3.size)")

			markdown.raw("|")

			let p4 = try orig.drawingBorder(
				stroke: Bitmap.Stroke(color: .green, lineWidth: 1.0, dash: .init(lengths: [1, 2])),
				expanding: true
			)
			try markdown.image(p4, linked: true)
			markdown.raw("<br/>\(p4.size)")

			markdown.raw("|")

			let p5 = try orig.drawingBorder(
				stroke: Bitmap.Stroke(color: .red, lineWidth: 2.0, dash: .init(lengths: [2, 2])),
				expanding: true
			)
			try markdown.image(p5, linked: true)
			markdown.raw("<br/>\(p5.size)")

			markdown.raw("|")

			markdown.br()
		}
	}

	func testScrolling() throws {

		let logoImg = bitmapResource(name: "apple-logo-dark", extension: "png")
		let logoBg = try Bitmap.Checkerboard(
			width: logoImg.width,
			height: logoImg.height,
			color0: CGColor(gray: 0, alpha: 0.05),
			color1: CGColor(gray: 0, alpha: 0.15)
		)

		markdown.h2("Image scrolling")
		markdown.h3("Vertical")

		do {

			markdown.raw("| original | 1 row downwards | 2 rows upwards |\n")
			markdown.raw("|----|----|----|\n")
			markdown.raw("|")

			let orig = bitmapResource(name: "p3test", extension: "ppm")
			XCTAssertEqual(orig.width, 4)
			XCTAssertEqual(orig.height, 4)

			let y0 = orig.bitmapData.rowPixels(at: 0)
			let y1 = orig.bitmapData.rowPixels(at: 1)
			let y2 = orig.bitmapData.rowPixels(at: 2)
			let y3 = orig.bitmapData.rowPixels(at: 3)
			XCTAssertEqual(y0, [Bitmap.RGBA(r: 255, g: 0, b: 255, a: 255), Bitmap.RGBA.black, Bitmap.RGBA.black, Bitmap.RGBA.black])
			XCTAssertEqual(y1, [Bitmap.RGBA.black, Bitmap.RGBA.black, Bitmap.RGBA(r: 0, g: 255, b: 119, a: 255), Bitmap.RGBA.black])
			XCTAssertEqual(y2, [Bitmap.RGBA.black, Bitmap.RGBA(r: 0, g: 255, b: 119, a: 255), Bitmap.RGBA.black, Bitmap.RGBA.black])
			XCTAssertEqual(y3, [Bitmap.RGBA.black, Bitmap.RGBA.black, Bitmap.RGBA.black, Bitmap.RGBA(r: 255, g: 0, b: 255, a: 255)])

			let x0 = orig.bitmapData.columnPixels(at: 0)
			let x1 = orig.bitmapData.columnPixels(at: 1)
			let x2 = orig.bitmapData.columnPixels(at: 2)
			let x3 = orig.bitmapData.columnPixels(at: 3)
			XCTAssertEqual(x0, [Bitmap.RGBA(r: 255, g: 0, b: 255, a: 255), Bitmap.RGBA.black, Bitmap.RGBA.black, Bitmap.RGBA.black])
			XCTAssertEqual(x1, [Bitmap.RGBA.black, Bitmap.RGBA.black, Bitmap.RGBA(r: 0, g: 255, b: 119, a: 255), Bitmap.RGBA.black])
			XCTAssertEqual(x2, [Bitmap.RGBA.black, Bitmap.RGBA(r: 0, g: 255, b: 119, a: 255), Bitmap.RGBA.black, Bitmap.RGBA.black])
			XCTAssertEqual(x3, [Bitmap.RGBA.black, Bitmap.RGBA.black, Bitmap.RGBA.black, Bitmap.RGBA(r: 255, g: 0, b: 255, a: 255)])

			try markdown.image(try orig.scaling(multiplier: 32), linked: true)

			markdown.raw(" | ")

			let scrolledDown = try orig.scrolling(direction: .down, count: 1)
			// Remember that the bitmap origin is lower left
			XCTAssertEqual(orig.bitmapData.rowPixels(at: 0), scrolledDown.bitmapData.rowPixels(at: 3))
			try markdown.image(try scrolledDown.scaling(multiplier: 32), linked: true)

			markdown.raw(" | ")

			let scrolledUp = try orig.copy()
			scrolledUp.scroll(direction: .up, count: 2)
			XCTAssertEqual(orig.bitmapData.rowPixels(at: 0), scrolledUp.bitmapData.rowPixels(at: 2))
			try markdown.image(try scrolledUp.scaling(multiplier: 32), linked: true)

			markdown.raw(" | ")
			markdown.br()
		}

		let stamp = bitmapResource(name: "16-squares", extension: "png")
		let bg = try Bitmap.Checkerboard(
			width: stamp.width,
			height: stamp.height,
			checkSize: 4,
			color0: CGColor(gray: 0, alpha: 0.05),
			color1: CGColor(gray: 0, alpha: 0.15)
		)

		do {
			let orig = bitmapResource(name: "16-squares", extension: "png")
			let step = orig.height / 8

			let stepper = stride(from: 0, to: orig.height, by: step)
			let directions: [Bitmap.ScrollDirection] = [.down, .up, .right, .left]

			try directions.forEach { dir in
				markdown.h3("\(dir)").br()
				markdown.raw("|    |")
				stepper.forEach { o in markdown.raw("  \(Int(o))  |") }
				markdown.raw("\n|----|")
				stepper.forEach { _ in markdown.raw("----|") }
				markdown.raw("\n|")

				try [true, false].forEach { wraps in
					markdown.raw(" \(wraps ? "wrap" : "nowrap") |")
					try stepper.forEach { offset in
						let scrolled = try bg.drawingBitmap(orig.scrolling(direction: dir, count: offset, wrapsContent: wraps))
						try markdown.image(scrolled.scaling(multiplier: 2), linked: true)
						markdown.raw("|")
					}
					markdown.raw("\n")
				}
			}
			markdown.br()
		}

		do {
			markdown.raw("|    | original | 6 rows down | 6 rows up | 12 rows down | 24 rows up |\n")
			markdown.raw("|----|----|----|----|----|----|----|\n")
			do {
				markdown.raw("| wraps |")

				let orig = bitmapResource(name: "16-squares", extension: "png")
				try markdown.image(try orig.scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollRight6 = try orig.scrolling(direction: .down, count: 6)
				try markdown.image(try scrollRight6.scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollLeft6 = try orig.scrolling(direction: .up, count: 6)
				try markdown.image(try scrollLeft6.scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollLeft = try orig.scrolling(direction: .down, count: 12)
				try markdown.image(try scrollLeft.scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollRight = try orig.scrolling(direction: .up, count: 24)
				try markdown.image(try scrollRight.scaling(multiplier: 8), linked: true)

				markdown.raw("|")
			}
			markdown.raw("\n")
			markdown.raw("| no-wrap |")
			do {
				let orig = bitmapResource(name: "16-squares", extension: "png")
				try markdown.image(try orig.scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollRight6 = try orig.scrolling(direction: .down, count: 6, wrapsContent: false)
				try markdown.image(try bg.drawingBitmap(scrollRight6).scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollLeft6 = try orig.scrolling(direction: .up, count: 6, wrapsContent: false)
				try markdown.image(try bg.drawingBitmap(scrollLeft6).scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollLeft = try orig.scrolling(direction: .down, count: 12, wrapsContent: false)
				try markdown.image(try bg.drawingBitmap(scrollLeft).scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollRight = try orig.scrolling(direction: .up, count: 24, wrapsContent: false)
				try markdown.image(try bg.drawingBitmap(scrollRight).scaling(multiplier: 8), linked: true)

				markdown.raw("|")
			}
			markdown.br()
		}

		do {
			markdown.raw("|    | original | downwards | upwards |\n")
			markdown.raw("|----|----|----|----|\n")
			markdown.raw("| wraps |")

			do {
				try markdown.image(logoBg.drawingBitmap(logoImg), linked: true)

				markdown.raw("|")

				let scrolledDown = try logoImg.scrolling(direction: .down, count: logoImg.height / 6)
				try markdown.image(logoBg.drawingBitmap(scrolledDown), linked: true)
				markdown.raw("|")

				let scrolledUp = try logoImg.scrolling(direction: .up, count: logoImg.height / 6)
				try markdown.image(logoBg.drawingBitmap(scrolledUp), linked: true)
				markdown.raw("|")
			}
			markdown.raw("\n")
			markdown.raw("| no-wrap |")
			do {

				try markdown.image(logoBg.drawingBitmap(logoImg), linked: true)

				markdown.raw("|")

				let scrolledDown = try logoImg.scrolling(direction: .down, count: logoImg.height / 6, wrapsContent: false)
				try markdown.image(logoBg.drawingBitmap(scrolledDown), linked: true)
				markdown.raw("|")

				let scrolledUp = try logoImg.scrolling(direction: .up, count: logoImg.height / 6, wrapsContent: false)
				try markdown.image(logoBg.drawingBitmap(scrolledUp), linked: true)
				markdown.raw("|")
			}

			markdown.br()
		}

		markdown.h3("Horizontal")

		do {
			markdown.raw("|    | original | 6 cols right | 6 cols left | 12 cols right | 24 cols left |\n")
			markdown.raw("|----|----|----|----|----|----|----|\n")

			do {
				markdown.raw("| wrap |")

				let orig = bitmapResource(name: "16-squares", extension: "png")
				try markdown.image(try orig.scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollRight6 = try orig.scrolling(direction: .right, count: 6)
				try markdown.image(try scrollRight6.scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollLeft6 = try orig.scrolling(direction: .left, count: 6)
				try markdown.image(try scrollLeft6.scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollLeft = try orig.scrolling(direction: .right, count: 12)
				try markdown.image(try scrollLeft.scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollRight = try orig.scrolling(direction: .left, count: 24)
				try markdown.image(try scrollRight.scaling(multiplier: 8), linked: true)

				markdown.raw("|")
			}
		
			markdown.raw("\n")

			do {
				markdown.raw("| no-wrap |")

				let orig = bitmapResource(name: "16-squares", extension: "png")
				try markdown.image(try orig.scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollRight6 = try orig.scrolling(direction: .right, count: 6, wrapsContent: false)
				try markdown.image(try bg.drawingBitmap(scrollRight6).scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollLeft6 = try orig.scrolling(direction: .left, count: 6, wrapsContent: false)
				try markdown.image(try bg.drawingBitmap(scrollLeft6).scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollLeft = try orig.scrolling(direction: .right, count: 12, wrapsContent: false)
				try markdown.image(try bg.drawingBitmap(scrollLeft).scaling(multiplier: 8), linked: true)

				markdown.raw("|")

				let scrollRight = try orig.scrolling(direction: .left, count: 24, wrapsContent: false)
				try markdown.image(try bg.drawingBitmap(scrollRight).scaling(multiplier: 8), linked: true)

				markdown.raw("|")
			}
			markdown.br()
		}

		do {
			markdown.raw("|  | original | right | left |\n")
			markdown.raw("|----|----|----|----|\n")

			do {
				markdown.raw("| wraps |")

				try markdown.image(logoBg.drawingBitmap(logoImg), linked: true)

				markdown.raw("|")

				let scrolledDown = try logoImg.scrolling(direction: .right, count: logoImg.width / 6)
				try markdown.image(logoBg.drawingBitmap(scrolledDown), linked: true)
				markdown.raw("|")

				let scrolledUp = try logoImg.scrolling(direction: .left, count: logoImg.width / 6)
				try markdown.image(logoBg.drawingBitmap(scrolledUp), linked: true)
				markdown.raw("|")
			}

			markdown.raw("\n")

			do {
				markdown.raw("| no wrap |")

				let orig = bitmapResource(name: "apple-logo-dark", extension: "png")
				let bg = try Bitmap.Checkerboard(
					width: orig.width,
					height: orig.height,
					color0: CGColor(gray: 0, alpha: 0.05),
					color1: CGColor(gray: 0, alpha: 0.15)
				)
				
				try markdown.image(bg.drawingBitmap(orig), linked: true)

				markdown.raw("|")

				let scrolledRight = try orig.scrolling(direction: .right, count: orig.width / 6, wrapsContent: false)
				try markdown.image(bg.drawingBitmap(scrolledRight), linked: true)
				markdown.raw("|")

				let scrolledLeft = try orig.scrolling(direction: .left, count: orig.width / 6, wrapsContent: false)
				try markdown.image(bg.drawingBitmap(scrolledLeft), linked: true)
				markdown.raw("|")
			}


			markdown.br()
		}

		markdown.h3("re-zeroing the bitmap")

		do {
			markdown.raw("| original | mid | quarter |\n")
			markdown.raw("|----|----|----|\n")
			markdown.raw("|")

			let orig = bitmapResource(name: "16-squares", extension: "png")
			try markdown.image(orig.scaling(multiplier: 4), linked: true)

			markdown.raw("|")

			let mid = try orig.zeroingPoint(x: orig.width / 2, y: orig.height / 2)
			try markdown.image(mid.scaling(multiplier: 4), linked: true)

			markdown.raw("|")

			let quarter = try orig.zeroingPoint(x: orig.width / 4, y: orig.height / 4)
			try markdown.image(quarter.scaling(multiplier: 4), linked: true)
		}

		markdown.raw("|")
		markdown.br()
	}

	#if !os(watchOS)
	func testLayer() throws {
		let l = CAShapeLayer()
		l.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
		l.contentsScale = 2
		l.path = CGPath(
			roundedRect: CGRect(x: 0, y: 0, width: 60, height: 60),
			cornerWidth: 6,
			cornerHeight: 6,
			transform: nil
		)
		l.fillColor = .blue

		let e1 = CAShapeLayer()
		e1.path = CGPath(ellipseIn: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)), transform: nil)
		e1.fillColor = .black
		l.addSublayer(e1)

		let t = CATextLayer()
		t.contentsScale = 2
		t.fontSize = 26
		t.foregroundColor = .white
		t.string = "A"
		t.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
		l.addSublayer(t)

		let bitmap = try Bitmap(l)
		XCTAssertEqual(bitmap.width, 60)
		XCTAssertEqual(bitmap.height, 60)

		let cg = try XCTUnwrap(bitmap.cgImage)
		XCTAssertEqual(cg.width, 60)
		XCTAssertEqual(cg.height, 60)
	}
	#endif

	#if os(macOS)
	func testBasicNSView() throws {
		let v = NSButton()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.title = "Press me!"
		v.sizeToFit()
		let bitmap = try Bitmap(v)
		XCTAssertGreaterThan(bitmap.width, 0)
		XCTAssertGreaterThan(bitmap.height, 0)
		let cg = try XCTUnwrap(bitmap.cgImage)
		XCTAssertEqual(cg.width, bitmap.width)
		XCTAssertEqual(cg.height, bitmap.height)
	}
	#elseif !os(watchOS)
	func testBasicUIView() throws {
		let view = UIButton(type: .roundedRect)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.setTitle("Press me!", for: .normal)
		view.layer.backgroundColor = .red
		view.tintColor = .white
		view.layer.cornerRadius = 6
 		view.sizeToFit()

		let bitmap = try Bitmap(view)
		
		XCTAssertGreaterThan(bitmap.width, 0)
		XCTAssertGreaterThan(bitmap.height, 0)
		let cg = try XCTUnwrap(bitmap.cgImage)
		XCTAssertEqual(cg.width, bitmap.width)
		XCTAssertEqual(cg.height, bitmap.height)
	}
	#endif

	func testExtract() throws {

		markdown.h2("Extracting Content")

		markdown.raw("| original | extracted | extracted and clipped<br/>to path bounds |\n")
		markdown.raw("|----|----|----|\n")
		markdown.raw("|")

		do {
			let orig = bitmapResource(name: "16-squares", extension: "png")
			try markdown.image(orig.scaling(multiplier: 2), linked: true)

			markdown.raw("|")

			do {
				let extracted = try orig.extracting(CGRect(x: 12, y: 12, width: 24, height: 24))
				XCTAssertEqual(extracted.size, orig.size)
				try markdown.image(try checked(orig.width, orig.height).drawingBitmap(extracted).scaling(multiplier: 2), linked: true)
			}

			markdown.raw("|")

			do {
				let orig = bitmapResource(name: "16-squares", extension: "png")
				let extracted = try orig.extracting(CGRect(x: 12, y: 12, width: 24, height: 24), clipToPath: true)
				XCTAssertEqual(extracted.size, CGSize(width: 24, height: 24))
				try markdown.image(try checked(24, 24).drawingBitmap(extracted).scaling(multiplier: 2), linked: true)
			}
			markdown.raw("|\n")
		}

		do {
			let p2 = CGRect(x: 6, y: 6, width: 30, height: 30)
			let pth = CGPath(roundedRect: p2, cornerWidth: 8, cornerHeight: 8, transform: nil)

			markdown.raw("|")
			do {
				let orig = bitmapResource(name: "16-squares", extension: "png")
				try markdown.image(orig.scaling(multiplier: 2), linked: true)
			}
			markdown.raw("|")
			do {
				let orig = bitmapResource(name: "16-squares", extension: "png")
				let extracted = try orig.extracting(pth, clipToPath: false)
				XCTAssertEqual(extracted.size, orig.size)
				try markdown.image(try checked(orig.size).drawingBitmap(extracted).scaling(multiplier: 2), linked: true)
			}

			markdown.raw("|")

			do {
				let orig = bitmapResource(name: "16-squares", extension: "png")
				let extracted = try orig.extracting(pth, clipToPath: true)
				XCTAssertEqual(extracted.size, p2.size)
				try markdown.image(try checked(p2.size).drawingBitmap(extracted).scaling(multiplier: 2), linked: true)
			}

			markdown.raw("|")
		}
		markdown.br()
	}

	func testErase() throws {

		markdown.h2("Erasing paths")

		do {
			markdown.h3("Erase hole")

			markdown.raw("| original | erased |\n")
			markdown.raw("|----|----|\n")
			markdown.raw("|")

			let bitmap = bitmapResource(name: "gps-image", extension: "jpg")
			try markdown.image(bitmap.cgImage!, linked: true)

			markdown.raw("|")

			let punch = CGRect(x: 50, y: 50, width: 70, height: 150).insetBy(dx: 0.5, dy: 0.5)
			let punched = try bitmap.erasing(punch.path, backgroundColor: .red.copy(alpha: 0.2))
				.drawingPath(
					CGPath(rect: punch, transform: nil),
					fillColor: nil,
					stroke: Bitmap.Stroke(color: .green, lineWidth: 1)
				)
				.erasing(complexPath())

			try markdown.image(punched, linked: true)

			markdown.raw("|")

			markdown.br()
		}


		let starPath: CGPath = {
			let s = CGMutablePath()
			s.move(to: CGPoint(x: 24, y: 48))
			s.addLine(to: CGPoint(x: 29.51, y: 37.3))
			s.addLine(to: CGPoint(x: 40.97, y: 40.97))
			s.addLine(to: CGPoint(x: 37.3, y: 29.51))
			s.addLine(to: CGPoint(x: 48, y: 24))
			s.addLine(to: CGPoint(x: 37.3, y: 18.49))
			s.addLine(to: CGPoint(x: 40.97, y: 7.03))
			s.addLine(to: CGPoint(x: 29.51, y: 10.7))
			s.addLine(to: CGPoint(x: 24, y: 0))
			s.addLine(to: CGPoint(x: 18.49, y: 10.7))
			s.addLine(to: CGPoint(x: 7.03, y: 7.03))
			s.addLine(to: CGPoint(x: 10.7, y: 18.49))
			s.addLine(to: CGPoint(x: 0, y: 24))
			s.addLine(to: CGPoint(x: 10.7, y: 29.51))
			s.addLine(to: CGPoint(x: 7.03, y: 40.97))
			s.addLine(to: CGPoint(x: 18.49, y: 37.3))
			s.closeSubpath()
			return s
		}()

		do {
			markdown.raw("| original | transparent | red | green |\n")
			markdown.raw("|----|----|----|----|\n")
			markdown.raw("|")

			let orig = bitmapResource(name: "16-squares", extension: "png")
			let bg = try Bitmap.Checkerboard(
				width: orig.width,
				height: orig.height,
				checkSize: 4,
				color0: CGColor(gray: 0, alpha: 0.05),
				color1: CGColor(gray: 0, alpha: 0.15)
			)

			let pth = CGPath(ellipseIn: orig.bounds.insetBy(dx: 8, dy: 8), transform: nil)
			try markdown.image(bg.drawingBitmap(orig).scaling(multiplier: 5), linked: true)

			markdown.raw("|")
			let erase1 = try orig.erasing(pth)
			try markdown.image(bg.drawingBitmap(erase1).scaling(multiplier: 5), linked: true)

			markdown.raw("|")
			let erase2 = try orig.erasing(pth, backgroundColor: .red)
			try markdown.image(bg.drawingBitmap(erase2).scaling(multiplier: 5), linked: true)

			markdown.raw("|")
			let erase7 = try orig.erasing(pth, backgroundColor: .green)
			try markdown.image(bg.drawingBitmap(erase7).scaling(multiplier: 5), linked: true)

			markdown.raw("|")
			markdown.raw("\n")

			markdown.raw("|    |")
			let erase3 = try orig.erasing(starPath)
			try markdown.image(bg.drawingBitmap(erase3).scaling(multiplier: 5), linked: true)

			markdown.raw("|")
			let erase4 = try orig.erasing(starPath, backgroundColor: .red)
			try markdown.image(bg.drawingBitmap(erase4).scaling(multiplier: 5), linked: true)

			markdown.raw("|")
			let erase6 = try orig.erasing(starPath, backgroundColor: .green)
			try markdown.image(bg.drawingBitmap(erase6).scaling(multiplier: 5), linked: true)

			markdown.raw("|")
			markdown.br()
		}
	}

	func testBlurring() throws {

		markdown.h2("Blurring")

		let imgs = [
			imageResource(name: "gps-image", extension: "jpg"),
			imageResource(name: "apple-logo-dark", extension: "png")
		]

		try imgs.forEach { cgi in

			markdown.raw("| original | blurred (5) | blurred (10) |\n")
			markdown.raw("|--------|--------|--------|\n")

			let bmi = try Bitmap(cgi)
			markdown.raw("|")
			try markdown.image(cgi, linked: true)

			do {
				let bm1 = try bmi.blurring(5)
				let cg1 = try XCTUnwrap(bm1.cgImage)
				markdown.raw("|")
				try markdown.image(cg1, linked: true)
			}

			do {
				let bm2 = try bmi.copy()
				try bm2.blur(10)
				let cg2 = try XCTUnwrap(bm2.cgImage)
				markdown.raw("|")
				try markdown.image(cg2, linked: true)
			}

			markdown.raw("|")
			markdown.br()
		}
	}

#if canImport(CoreImage)
	func testGamma() throws {

		markdown.h2("Gamma")

		let imgs = [
			imageResource(name: "gps-image", extension: "jpg"),
			imageResource(name: "apple-logo-dark", extension: "png")
		]

		try imgs.forEach { cgi in
			markdown.raw("| original | gamma (2.2) | gamma (1/2.2) | gamma (5) |\n")
			markdown.raw("|--------|--------|--------|--------|\n")

			let bmi = try Bitmap(cgi)
			markdown.raw("|")
			try markdown.image(cgi, linked: true)

			do {
				let bm1 = try bmi.adjustingGamma(power: 2.2)
				let cg1 = try XCTUnwrap(bm1.cgImage)
				markdown.raw("|")
				try markdown.image(cg1, linked: true)
			}

			do {
				let bm1 = try bmi.adjustingGamma(power: 1/2.2)
				let cg1 = try XCTUnwrap(bm1.cgImage)
				markdown.raw("|")
				try markdown.image(cg1, linked: true)
			}

			do {
				let bm2 = try bmi.copy()
				try bm2.adjustGamma(power: 5)
				let cg2 = try XCTUnwrap(bm2.cgImage)
				markdown.raw("|")
				try markdown.image(cg2, linked: true)
			}

			markdown.raw("|")
			markdown.br()
		}
	}
#endif

#if canImport(CoreImage)
	func testDiagonalLines() throws {

		markdown.h2("Diagonal lines generator")

		do {
			let linew: [CGFloat] = [4, 8, 12]
			let st = stride(from: 0, to: CGFloat.pi, by: CGFloat.pi / 8)
			markdown.raw("|")

			let f = NumberFormatter()
			f.maximumFractionDigits = 3
			st.forEach { angle in
				markdown.raw("  \(f.string(for: angle)!)  |")
			}
			markdown.raw("\n|")
			st.forEach { _ in markdown.raw("----|") }
			markdown.raw("\n")
			try linew.forEach { lineWidth in
				markdown.raw("|")
				try st.forEach { angle in
					let bss = try Bitmap.DiagonalLines(width: 100, height: 100, lineWidth: lineWidth, angle: .radians(angle))
					try markdown.image(bss, linked: true)
					markdown.raw("|")
				}
				markdown.raw("\n")
			}
			markdown.br()

			do {
				markdown.raw("|    |    |    |\n")
				markdown.raw("|----|----|----|\n")
				markdown.raw("|")
				let bss1 = try Bitmap.DiagonalLines(
					width: 100,
					height: 100,
					lineWidth: 10,
					color0: CGColor.red,
					color1: CGColor.blue
				)
				try markdown.image(bss1, linked: true)
				markdown.raw("|")
				let bss2 = try Bitmap.DiagonalLines(
					width: 100,
					height: 100,
					lineWidth: 4,
					angle: .radians(0.1),
					color0: CGColor(srgbRed: 0, green: 1, blue: 0, alpha: 0.1),
					color1: CGColor.clear
				)
				try markdown.image(bss2, linked: true)
				markdown.raw("|")
				let bss3 = try Bitmap.DiagonalLines(
					width: 100,
					height: 100,
					lineWidth: 20,
					angle: .radians(CGFloat.pi / 4),
					color0: CGColor(red: 1.000, green: 0.838, blue: 0.034, alpha: 1.0),
					color1: CGColor(red: 1.000, green: 0.763, blue: 0.000, alpha: 1.0)
				)
				try markdown.image(bss3, linked: true)
			}

			markdown.br()
		}
	}
	#endif
}
