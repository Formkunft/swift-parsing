import Testing
@testable import SpanParsing

// MARK: - Helpers

/// Calls the given closure with a `ParserSpan` over the given array.
private func withParser<E>(
	_ array: ContiguousArray<Int>,
	position: Int = 0,
	_ body: (inout ParserSpan<Int>) throws(E) -> Void,
) throws(E) {
	let span = array.span
	var parser = ParserSpan(span, position: position)
	try body(&parser)
}

@Suite
struct `ParserSpan tests` {
	// MARK: - Init
	
	@Test func `create with span`() {
		withParser([1, 2, 3]) { parser in
			let position = parser.position
			let count = parser.count
			#expect(position == 0)
			#expect(count == 3)
		}
	}
	
	@Test func `create with span and position`() {
		withParser([1, 2, 3], position: 2) { parser in
			let position = parser.position
			let count = parser.count
			#expect(position == 2)
			#expect(count == 1)
		}
	}
	
	@Test func `create with empty span`() {
		withParser([]) { parser in
			let isEmpty = parser.isEmpty
			let position = parser.position
			let count = parser.count
			#expect(isEmpty)
			#expect(position == 0)
			#expect(count == 0)
		}
	}
	
	// MARK: - Position
	
	@Test func `position setter`() {
		withParser([10, 20, 30]) { parser in
			parser.position = 2
			let element = parser.peek()
			#expect(element == 30)
		}
	}
	
	@Test func `position setter to end`() {
		withParser([10, 20, 30]) { parser in
			parser.position = 3
			let isEmpty = parser.isEmpty
			#expect(isEmpty)
		}
	}
	
	@Test func `unchecked reposition`() {
		withParser([10, 20, 30, 40]) { parser in
			unsafe parser.uncheckedReposition(to: 3)
			let element = parser.peek()
			#expect(element == 40)
		}
	}
	
	@Test func `unchecked reposition to start`() {
		withParser([10, 20, 30], position: 2) { parser in
			unsafe parser.uncheckedReposition(to: 0)
			let element = parser.peek()
			#expect(element == 10)
		}
	}
	
	@Test func `unchecked reposition to end`() {
		withParser([10, 20]) { parser in
			unsafe parser.uncheckedReposition(to: 2)
			let isEmpty = parser.isEmpty
			#expect(isEmpty)
		}
	}
	
	// MARK: - State
	
	@Test func `is empty on non empty`() {
		withParser([1, 2, 3]) { parser in
			let isEmpty = parser.isEmpty
			#expect(!isEmpty)
		}
	}
	
	@Test func `is empty after consuming all`() {
		withParser([1]) { parser in
			parser.advance()
			let isEmpty = parser.isEmpty
			#expect(isEmpty)
		}
	}
	
	@Test func `count from start`() {
		withParser([1, 2, 3, 4, 5]) { parser in
			let count = parser.count
			#expect(count == 5)
		}
	}
	
	@Test func `count after advancing`() {
		withParser([1, 2, 3, 4, 5]) { parser in
			parser.advance(by: 3)
			let count = parser.count
			#expect(count == 2)
		}
	}
	
	@Test func `count at end`() {
		withParser([1, 2], position: 2) { parser in
			let count = parser.count
			#expect(count == 0)
		}
	}
	
	@Test func `remainder from start`() {
		withParser([1, 2, 3]) { parser in
			let count = parser.remainder().count
			#expect(count == 3)
		}
	}
	
	@Test func `remainder after advancing`() {
		withParser([1, 2, 3, 4, 5]) { parser in
			parser.advance(by: 3)
			let count = parser.remainder().count
			#expect(count == 2)
		}
	}
	
	@Test func `remainder at end`() {
		withParser([1, 2], position: 2) { parser in
			let count = parser.remainder().count
			#expect(count == 0)
		}
	}
	
	@Test func `remainder of empty`() {
		withParser([]) { parser in
			let count = parser.remainder().count
			#expect(count == 0)
		}
	}
	
	// MARK: - Advance
	
	@Test func `advance by one`() {
		withParser([1, 2, 3]) { parser in
			parser.advance()
			let element = parser.peek()
			#expect(element == 2)
		}
	}
	
	@Test func `unchecked advance`() {
		withParser([1, 2, 3]) { parser in
			unsafe parser.uncheckedAdvance()
			let element = parser.peek()
			#expect(element == 2)
		}
	}
	
