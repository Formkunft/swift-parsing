import Testing
@testable import CollectionParsing

@Suite
struct `CollectionParsing tests` {
	// MARK: - Init
	
	@Test func `create with subject`() {
		let subject = "hello"
		let parser = Parser(subject: subject)
		#expect(parser.subject == subject)
		#expect(parser.position == subject.startIndex)
	}
	
	@Test func `create with subject and position`() {
		let subject = "hello"
		let position = subject.index(subject.startIndex, offsetBy: 2)
		let parser = Parser(subject: subject, position: position)
		#expect(parser.position == position)
	}
	
	@Test func `create with empty collection`() {
		let subject = ""
		let parser = Parser(subject: subject)
		#expect(parser.isEmpty)
		#expect(parser.position == subject.startIndex)
	}
	
	// MARK: - Position
	
	@Test func `position setter`() {
		var parser = Parser(subject: [1, 2, 3])
		parser.position = parser.subject.index(parser.subject.startIndex, offsetBy: 2)
		#expect(parser.peek() == 3)
	}
	
	@Test func `position setter to end index`() {
		var parser = Parser(subject: [1, 2, 3])
		parser.position = parser.subject.endIndex
		#expect(parser.isEmpty)
	}
	
	@Test func `unchecked reposition`() {
		var parser = Parser(subject: [10, 20, 30, 40])
		parser.uncheckedReposition(to: parser.subject.index(parser.subject.startIndex, offsetBy: 3))
		#expect(parser.peek() == 40)
	}
	
	@Test func `unchecked reposition to start`() {
		var parser = Parser(subject: [10, 20, 30])
		parser.advance(by: 2)
		parser.uncheckedReposition(to: parser.subject.startIndex)
		#expect(parser.peek() == 10)
	}
	
	@Test func `unchecked reposition to end`() {
		var parser = Parser(subject: [10, 20])
		parser.uncheckedReposition(to: parser.subject.endIndex)
		#expect(parser.isEmpty)
	}
	
	// MARK: - State
	
	@Test func `is empty on non empty`() {
		let parser = Parser(subject: "abc")
		#expect(!parser.isEmpty)
	}
	
	@Test func `is empty after consuming all`() {
		var parser = Parser(subject: "a")
		parser.advance()
		#expect(parser.isEmpty)
	}
	
	@Test func `remainder from start`() {
		let parser = Parser(subject: "hello")
		#expect(parser.remainder() == "hello")
	}
	
	@Test func `remainder after advancing`() {
		var parser = Parser(subject: "hello")
		parser.advance()
		parser.advance()
		#expect(parser.remainder() == "llo")
	}
	
	@Test func `remainder at end`() {
		var parser = Parser(subject: "ab")
		parser.advance()
		parser.advance()
		#expect(parser.remainder() == "")
	}
	
	@Test func `remainder of empty`() {
		let parser = Parser(subject: "")
		#expect(parser.remainder() == "")
	}
	
	// MARK: - Advance
	
	@Test func `advance by one`() {
		var parser = Parser(subject: "abc")
		parser.advance()
		#expect(parser.peek() == "b")
	}
	
	@Test func `advance by distance`() {
		var parser = Parser(subject: "abcdef")
		parser.advance(by: 3)
		#expect(parser.peek() == "d")
	}
	
	@Test func `advance by zero`() {
		var parser = Parser(subject: "abc")
		parser.advance(by: 0)
		#expect(parser.peek() == "a")
	}
	
	@Test func `advance while predicate`() {
		var parser = Parser(subject: "aaabcd")
		parser.advance(while: { $0 == "a" })
		#expect(parser.peek() == "b")
	}
	
	@Test func `advance while predicate no match`() {
		var parser = Parser(subject: "xyz")
		parser.advance(while: { $0 == "a" })
		#expect(parser.peek() == "x")
	}
	
	@Test func `advance while predicate all match`() {
		var parser = Parser(subject: "aaa")
		parser.advance(while: { $0 == "a" })
		#expect(parser.isEmpty)
	}
	
	@Test func `advance while predicate on empty`() {
		var parser = Parser(subject: "")
		parser.advance(while: { _ in true })
		#expect(parser.isEmpty)
	}
	
	@Test func `advance while with borrowing parser`() {
		var parser = Parser(subject: "abcXdef")
		parser.advance(while: { element, parser in
			element != "X"
		})
		#expect(parser.peek() == "X")
	}
	
	@Test func `advance matching regex`() throws {
		var parser = Parser(subject: "abc123xyz")
		try parser.advance(matching: /[a-z]+/)
		#expect(parser.peek() == "1")
	}
	
