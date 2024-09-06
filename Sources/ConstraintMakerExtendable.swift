//
//  SnapKit
//
//  Copyright (c) 2011-Present SnapKit Team - https://github.com/SnapKit
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

public final class ConstraintMakerExtendable {
    
    internal let description: ConstraintDescription
    
    internal init(_ description: ConstraintDescription) {
        self.description = description
    }
    
    internal func relatedTo(_ other: ConstraintRelatableTarget, relation: ConstraintRelation, file: String, line: UInt) -> ConstraintMakerEditable {
        let related: ConstraintItem
        let constant: ConstraintConstantTarget
        
        if let other = other as? ConstraintItem {
            let otherAttributes = other.attributes
            let otherLayoutAttributes = otherAttributes.layoutAttributes
            
            let selfAttributes = description.attributes
            let selfLayoutAttributes = selfAttributes.layoutAttributes
            
            guard otherAttributes == ConstraintAttributes.none ||
                    otherLayoutAttributes.count <= 1 ||
                    otherLayoutAttributes == selfLayoutAttributes ||
                    otherAttributes == .edges && selfAttributes == .margins ||
                    otherAttributes == .margins ||
                    otherAttributes == .directionalEdges && selfAttributes == .directionalMargins ||
                    otherAttributes == .directionalMargins else {
                        fatalError("Cannot constraint to multiple non identical attributes. (\(file), \(line))");
                    }
            
            related = other
            constant = 0.0
        } else if let other = other as? ConstraintView {
            related = ConstraintItem(target: other, attributes: .none)
            constant = 0.0
        } else if let other = other as? ConstraintConstantTarget {
            related = ConstraintItem(target: nil, attributes: .none)
            constant = other
        } else if #available(iOS 9.0, OSX 10.11, *), let other = other as? ConstraintLayoutGuide {
            related = ConstraintItem(target: other, attributes: .none)
            constant = 0.0
        } else {
            fatalError("Invalid constraint. (\(file), \(line))")
        }
        
        let editable = ConstraintMakerEditable(description)
        editable.description.sourceLocation = (file, line)
        editable.description.relation = relation
        editable.description.related = related
        editable.description.constant = constant
        return editable
    }
    
    @discardableResult
    public func equalTo(_ other: ConstraintRelatableTarget, _ file: String = #file, _ line: UInt = #line) -> ConstraintMakerEditable {
        return relatedTo(other, relation: .equal, file: file, line: line)
    }
    
    @discardableResult
    public func equalToSuperview(_ file: String = #file, _ line: UInt = #line) -> ConstraintMakerEditable {
        guard let other = description.item.superview else {
            fatalError("Expected superview but found nil when attempting make constraint `equalToSuperview`.")
        }
        return relatedTo(other, relation: .equal, file: file, line: line)
    }
    
    @discardableResult
    public func lessThanOrEqualTo(_ other: ConstraintRelatableTarget, _ file: String = #file, _ line: UInt = #line) -> ConstraintMakerEditable {
        return relatedTo(other, relation: .lessThanOrEqual, file: file, line: line)
    }
    
    @discardableResult
    public func lessThanOrEqualToSuperview(_ file: String = #file, _ line: UInt = #line) -> ConstraintMakerEditable {
        guard let other = description.item.superview else {
            fatalError("Expected superview but found nil when attempting make constraint `lessThanOrEqualToSuperview`.")
        }
        return relatedTo(other, relation: .lessThanOrEqual, file: file, line: line)
    }
    
    @discardableResult
    public func greaterThanOrEqualTo(_ other: ConstraintRelatableTarget, _ file: String = #file, line: UInt = #line) -> ConstraintMakerEditable {
        return relatedTo(other, relation: .greaterThanOrEqual, file: file, line: line)
    }
    
    @discardableResult
    public func greaterThanOrEqualToSuperview(_ file: String = #file, line: UInt = #line) -> ConstraintMakerEditable {
        guard let other = description.item.superview else {
            fatalError("Expected superview but found nil when attempting make constraint `greaterThanOrEqualToSuperview`.")
        }
        return relatedTo(other, relation: .greaterThanOrEqual, file: file, line: line)
    }
}

extension ConstraintMakerExtendable {
    
    @discardableResult
    public func offset(_ amount: ConstraintOffsetTarget) -> ConstraintMakerEditable {
        return equalToSuperview().offset(amount)
    }
    
    @discardableResult
    public func inset(_ amount: ConstraintInsetTarget) -> ConstraintMakerEditable {
        return equalToSuperview().inset(amount)
    }
}

extension ConstraintMakerExtendable {
    @discardableResult
    public func equalToSuperviewMargin(_ file: String = #file, line: UInt = #line) -> ConstraintMakerEditable {
        guard let other = description.item.superview else {
            fatalError("Expected superview but found nil when attempting make constraint `equalToSuperview`.")
        }
        return relatedTo(other.snp.margins, relation: .equal, file: file, line: line)
    }
    
    @discardableResult
    public func equalToSelf(_ keyPath: KeyPath<ConstraintAttributesDSL, ConstraintItem>, _ file: String = #file, _ line: UInt = #line) -> ConstraintMakerEditable {
        guard let snp = description.item._snp else {
            fatalError("Expected snp but found nil when attempting make constraint `equalToSelf`.")
        }
        return relatedTo(snp[keyPath: keyPath], relation: .equal, file: file, line: line)
    }
    
    @discardableResult
    public func equalToSelfWidth(_ file: String = #file, _ line: UInt = #line) -> ConstraintMakerEditable {
        return equalToSelf(\.width, file, line)
    }
    
