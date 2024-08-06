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

// Standard cross-platform color definitions

public extension CGColor {
	struct StandardColors {
		static public let clear = CGColor(red: 0, green: 0, blue: 0, alpha: 0)
		static public let black = CGColor(colorSpace: .init(name: CGColorSpace.linearGray)!, components: [0, 1])!
		static public let white = CGColor(colorSpace: .init(name: CGColorSpace.linearGray)!, components: [1, 1])!

		static public let red = CGColor(colorSpace: CGColorSpace.csRGB, components: [1.0, 0.0, 0.0, 1.0])!
		static public let green = CGColor(colorSpace: CGColorSpace.csRGB, components: [0.0, 1.0, 0.0, 1.0])!
		static public let blue = CGColor(colorSpace: CGColorSpace.csRGB, components: [0.0, 0.0, 1.0, 1.0])!
		static public let yellow = CGColor(colorSpace: CGColorSpace.csRGB, components: [1.0, 1.0, 0.0, 1.0])!
		static public let magenta = CGColor(colorSpace: CGColorSpace.csRGB, components: [1.0, 0.0, 1.0, 1.0])!
		static public let cyan = CGColor(colorSpace: CGColorSpace.csRGB, components: [0.0, 1.0, 1.0, 1.0])!
	}

	/// Standard color definition accessor
	static var standard: StandardColors.Type { StandardColors.self }
}