	@Test func `advance matching regex no match`() throws {
		var parser = Parser(subject: "123abc")
		try parser.advance(matching: /[a-z]+/)
		#expect(parser.peek() == "1")
	}
	
	// MARK: - Peek
	
	@Test func `peek single element`() {
		let parser = Parser(subject: "abc")
		#expect(parser.peek() == "a")
	}
	
	@Test func `peek single at end`() {
		let parser = Parser(subject: "")
		let result: Character? = parser.peek()
		#expect(result == nil)
	}
	
	@Test func `peek two elements`() {
		let parser = Parser(subject: "abc")
		let result: (Character, Character)? = parser.peek()
		#expect(result?.0 == "a")
		#expect(result?.1 == "b")
	}
	
	@Test func `peek two elements with only one available`() {
		let parser = Parser(subject: "a")
		let result: (Character, Character)? = parser.peek()
		#expect(result == nil)
	}
	
	@Test func `peek three elements`() {
		let parser = Parser(subject: "abcd")
		let result: (Character, Character, Character)? = parser.peek()
		#expect(result?.0 == "a")
		#expect(result?.1 == "b")
		#expect(result?.2 == "c")
	}
	
	@Test func `peek three elements with exactly three available`() {
		let parser = Parser(subject: "abc")
		let result: (Character, Character, Character)? = parser.peek()
		#expect(result?.0 == "a")
		#expect(result?.1 == "b")
		#expect(result?.2 == "c")
	}
	
	@Test func `peek three elements with only two available`() {
		let parser = Parser(subject: "ab")
		let result: (Character, Character, Character)? = parser.peek()
		#expect(result == nil)
	}
	
	@Test func `peek three elements with none available`() {
		let parser = Parser(subject: "")
		let result: (Character, Character, Character)? = parser.peek()
		#expect(result == nil)
	}
	
	// MARK: - Has Prefix
	
	@Test func `has prefix element match`() {
		let parser = Parser(subject: "abc")
		#expect(parser.hasPrefix("a"))
	}
	
	@Test func `has prefix element no match`() {
		let parser = Parser(subject: "abc")
		#expect(!parser.hasPrefix("b"))
	}
	
	@Test func `has prefix element at end`() {
		var parser = Parser(subject: "a")
		parser.advance()
		#expect(!parser.hasPrefix("a"))
	}
	
	@Test func `has prefix subsequence match`() {
		let parser = Parser(subject: [1, 2, 3, 4])
		#expect(parser.hasPrefix([1, 2, 3][...]))
	}
	
	@Test func `has prefix subsequence no match`() {
		let parser = Parser(subject: [1, 2, 3])
		#expect(!parser.hasPrefix([1, 3][...]))
	}
	
	@Test func `has prefix subsequence longer than remainder`() {
		var parser = Parser(subject: [1, 2, 3])
		parser.advance(by: 2)
		#expect(!parser.hasPrefix([3, 4][...]))
	}
	
	@Test func `has prefix subsequence empty`() {
		let parser = Parser(subject: [1, 2, 3])
		#expect(parser.hasPrefix([][...] as ArraySlice<Int>))
	}
	
	@Test func `has prefix string protocol`() {
		let parser = Parser(subject: "hello world")
		#expect(parser.hasPrefix("hello" as String))
	}
	
	@Test func `has prefix regex`() {
		let parser = Parser(subject: "123abc")
		#expect(parser.hasPrefix(/\d+/))
	}
	
	@Test func `has prefix regex no match`() {
		let parser = Parser(subject: "abc123")
		#expect(!parser.hasPrefix(/\d+/))
	}
	
	// MARK: - Pop
	
	@Test func `pop element`() {
		var parser = Parser(subject: "abc")
		let element = parser.pop()
		#expect(element == "a")
		#expect(parser.peek() == "b")
	}
	
	@Test func `pop at end`() {
		var parser = Parser(subject: "")
		let element: Character? = parser.pop()
		#expect(element == nil)
	}
	
	@Test func `pop specific element match`() {
		var parser = Parser(subject: "abc")
		let result = parser.pop("a")
		#expect(result)
		#expect(parser.peek() == "b")
	}
	
	@Test func `pop specific element no match`() {
		var parser = Parser(subject: "abc")
		let result = parser.pop("x")
		#expect(!result)
		#expect(parser.peek() == "a")
	}
	
	@Test func `pop specific element at end`() {
		var parser = Parser(subject: "")
		let result = parser.pop("a")
		#expect(!result)
	}
	
	@Test func `pop where predicate match`() {
		var parser = Parser(subject: "abc")
		let element = parser.pop(where: { $0 == "a" })
		#expect(element == "a")
		#expect(parser.peek() == "b")
	}
	