	@Test func `advance by distance`() {
		withParser([1, 2, 3, 4, 5, 6]) { parser in
			parser.advance(by: 3)
			let element = parser.peek()
			#expect(element == 4)
		}
	}
	
	@Test func `advance by zero`() {
		withParser([1, 2, 3]) { parser in
			parser.advance(by: 0)
			let element = parser.peek()
			#expect(element == 1)
		}
	}
	
	@Test func `advance by negative distance`() {
		withParser([1, 2, 3, 4, 5], position: 3) { parser in
			parser.advance(by: -2)
			let element = parser.peek()
			#expect(element == 2)
		}
	}
	
	@Test func `unchecked advance by distance`() {
		withParser([1, 2, 3, 4]) { parser in
			unsafe parser.uncheckedAdvance(by: 3)
			let element = parser.peek()
			#expect(element == 4)
		}
	}
	
	@Test func `unchecked advance by negative distance`() {
		withParser([1, 2, 3, 4, 5], position: 4) { parser in
			unsafe parser.uncheckedAdvance(by: -3)
			let element = parser.peek()
			#expect(element == 2)
		}
	}
	
	@Test func `advance while predicate`() {
		withParser([1, 1, 1, 2, 3]) { parser in
			parser.advance(while: { $0 == 1 })
			let element = parser.peek()
			#expect(element == 2)
		}
	}
	
	@Test func `advance while predicate no match`() {
		withParser([5, 6, 7]) { parser in
			parser.advance(while: { $0 == 1 })
			let element = parser.peek()
			#expect(element == 5)
		}
	}
	
	@Test func `advance while predicate all match`() {
		withParser([1, 1, 1]) { parser in
			parser.advance(while: { $0 == 1 })
			let isEmpty = parser.isEmpty
			#expect(isEmpty)
		}
	}
	
	@Test func `advance while predicate on empty`() {
		withParser([]) { parser in
			parser.advance(while: { _ in true })
			let isEmpty = parser.isEmpty
			#expect(isEmpty)
		}
	}
	
	// MARK: - Peek
	
	@Test func `peek single element`() {
		withParser([10, 20, 30]) { parser in
			let element = parser.peek()
			#expect(element == 10)
		}
	}
	
	@Test func `peek single at end`() {
		withParser([]) { parser in
			let element: Int? = parser.peek()
			#expect(element == nil)
		}
	}
	
	@Test func `peek two elements`() {
		withParser([10, 20, 30]) { parser in
			let result: (Int, Int)? = parser.peek()
			#expect(result?.0 == 10)
			#expect(result?.1 == 20)
		}
	}
	
	@Test func `peek two elements with only one available`() {
		withParser([10]) { parser in
			let result: (Int, Int)? = parser.peek()
			#expect(result == nil)
		}
	}
	
	@Test func `peek three elements`() {
		withParser([10, 20, 30, 40]) { parser in
			let result: (Int, Int, Int)? = parser.peek()
			#expect(result?.0 == 10)
			#expect(result?.1 == 20)
			#expect(result?.2 == 30)
		}
	}
	
	@Test func `peek three elements with exactly three available`() {
		withParser([10, 20, 30]) { parser in
			let result: (Int, Int, Int)? = parser.peek()
			#expect(result?.0 == 10)
			#expect(result?.1 == 20)
			#expect(result?.2 == 30)
		}
	}
	
	@Test func `peek three elements with only two available`() {
		withParser([10, 20]) { parser in
			let result: (Int, Int, Int)? = parser.peek()
			#expect(result == nil)
		}
	}
	
	@Test func `peek three elements with none available`() {
		withParser([]) { parser in
			let result: (Int, Int, Int)? = parser.peek()
			#expect(result == nil)
		}
	}
	
	// MARK: - Has Prefix
	
	@Test func `has prefix match`() {
		withParser([1, 2, 3]) { parser in
			let result = parser.hasPrefix(1)
			#expect(result)
		}
	}
	
	@Test func `has prefix no match`() {
		withParser([1, 2, 3]) { parser in
			let result = parser.hasPrefix(2)
			#expect(!result)
		}
	}
	
	@Test func `has prefix at end`() {
		withParser([]) { parser in
			let result = parser.hasPrefix(1)
			#expect(!result)
		}
	}
	
	// MARK: - Pop
	