    @discardableResult
    public func equalToSelfHeight(_ file: String = #file, _ line: UInt = #line) -> ConstraintMakerEditable {
        return equalToSelf(\.height, file, line)
    }
    
    @discardableResult
    public func equalToSuperview<T: ConstraintRelatableTarget>(_ closure: (ConstraintView) -> T, _ file: String = #file, line: UInt = #line) -> ConstraintMakerEditable {
        guard let other = description.item.superview else {
            fatalError("Expected superview but found nil when attempting make constraint `equalToSuperview`.")
        }
        return relatedTo(closure(other), relation: .equal, file: file, line: line)
    }
    
    @discardableResult
    public func lessThanOrEqualToSuperview<T: ConstraintRelatableTarget>(_ closure: (ConstraintView) -> T, _ file: String = #file, line: UInt = #line) -> ConstraintMakerEditable {
        guard let other = description.item.superview else {
            fatalError("Expected superview but found nil when attempting make constraint `lessThanOrEqualToSuperview`.")
        }
        return relatedTo(closure(other), relation: .lessThanOrEqual, file: file, line: line)
    }
    
    @discardableResult
    public func greaterThanOrEqualToSuperview<T: ConstraintRelatableTarget>(_ closure: (ConstraintView) -> T, _ file: String = #file, line: UInt = #line) -> ConstraintMakerEditable {
        guard let other = description.item.superview else {
            fatalError("Expected superview but found nil when attempting make constraint `greaterThanOrEqualToSuperview`.")
        }
        return relatedTo(closure(other), relation: .greaterThanOrEqual, file: file, line: line)
    }
}

extension ConstraintMakerExtendable {
    
    public var left: ConstraintMakerExtendable {
        description.attributes += .left
        return self
    }
    
    public var top: ConstraintMakerExtendable {
        description.attributes += .top
        return self
    }
    
    public var bottom: ConstraintMakerExtendable {
        description.attributes += .bottom
        return self
    }
    
    public var right: ConstraintMakerExtendable {
        description.attributes += .right
        return self
    }
    
    public var leading: ConstraintMakerExtendable {
        description.attributes += .leading
        return self
    }
    
    public var trailing: ConstraintMakerExtendable {
        description.attributes += .trailing
        return self
    }
    
    public var width: ConstraintMakerExtendable {
        description.attributes += .width
        return self
    }
    
    public var height: ConstraintMakerExtendable {
        description.attributes += .height
        return self
    }
    
    public var centerX: ConstraintMakerExtendable {
        description.attributes += .centerX
        return self
    }
    
    public var centerY: ConstraintMakerExtendable {
        description.attributes += .centerY
        return self
    }
    
    public var lastBaseline: ConstraintMakerExtendable {
        description.attributes += .lastBaseline
        return self
    }
    
    @available(iOS 8.0, OSX 10.11, *)
    public var firstBaseline: ConstraintMakerExtendable {
        description.attributes += .firstBaseline
        return self
    }
    
    @available(iOS 8.0, *)
    public var leftMargin: ConstraintMakerExtendable {
        description.attributes += .leftMargin
        return self
    }
    
    @available(iOS 8.0, *)
    public var rightMargin: ConstraintMakerExtendable {
        description.attributes += .rightMargin
        return self
    }
    
    @available(iOS 8.0, *)
    public var topMargin: ConstraintMakerExtendable {
        description.attributes += .topMargin
        return self
    }
    
    @available(iOS 8.0, *)
    public var bottomMargin: ConstraintMakerExtendable {
        description.attributes += .bottomMargin
        return self
    }
    
    @available(iOS 8.0, *)
    public var leadingMargin: ConstraintMakerExtendable {
        description.attributes += .leadingMargin
        return self
    }
    
    @available(iOS 8.0, *)
    public var trailingMargin: ConstraintMakerExtendable {
        description.attributes += .trailingMargin
        return self
    }
    
    @available(iOS 8.0, *)
    public var centerXWithinMargins: ConstraintMakerExtendable {
        description.attributes += .centerXWithinMargins
        return self
    }
    
    @available(iOS 8.0, *)
    public var centerYWithinMargins: ConstraintMakerExtendable {
        description.attributes += .centerYWithinMargins
        return self
    }
    
    public var edges: ConstraintMakerExtendable {
        description.attributes += .edges
        return self
    }
    public var horizontalEdges: ConstraintMakerExtendable {
        description.attributes += .horizontalEdges
        return self
    }
    public var verticalEdges: ConstraintMakerExtendable {
        description.attributes += .verticalEdges
        return self
    }
    public var directionalEdges: ConstraintMakerExtendable {
        description.attributes += .directionalEdges
        return self
    }
    public var directionalHorizontalEdges: ConstraintMakerExtendable {
        description.attributes += .directionalHorizontalEdges
        return self
    }
    public var directionalVerticalEdges: ConstraintMakerExtendable {
        description.attributes += .directionalVerticalEdges
        return self
    }
    public var size: ConstraintMakerExtendable {
        description.attributes += .size
        return self
    }
    
    @available(iOS 8.0, *)
    public var margins: ConstraintMakerExtendable {
        description.attributes += .margins
        return self
    }
    
    @available(iOS 8.0, *)
    public var directionalMargins: ConstraintMakerExtendable {
        description.attributes += .directionalMargins
        return self
    }
    
    @available(iOS 8.0, *)
    public var centerWithinMargins: ConstraintMakerExtendable {
        description.attributes += .centerWithinMargins
        return self
    }
    
}
