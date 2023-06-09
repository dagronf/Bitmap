//
//  File.swift
//  
//
//  Created by Darren Ford on 16/6/2023.
//

import Foundation
import CoreGraphics

#if os(macOS)
import AppKit.NSImage
#else
import UIKit
#endif

#if os(macOS)
import AppKit
typealias PlatformImage = NSImage
extension NSImage {
	public var cgImage: CGImage? { self.cgImage(forProposedRect: nil, context: nil, hints: nil) }
}
#else
import UIKit
typealias PlatformImage = UIImage
#endif

#if !os(macOS)
extension CGColor {
	public static let black = CGColor(colorSpace: .init(name: CGColorSpace.linearGray)!, components: [0, 1])!
	public static let white = CGColor(colorSpace: .init(name: CGColorSpace.linearGray)!, components: [1, 1])!
}
#endif

#if os(macOS)
public extension Bitmap {
	/// Create a bitmap context containing an image
	init(_ image: NSImage) throws {
		guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
			throw BitmapError.cannotCreateCGImage
		}
		try self.init(cgImage)
	}

	/// Returns a platform-specific image
	var image: NSImage? {
		guard let cgImage = self.cgImage else { return nil }
		return NSImage(cgImage: cgImage, size: .zero)
	}
}
#else
public extension Bitmap {
	/// Returns a platform-specific image
	var image: UIImage? {
		guard let cgImage = self.cgImage else { return nil }
		return UIImage(cgImage: cgImage)
	}
}
#endif

#if !os(macOS)
public struct NSEdgeInsets {
	public let top: CGFloat
	public let left: CGFloat
	public let bottom: CGFloat
	public let right: CGFloat
	public init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
		self.top = top
		self.left = left
		self.bottom = bottom
		self.right = right
	}
}
#endif
