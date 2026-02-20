//
//  Copyright 2025 Florian Pircher
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

/// A parser for accessing the elements of a span.
public struct ParserSpan<Element>: ~Escapable, ~Copyable {
	/// The span that is parsed by the parser.
	public let span: Span<Element>
	@usableFromInline
	var _position: Int
	/// The index of the current element (the next element to be parsed).
	///
	/// The parser is at the end when its position is equal to ``span.count``.
	@inlinable
	public var position: Int { self._position }
	
	/// Creates a parser for parsing the given span.
	@inlinable
	@_lifetime(copy span)
	public init(_ span: Span<Element>, position: Int = 0) {
		precondition(position <= span.count)
		self.span = span
		self._position = position
	}
	
	/// The count of unparsed elements, that is, the elements starting at ``position``.
	@inlinable
	public var count: Int {
		self.span.count &- self._position
	}
	
	/// Whether the parser is at the end of the span and no more elements can be read.
	@inlinable
	public var isEmpty: Bool {
		self._position == self.span.count
	}
	
	/// Returns the currently unparsed part of the span, or an empty subsequence if the parser is at the end of the span.
	@inlinable
	@_lifetime(copy self)
	public func remainder() -> Span<Element> {
		unsafe self.span.extracting(unchecked: self._position ..< self.span.count)
	}
	
	// MARK: Advance
	
	/// Advances the parser by one element.
	///
	/// > Important: Only call this method if the parser is not at the end.
	/// > Otherwise, a precondition failure is triggered.
	@inlinable
	public mutating func advance() {
		precondition(self._position < self.span.count)
		self._position &+= 1
	}
	
	/// Advances the parser by one element.
	///
	/// > Important: Only call this method if the parser is not at the end.
	/// > Failure to satisfy that assumption is a serious programming error.
	@inlinable
	@unsafe
	public mutating func uncheckedAdvance() {
		assert(self._position < self.span.count)
		self._position &+= 1
	}
	
	/// Offsets the parser by the given number of elements.
	///
	/// The distance can be negative; moving the parsing position backwards.
	///
	/// > Important: Only call this method if advancing the parser by the given distance does not move past the start or end of the sapn.
	/// > Otherwise, a precondition failure is triggered.
	@inlinable
	@_lifetime(copy self)
	public mutating func advance(by distance: Int) {
		precondition(self._position + distance <= self.span.count)
		precondition(self._position + distance >= 0)
		self._position &+= distance
	}
	
	/// Offsets the parser by the given number of elements.
	///
	/// The distance can be negative; moving the parsing position backwards.
	///
	/// > Important: Only call this method if advancing the parser by the given distance does not move past the start or end of the span.
	/// > Failure to satisfy that assumption is a serious programming error.
	@inlinable
	@unsafe
	@_lifetime(copy self)
	public mutating func uncheckedAdvance(by distance: Int) {
		assert(self._position + distance <= self.span.count)
		assert(self._position + distance >= 0)
		self._position &+= distance
	}
	
	/// Advances the parser while `predicate` returns `true`.
	///
	/// If the parser reaches the end of the span, it will stop advancing.
	///
	/// ## Examples
	///
	/// Skip whitespace:
	///
	/// ```swift
	/// parser.advance(while: \.isWhitespace)
	/// ```
	///
	/// Skip letters until an `x` is encountered:
	///
	/// ```swift
	/// parser.advance(while: { $0.isLetter && $0 != "x" })
	/// ```
	///
	/// - Parameter predicate: A closure that takes the current element as its argument and returns whether the parser should advance past that element.
	@inlinable
	@_lifetime(copy self)
	public mutating func advance<E>(
		while predicate: (Element) throws(E) -> Bool,
	) throws(E) {
		var position = self._position
		
		while position < self.span.count {
			let element = unsafe self.span[unchecked: position]
			guard try predicate(element) else {
				break
			}
			position += 1
		}
		
		self._position = position
	}
	
	// MARK: Peek
	