	@Test func `pop element`() {
		withParser([10, 20, 30]) { parser in
			let element = parser.pop()
			let next = parser.peek()
			#expect(element == 10)
			#expect(next == 20)
		}
	}
	
	@Test func `pop at end`() {
		withParser([]) { parser in
			let element = parser.pop()
			#expect(element == nil)
		}
	}
	
	@Test func `pop specific element match`() {
		withParser([10, 20, 30]) { parser in
			let result = parser.pop(10)
			let next = parser.peek()
			#expect(result == true)
			#expect(next == 20)
		}
	}
	
	@Test func `pop specific element no match`() {
		withParser([10, 20, 30]) { parser in
			let result = parser.pop(99)
			let element = parser.peek()
			#expect(result == false)
			#expect(element == 10)
		}
	}
	
	@Test func `pop specific element at end`() {
		withParser([]) { parser in
			let result = parser.pop(1)
			#expect(result == false)
		}
	}
	
	@Test func `pop where predicate match`() {
		withParser([10, 20, 30]) { parser in
			let element = parser.pop(where: { $0 == 10 })
			let next = parser.peek()
			#expect(element == 10)
			#expect(next == 20)
		}
	}
	
	@Test func `pop where predicate no match`() {
		withParser([10, 20, 30]) { parser in
			let element = parser.pop(where: { $0 == 99 })
			let current = parser.peek()
			#expect(element == nil)
			#expect(current == 10)
		}
	}
	
	@Test func `pop where at end`() {
		withParser([]) { parser in
			let element = parser.pop(where: { _ in true })
			#expect(element == nil)
		}
	}
	
	// MARK: - Read
	
	@Test func `read count`() {
		withParser([1, 2, 3, 4, 5, 6]) { parser in
			if let result = parser.read(count: 3) {
				#expect(result.count == 3)
			}
			else {
				Issue.record("expected non-nil result")
			}
			let next = parser.peek()
			#expect(next == 4)
		}
	}
	
	@Test func `read count zero`() {
		withParser([1, 2, 3]) { parser in
			if let result = parser.read(count: 0) {
				#expect(result.count == 0)
			}
			else {
				Issue.record("expected non-nil result")
			}
			let element = parser.peek()
			#expect(element == 1)
		}
	}
	
	@Test func `read count exact remainder`() {
		withParser([1, 2, 3]) { parser in
			if let result = parser.read(count: 3) {
				#expect(result.count == 3)
			}
			else {
				Issue.record("expected non-nil result")
			}
			let isEmpty = parser.isEmpty
			#expect(isEmpty)
		}
	}
	
	@Test func `read count exceeds remainder`() {
		withParser([1, 2]) { parser in
			let isNil = parser.read(count: 5) == nil
			let element = parser.peek()
			#expect(isNil)
			#expect(element == 1)
		}
	}
	
	@Test func `read count on empty`() {
		withParser([]) { parser in
			let isNil = parser.read(count: 1) == nil
			#expect(isNil)
		}
	}
	
	@Test func `read while predicate`() {
		withParser([1, 1, 1, 2, 3]) { parser in
			let result = parser.read(while: { $0 == 1 })
			let next = parser.peek()
			#expect(result.count == 3)
			#expect(next == 2)
		}
	}
	
	@Test func `read while predicate no match`() {
		withParser([5, 6, 7]) { parser in
			let result = parser.read(while: { $0 == 1 })
			let element = parser.peek()
			#expect(result.count == 0)
			#expect(element == 5)
		}
	}
	
	@Test func `read while predicate all match`() {
		withParser([1, 1, 1]) { parser in
			let result = parser.read(while: { $0 == 1 })
			let isEmpty = parser.isEmpty
			#expect(result.count == 3)
			#expect(isEmpty)
		}
	}
	
	@Test func `read while on empty`() {
		withParser([]) { parser in
			let result = parser.read(while: { _ in true })
			#expect(result.count == 0)
		}
	}
	
	// MARK: - Integration
	
	@Test func `parse sequence of elements`() {
		withParser([1, 2, 3, 4, 5]) { parser in
			let first = parser.pop()
			let popped = parser.pop(2)
			let rest = parser.read(while: { $0 < 10 })
			let isEmpty = parser.isEmpty
			#expect(first == 1)
			#expect(popped == true)
			#expect(rest.count == 3)
			#expect(isEmpty)
		}
	}
}
