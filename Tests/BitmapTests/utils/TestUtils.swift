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

// Note:  DateFormatter is thread safe
// See https://developer.apple.com/documentation/foundation/dateformatter#1680059
private let iso8601Formatter: DateFormatter = {
	let dateFormatter = DateFormatter()
	dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX ISO8601
	dateFormatter.dateFormat = "yyyy-MM-dd'T'HHmmssSSSZ"
	return dateFormatter
}()

class TestOutputContainer {
	let _root = FileManager.default.temporaryDirectory
	let _container: URL

	init(title: String) {
		_container = _root
			.appendingPathComponent(title)
			.appendingPathComponent(iso8601Formatter.string(from: Date()))
		try! FileManager.default.createDirectory(at: _container, withIntermediateDirectories: true)

		// Create a symbolic link for the latest results
		let latest = _root.appendingPathComponent(title).appendingPathComponent("_latest")
		try? FileManager.default.removeItem(at: latest)
		try! FileManager.default.createSymbolicLink(at: latest, withDestinationURL: _container)
		Swift.print("Temp files at: \(_container)")
	}

	func testFilenameWithName(_ name: String) throws -> URL {
		_container.appendingPathComponent(name)
	}
}

let OperatingSystemVersion: String = { ProcessInfo.processInfo.operatingSystemVersionString }()

#if os(macOS)

let DeviceModel: String = {
	var size = 0
	sysctlbyname("hw.model", nil, &size, nil, 0)
	var machine = [CChar](repeating: 0,  count: size)
	sysctlbyname("hw.model", &machine, &size, nil, 0)
	return String(cString: machine)
}()

//let CurrentMacModel: String? = {
//	let service = IOServiceGetMatchingService(
//		kIOMainPortDefault,
//		IOServiceMatching("IOPlatformExpertDevice")
//	)
//	defer { IOObjectRelease(service) }
//	if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
//		if let modelIdentifierCString = String(data: modelData, encoding: .utf8)?.cString(using: .utf8) {
//			return String(cString: modelIdentifierCString)
//		}
//	}
//	return nil
//}()

#endif