	/// Returns the current element, or `nil` if the parser is at the end of the span.
	@inlinable
	public func peek() -> Element? {
		guard !self.isEmpty else {
			return nil
		}
		return unsafe self.span[unchecked: self._position]
	}
	
	/// Returns the next two elements, if available.
	@_disfavoredOverload
	@inlinable
	public func peek() -> (Element, Element)? {
		guard let a = self.peek() else {
			return nil
		}
		let bIndex = self._position + 1
		guard bIndex < self.span.count else {
			return nil
		}
		return (a, unsafe self.span[unchecked: bIndex])
	}
	
	/// Returns the next three elements, if available.
	@_disfavoredOverload
	@inlinable
	public func peek() -> (Element, Element, Element)? {
		guard let a = self.peek() else {
			return nil
		}
		let bIndex = self._position + 1
		guard bIndex < self.span.count else {
			return nil
		}
		let cIndex = bIndex + 1
		guard cIndex < self.span.count else {
			return nil
		}
		return (a, unsafe self.span[unchecked: bIndex], unsafe self.span[unchecked: cIndex])
	}
	
	// MARK: Pop
	
	/// Returns the current element and advances the parser, or returns `nil` if the parser is at the end of the span.
	@inlinable
	@discardableResult
	public mutating func pop() -> Element? {
		guard !self.isEmpty else {
			return nil
		}
		return unsafe self.uncheckedPop()
	}
	
	/// Returns the current element and advances the parser, or returns `nil` if the parser is at the end of the span.
	///
	/// > Important: Only call this method if the parser is not at the end.
	/// > Otherwise, a precondition failure is triggered.
	@inlinable
	@unsafe
	@_lifetime(copy self)
	mutating func uncheckedPop() -> Element {
		assert(self._position < self.span.count)
		defer {
			self._position &+= 1
		}
		return unsafe self.span[unchecked: self._position]
	}
	
	/// Returns whether the current element is equal to the given element, and advances the parser by that element if so.
	@inlinable
	@_lifetime(copy self)
	public mutating func pop(_ element: Element) -> Bool where Element: Equatable {
		guard let head = self.peek(), head == element else {
			return false
		}
		unsafe self.uncheckedAdvance()
		return true
	}
	
	/// Returns the current element if it matches the given predicate, and advances the parser by that element if so.
	///
	/// - Returns: The current element if it matches the given predicate, or `nil` if the parser is at the end of the span or the current element does not match the given predicate.
	@inlinable
	@_lifetime(copy self)
	public mutating func pop<E>(
		where predicate: (Element) throws(E) -> Bool,
	) throws(E) -> Element? {
		guard let element = self.peek(), try predicate(element) else {
			return nil
		}
		unsafe self.uncheckedAdvance()
		return element
	}
	
	// MARK: Read
	
	/// Returns a prefix of the remainder of the span matching the given element count and advances the parser, or `nil`, if the remainder is shorter then the count.
	@inlinable
	@_lifetime(copy self)
	public mutating func read(count: UInt) -> Span<Element>? {
		let count = Int(count)
		let startIndex = self.position
		let endIndex = startIndex + count
		guard endIndex < self.span.count else {
			return nil
		}
		unsafe self.uncheckedAdvance(by: count)
		return unsafe self.span.extracting(unchecked: startIndex ..< endIndex)
	}
	
	/// Returns a prefix containing the elements until `predicate` returns `false`, and advances the parser by that prefix if so.
	///
	/// If the parser reaches the end of the span, it will stop reading.
	///
	/// - Parameter predicate: A closure that takes the current element as its argument and returns whether the parser should advance past that element.
	@inlinable
	@_lifetime(copy self)
	public mutating func read<E>(
		while predicate: (Element) throws(E) -> Bool,
	) throws(E) -> Span<Element> {
		let startIndex = self._position
		var endIndex = startIndex
		
		while endIndex < self.span.count {
			let element = unsafe self.span[unchecked: endIndex]
			guard try predicate(element) else {
				break
			}
			endIndex += 1
		}
		
		self._position = endIndex
		
		return unsafe self.span.extracting(unchecked: startIndex ..< endIndex)
	}
}
