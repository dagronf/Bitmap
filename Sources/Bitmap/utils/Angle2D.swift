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

/// A 2D angle
///
/// An angle value represents either a radians or a degrees angle, with functions to easily convert between the two
public enum Angle2D<FloatingPointType: BinaryFloatingPoint & Codable> {
	/// Radians angle value
	case radians(FloatingPointType)
	/// Degrees angle value
	case degrees(FloatingPointType)

	/// The radians value for the angle
	@inlinable public var radians: FloatingPointType {
		switch self {
		case let .radians(value): return value
		case let .degrees(value): return value * 0.01745329251   // precomputed -> pi / 180
		}
	}

	/// The degrees value for the angle
	@inlinable public var degrees: FloatingPointType {
		switch self {
		case let .radians(value): return value * 57.2957795131   // precomputed -> 180 / pi
		case let .degrees(value): return value
		}
	}

	/// Return a guaranteed radians angle representation
	@inlinable public var asRadians: Angle2D { .radians(self.radians) }
	/// Return a guaranteed degrees angle representation
	@inlinable public var asDegrees: Angle2D { .degrees(self.degrees) }
}

@usableFromInline let _doublePI: Angle2D<Double> = .radians(Double.pi)
public extension Angle2D where FloatingPointType == Double {
	/// The mathematical constant pi (π), approximately equal to 3.14159
	@inlinable static var pi: Angle2D<Double> { _doublePI }
}

@usableFromInline let _floatPI: Angle2D<Float> = .radians(Float.pi)
public extension Angle2D where FloatingPointType == Float {
	/// The mathematical constant pi (π), approximately equal to 3.14159
	@inlinable static var pi: Angle2D<Float> { _floatPI }
}

@usableFromInline let _cgfloatPI: Angle2D<CGFloat> = .radians(CGFloat.pi)
public extension Angle2D where FloatingPointType == CGFloat {
	/// The mathematical constant pi (π), approximately equal to 3.14159
	@inlinable static var pi: Angle2D<CGFloat> { _cgfloatPI }
}

// MARK: - Additive conformance

extension Angle2D: AdditiveArithmetic {
	/// The zero value
	@inlinable public static var zero: Angle2D<FloatingPointType> { .radians(0.0) }

	/// Returns the given number unchanged.
	@inlinable public static prefix func + (x: Angle2D) -> Angle2D { x }
	/// Adds two values and stores the result in the left-hand-side variable.
	@inlinable public static func += (lhs: inout Angle2D, rhs: Angle2D) {
		switch lhs {
		case let .radians(value): lhs = .radians(value + rhs.radians)
		case let .degrees(value): lhs = .degrees(value + rhs.degrees)
		}
	}

	/// Adds two values and produces their sum.
	@inlinable public static func + (lhs: Angle2D, rhs: Angle2D) -> Angle2D {
		switch lhs {
		case let .radians(value): .radians(value + rhs.radians)
		case let .degrees(value): .degrees(value + rhs.degrees)
		}
	}

	/// Returns the additive inverse of the given angle.
	public static prefix func - (angle: Angle2D) -> Angle2D {
		switch angle {
		case let .radians(value): .radians(-value)
		case let .degrees(value): .degrees(-value)
		}
	}

	/// Subtracts one value from another and produces their difference.
	@inlinable public static func - (_ lhs: Angle2D, _ rhs: Angle2D) -> Angle2D {
		switch lhs {
		case let .radians(value): .radians(value - rhs.radians)
		case let .degrees(value): .degrees(value - rhs.degrees)
		}
	}

	/// Subtracts the second value from the first and stores the difference in the left-hand-side variable.
	@inlinable public static func -= (lhs: inout Angle2D, rhs: Angle2D) {
		switch lhs {
		case let .radians(value): lhs = .radians(value - rhs.radians)
		case let .degrees(value): lhs = .degrees(value - rhs.degrees)
		}
	}
}

// MARK: - Hashable conformance

extension Angle2D: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.radians)
	}
}

// MARK: - Equatable conformance

extension Angle2D: Equatable {
	/// Returns a Boolean value indicating whether two values are equal.
	@inlinable public static func == (lhs: Angle2D, rhs: Angle2D) -> Bool {
		switch lhs {
		case let .radians(value): return value == rhs.radians
		case let .degrees(value): return value == rhs.degrees
		}
	}
}

