import XCTest
@testable import Bitmap

func bitmapResource(name: String, extension extn: String) -> Bitmap {
	let url = Bundle.module.url(forResource: name, withExtension: extn)!
	let image = PlatformImage(contentsOfFile: url.path)!.cgImage!
	return try! Bitmap(image)
}

func imageResource(name: String, extension extn: String) -> CGImage {
	let url = Bundle.module.url(forResource: name, withExtension: extn)!
	return PlatformImage(contentsOfFile: url.path)!.cgImage!
}

final class BitmapTests: XCTestCase {
	func testExample() throws {
		var bitmap = try Bitmap(width: 100, height: 100)
		XCTAssertEqual(100, bitmap.width)

		bitmap.setPixel(x: 0, y: 0, color: Bitmap.RGBA(r: 255, g: 0, b: 0, a: 255))
		bitmap.setPixel(x: 0, y: 99, color: Bitmap.RGBA(r: 255, g: 0, b: 255, a: 255))
		bitmap.setPixel(x: 99, y: 99, color: Bitmap.RGBA(r: 0, g: 255, b: 255, a: 255))
		bitmap.setPixel(x: 99, y: 0, color: Bitmap.RGBA(r: 255, g: 255, b: 0, a: 255))

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

		let image = try XCTUnwrap(bitmap.cgImage)
		XCTAssertEqual(100, image.width)
		XCTAssertEqual(100, image.height)

		let paddedBitmap = try bitmap.padded(40)
		XCTAssertEqual(180, paddedBitmap.width)
		XCTAssertEqual(180, paddedBitmap.height)
		let image2 = try XCTUnwrap(paddedBitmap.cgImage)
		XCTAssertEqual(180, image2.width)
		XCTAssertEqual(180, image2.height)
	}

	func testDrawing() throws {
		var bitmap = try Bitmap(width: 255, height: 255)
		assert(bitmap.width == 255)
		assert(bitmap.width == 255)

		bitmap.draw(
			rect: CGRect(x: 50, y: 50, width: 50, height: 50),
			fillColor: CGColor(red: 1, green: 0, blue: 0, alpha: 1),
			stroke: Bitmap.Stroke(color: CGColor(gray: 0.5, alpha: 1.0), lineWidth: 2)
		)
		let image = try XCTUnwrap(bitmap.cgImage)
		Swift.print(image)
	}

	func testShadow() throws {
		var bitmap = try Bitmap(width: 255, height: 255)
		bitmap.applyingShadow(Bitmap.Shadow()) { bitmap in
			bitmap.fill(CGPath(rect: CGRect(x: 10, y: 10, width: 100, height: 100), transform: nil), .init(gray: 0.5, alpha: 1))
		}

		bitmap.applyingShadow(Bitmap.Shadow(color: .white)) { bitmap in
			bitmap.stroke(
				CGPath(rect: CGRect(x: 110, y: 110, width: 100, height: 100), transform: nil),
				Bitmap.Stroke(color: CGColor(red: 1, green: 0, blue: 0, alpha: 1), lineWidth: 2)
			)
		}

		let image = try XCTUnwrap(bitmap.cgImage)
		Swift.print(image)
	}

	func testImage() throws {
		let image = imageResource(name: "gps-image", extension: "jpg")
		do {
			var bitmap = try Bitmap(width: 200, height: 200)
			bitmap.draw(image, in: CGRect(x: 50, y: 50, width: 100, height: 100))
			let stamped = try XCTUnwrap(bitmap.cgImage)
			Swift.print(stamped)
		}
		do {
			var bitmap = try Bitmap(width: 200, height: 200)
			bitmap.draw(image, in: CGRect(x: 50, y: 50, width: 100, height: 100), scaling: .aspectFit)
			let stamped = try XCTUnwrap(bitmap.cgImage)
			Swift.print(stamped)
		}

		do {
			var bitmap = try Bitmap(width: 200, height: 200)
			bitmap.draw(image, in: CGRect(x: 50, y: 50, width: 100, height: 100), scaling: .aspectFill)
			let stamped = try XCTUnwrap(bitmap.cgImage)
			Swift.print(stamped)
		}
	}

	func testTintRect() throws {
		var orig = bitmapResource(name: "gps-image", extension: "jpg")
		try orig.tint(with: CGColor(red: 1, green: 0, blue: 0, alpha: 1), in: CGRect(x: 50, y: 50, width: 200, height: 200))
		let rotatedCG = try XCTUnwrap(orig.cgImage)
		Swift.print(rotatedCG)
	}

	func testRotating() throws {
		let image = imageResource(name: "gps-image", extension: "jpg")
		let bitmap = try Bitmap(image)

		let rotated = try bitmap.rotating(by: 1.4)
		let rotatedCG = try XCTUnwrap(rotated.cgImage)
		Swift.print(rotatedCG)
	}

	func testGrayscale() throws {
		let image = imageResource(name: "gps-image", extension: "jpg")
		let bitmap = try Bitmap(image)

		let gr = try bitmap.grayscale()
		let grcg = try XCTUnwrap(gr.cgImage)
		Swift.print(grcg)
	}

	func testTinting() throws {
		let image = imageResource(name: "gps-image", extension: "jpg")
		let bitmap = try Bitmap(image)

		let gr = try bitmap.tinting(with: CGColor(red: 1, green: 0, blue: 0, alpha: 1))
		let grcg = try XCTUnwrap(gr.cgImage)
		Swift.print(grcg)
	}

	func testClipping() throws {
		let image = imageResource(name: "gps-image", extension: "jpg")
		var bitmap = try Bitmap(image)

		bitmap.clippingToPath(CGPath(ellipseIn: CGRect(x: 10, y: 10, width: 50, height: 50), transform: nil)) { bitmap in
			bitmap.fill(.white)
		}

		let grcg = try XCTUnwrap(bitmap.cgImage)
		Swift.print(grcg)
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

	func testString1() throws {
		var bitmap = try Bitmap(width: 400, height: 400)
		bitmap.drawText("Hello", color: .white, position: .zero)
		let ima = try XCTUnwrap(bitmap.cgImage)
		Swift.print(ima)
	}

	func testString2() throws {
		do {
			var bitmap = try Bitmap(width: 400, height: 400)
			bitmap.drawText(
				"Hello there, how are you? This is exciting",
				color: .white,
				path: CGPath(rect: CGRect(x: 100, y: 100, width: 50, height: 50), transform: nil)
			)
			let ima = try XCTUnwrap(bitmap.cgImage)
			Swift.print(ima)
		}

		do {
			var bitmap2 = try Bitmap(width: 400, height: 400)
			bitmap2.drawText(
				"Hello there, how are you? This is exciting",
				color: .white
			)
			let ima2 = try XCTUnwrap(bitmap2.cgImage)
			Swift.print(ima2)
		}

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
			let ima3 = try XCTUnwrap(bitmap3.cgImage)
			Swift.print(ima3)
		}
	}

	func testMasking() throws {

		let cmykImage = bitmapResource(name: "cmyk", extension: "jpg")
		let maskImage = bitmapResource(name: "cat-icon", extension: "png")

		let masked = try cmykImage.masking(using: maskImage)

		let nsi = masked.image
		Swift.print(nsi)
	}
}
