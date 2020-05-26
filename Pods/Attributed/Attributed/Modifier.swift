//
// Copyright (c) 2015 Hilton Campbell
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

public struct State {
    public var mutableAttributedString: NSMutableAttributedString
    public var range: NSRange
    public var stack: [MarkupElement]
    public var startElement: MarkupElement?
    public var endElement: MarkupElement?
}

public typealias Modifier = (_ state: State) -> Void

public func modifierWithBaseAttributes(_ attributes: [NSAttributedString.Key: Any], modifiers: [Modifier]) -> Modifier {
    return { state in
        state.mutableAttributedString.addAttributes(attributes, range: state.range)

        for count in 0...state.stack.count {
            let localStack = Array(state.stack[0..<count])
            for modifier in modifiers {
                var newState = state
                newState.stack = localStack
                modifier(newState)
            }
        }
    }
}

public typealias Map = (NSAttributedString) -> NSAttributedString

public func selectMap(_ selector: String, _ map: @escaping Map) -> Modifier {
    return { state in
        guard let element = state.stack.last, selector ~= element else { return }

        let attributedString = state.mutableAttributedString.attributedSubstring(from: state.range)
        state.mutableAttributedString.replaceCharacters(in: state.range, with: map(attributedString))
    }
}

public func selectMapBefore(_ selector: String, _ map: @escaping Map) -> Modifier {
    return { state in
        guard let element = state.startElement, selector ~= element else { return }

        let attributedString = state.mutableAttributedString.attributedSubstring(from: state.range)
        state.mutableAttributedString.replaceCharacters(in: state.range, with: map(attributedString))
    }
}

public func selectMapAfter(_ selector: String, _ map: @escaping Map) -> Modifier {
    return { state in
        guard let element = state.endElement, state.stack.isEmpty, selector ~= element else { return }

        let attributedString = state.mutableAttributedString.attributedSubstring(from: state.range)
        state.mutableAttributedString.replaceCharacters(in: state.range, with: map(attributedString))
    }
}

public typealias MapWithContext = (NSAttributedString, NSAttributedString) -> NSAttributedString

public func selectMap(_ selector: String, _ mapWithContext: @escaping MapWithContext) -> Modifier {
    return { state in
        guard let element = state.stack.last, selector ~= element else { return }

        let attributedString = state.mutableAttributedString.attributedSubstring(from: state.range)
        state.mutableAttributedString.replaceCharacters(in: state.range, with: mapWithContext(state.mutableAttributedString, attributedString))
    }
}

public func selectMapBefore(_ selector: String, _ mapWithContext: @escaping MapWithContext) -> Modifier {
    return { state in
        guard let element = state.startElement, selector ~= element else { return }

        let attributedString = state.mutableAttributedString.attributedSubstring(from: state.range)
        state.mutableAttributedString.replaceCharacters(in: state.range, with: mapWithContext(state.mutableAttributedString, attributedString))
    }
}

public func selectMapAfter(_ selector: String, _ mapWithContext: @escaping MapWithContext) -> Modifier {
    return { state in
        guard let element = state.endElement, state.stack.isEmpty, selector ~= element else { return }

        let attributedString = state.mutableAttributedString.attributedSubstring(from: state.range)
        state.mutableAttributedString.replaceCharacters(in: state.range, with: mapWithContext(state.mutableAttributedString, attributedString))
    }
}

public typealias MapWithElement = (MarkupElement, NSAttributedString) -> NSAttributedString

public func selectMap(_ selector: String, _ mapWithElement: @escaping MapWithElement) -> Modifier {
    return { state in
        guard let element = state.stack.last, selector ~= element else { return }

        let attributedString = state.mutableAttributedString.attributedSubstring(from: state.range)
        state.mutableAttributedString.replaceCharacters(in: state.range, with: mapWithElement(element, attributedString))
    }
}

public func selectMapBefore(_ selector: String, _ mapWithElement: @escaping MapWithElement) -> Modifier {
    return { state in
        guard let element = state.startElement, selector ~= element else { return }

        let attributedString = state.mutableAttributedString.attributedSubstring(from: state.range)
        state.mutableAttributedString.replaceCharacters(in: state.range, with: mapWithElement(element, attributedString))
    }
}

public func selectMapAfter(_ selector: String, _ mapWithElement: @escaping MapWithElement) -> Modifier {
    return { state in
        guard let element = state.endElement, state.stack.isEmpty, selector ~= element else { return }

        let attributedString = state.mutableAttributedString.attributedSubstring(from: state.range)
        state.mutableAttributedString.replaceCharacters(in: state.range, with: mapWithElement(element, attributedString))
    }
}