// MARK: - Comparable conformance

extension Angle2D: Comparable {
	/// Returns a Boolean value indicating whether the value of the first argument is less than that of the second argument.
	@inlinable public static func < (lhs: Angle2D, rhs: Angle2D) -> Bool {
		switch lhs {
		case let .radians(value): return value < rhs.radians
		case let .degrees(value): return value < rhs.degrees
		}
	}
}

// MARK: - CustomDebugStringConvertible conformance

extension Angle2D: CustomDebugStringConvertible {
	public var debugDescription: String {
		switch self {
		case let .radians(value): return "(rad=\(value), •deg=\(self.degrees))"
		case let .degrees(value): return "(deg=\(value), •rad=\(self.radians))"
		}
	}
}

// MARK: - Codable conformance

private let _radiansString = "radians"
private let _degreesString = "degrees"

extension Angle2D: Codable {
	private enum CodingKeys: String, CodingKey {
		case type
		case value
	}

	public init(from decoder: any Decoder) throws {
		let data = try decoder.container(keyedBy: CodingKeys.self)
		let type = try data.decode(String.self, forKey: .type)
		let value = try data.decode(FloatingPointType.self, forKey: .value)
		switch type {
		case _radiansString:
			self = .radians(value)
		case _degreesString:
			self = .degrees(value)
		default:
			throw DecodingError.dataCorruptedError(
				forKey: .type,
				in: data,
				debugDescription: "Unknown angle type '\(type)'. Expected 'radians' or 'degrees'"
			)
		}
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case let .radians(value):
			try container.encode(_radiansString, forKey: .type)
			try container.encode(value, forKey: .value)

		case let .degrees(value):
			try container.encode(_degreesString, forKey: .type)
			try container.encode(value, forKey: .value)
		}
	}
}

// MARK: - Basic math operations

@inlinable @inline(__always) func cos(_ value: Angle2D<Double>) -> Double { Foundation.cos(value.radians) }
@inlinable @inline(__always) func cos(_ value: Angle2D<Float>) -> Float { Foundation.cos(value.radians) }
@inlinable @inline(__always) func cos(_ value: Angle2D<CGFloat>) -> CGFloat { Foundation.cos(value.radians) }

@inlinable @inline(__always) func cosh(_ value: Angle2D<Double>) -> Double { Foundation.cosh(value.radians) }
@inlinable @inline(__always) func cosh(_ value: Angle2D<Float>) -> Float { Foundation.cosh(value.radians) }
@inlinable @inline(__always) func cosh(_ value: Angle2D<CGFloat>) -> CGFloat { Foundation.cosh(value.radians) }

@inlinable @inline(__always) func sin(_ value: Angle2D<Double>) -> Double { Foundation.sin(value.radians) }
@inlinable @inline(__always) func sin(_ value: Angle2D<Float>) -> Float { Foundation.sin(value.radians) }
@inlinable @inline(__always) func sin(_ value: Angle2D<CGFloat>) -> CGFloat { Foundation.sin(value.radians) }

@inlinable @inline(__always) func sinh(_ value: Angle2D<Double>) -> Double { Foundation.sinh(value.radians) }
@inlinable @inline(__always) func sinh(_ value: Angle2D<Float>) -> Float { Foundation.sinh(value.radians) }
@inlinable @inline(__always) func sinh(_ value: Angle2D<CGFloat>) -> CGFloat { Foundation.sinh(value.radians) }

@inlinable @inline(__always) func tan(_ value: Angle2D<Double>) -> Double { Foundation.tan(value.radians) }
@inlinable @inline(__always) func tan(_ value: Angle2D<Float>) -> Float { Foundation.tan(value.radians) }
@inlinable @inline(__always) func tan(_ value: Angle2D<CGFloat>) -> CGFloat { Foundation.tan(value.radians) }

@inlinable @inline(__always) func tanh(_ value: Angle2D<Double>) -> Double { Foundation.tanh(value.radians) }
@inlinable @inline(__always) func tanh(_ value: Angle2D<Float>) -> Float { Foundation.tanh(value.radians) }
@inlinable @inline(__always) func tanh(_ value: Angle2D<CGFloat>) -> CGFloat { Foundation.tanh(value.radians) }