	@Test func `pop where predicate no match`() {
		var parser = Parser(subject: "abc")
		let element = parser.pop(where: { $0 == "x" })
		#expect(element == nil)
		#expect(parser.peek() == "a")
	}
	
	@Test func `pop where at end`() {
		var parser = Parser(subject: "")
		let element: Character? = parser.pop(where: { _ in true })
		#expect(element == nil)
	}
	
	// MARK: - Read
	
	@Test func `read count`() {
		var parser = Parser(subject: "abcdef")
		let result = parser.read(count: 3)
		#expect(result == "abc")
		#expect(parser.peek() == "d")
	}
	
	@Test func `read count zero`() {
		var parser = Parser(subject: "abc")
		let result = parser.read(count: 0)
		#expect(result == "")
		#expect(parser.peek() == "a")
	}
	
	@Test func `read count exact remainder`() {
		var parser = Parser(subject: "abc")
		let result = parser.read(count: 3)
		#expect(result == "abc")
		#expect(parser.isEmpty)
	}
	
	@Test func `read count exceeds remainder`() {
		var parser = Parser(subject: "ab")
		let result = parser.read(count: 5)
		#expect(result == nil)
		#expect(parser.peek() == "a")
	}
	
	@Test func `read count on empty`() {
		var parser = Parser(subject: "")
		let result = parser.read(count: 1)
		#expect(result == nil)
	}
	
	@Test func `read subsequence match`() {
		var parser = Parser(subject: [1, 2, 3, 4])
		let result = parser.read([1, 2, 3][...])
		#expect(result)
		#expect(parser.peek() == 4)
	}
	
	@Test func `read subsequence no match`() {
		var parser = Parser(subject: [1, 2, 3])
		let result = parser.read([1, 3][...])
		#expect(!result)
		#expect(parser.peek() == 1)
	}
	
	@Test func `read string match`() {
		var parser = Parser(subject: "hello world")
		let result = parser.read("hello" as String)
		#expect(result)
		#expect(parser.peek() == " ")
	}
	
	@Test func `read string no match`() {
		var parser = Parser(subject: "hello")
		let result = parser.read("world" as String)
		#expect(!result)
		#expect(parser.peek() == "h")
	}
	
	@Test func `read while predicate`() {
		var parser = Parser(subject: "aaabbb")
		let result = parser.read(while: { $0 == "a" })
		#expect(result == "aaa")
		#expect(parser.peek() == "b")
	}
	
	@Test func `read while predicate no match`() {
		var parser = Parser(subject: "bbb")
		let result = parser.read(while: { $0 == "a" })
		#expect(result == "")
		#expect(parser.peek() == "b")
	}
	
	@Test func `read while predicate all match`() {
		var parser = Parser(subject: "aaa")
		let result = parser.read(while: { $0 == "a" })
		#expect(result == "aaa")
		#expect(parser.isEmpty)
	}
	
	@Test func `read while on empty`() {
		var parser = Parser(subject: "")
		let result = parser.read(while: { _ in true })
		#expect(result == "")
	}
	
	@Test func `read regex match`() throws {
		var parser = Parser(subject: "123abc")
		let match = try parser.read(/\d+/)
		#expect(match != nil)
		#expect(String(match!.output) == "123")
		#expect(parser.peek() == "a")
	}
	
	@Test func `read regex no match`() throws {
		var parser = Parser(subject: "abc123")
		let match = try parser.read(/\d+/)
		#expect(match == nil)
		#expect(parser.peek() == "a")
	}
	
	// MARK: - View
	
	@Test func `with view`() {
		let string = "caf\u{E9}."
		var parser = Parser(subject: string.utf8)
		let word = parser.withView(string.unicodeScalars) { parser in
			String(parser.read(while: { $0.properties.isAlphabetic }))
		}
		#expect(word == "caf\u{E9}")
		#expect(parser.peek() == Character(".").asciiValue)
	}
	
	@Test func `with view position propagates back`() {
		var parser = Parser(subject: [10, 20, 30, 40, 50])
		parser.advance()
		parser.withView([10, 20, 30, 40, 50]) { sub in
			sub.advance(by: 2)
		}
		#expect(parser.peek() == 40)
	}
	
	// MARK: - Int Array
	
	@Test func `parse int array`() {
		var parser = Parser(subject: [1, 2, 3, 4, 5])
		#expect(parser.pop() == 1)
		#expect(parser.pop(2) == true)
		let rest = parser.read(while: { $0 < 10 })
		#expect(Array(rest) == [3, 4, 5])
		#expect(parser.isEmpty)
	}
}
