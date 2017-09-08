//
//  ALViewExtension.swift
//  365Scores
//
//  Created by Milos Ljubevski on 11/22/16.
//  Copyright © 2016 for-each. All rights reserved.
//

import Foundation
import UIKit
// y = a + b*x


/*
 typedef NS_ENUM(NSInteger, NSLayoutAttribute) {
 NSLayoutAttributeLeft = 1,
 NSLayoutAttributeRight,
 NSLayoutAttributeTop,
 NSLayoutAttributeBottom,
 NSLayoutAttributeLeading,
 NSLayoutAttributeTrailing,
 NSLayoutAttributeWidth,
 NSLayoutAttributeHeight,
 NSLayoutAttributeCenterX,
 NSLayoutAttributeCenterY,
 NSLayoutAttributeLastBaseline,
 NSLayoutAttributeBaseline NS_SWIFT_UNAVAILABLE("Use 'lastBaseline' instead") = NSLayoutAttributeLastBaseline,
 NSLayoutAttributeFirstBaseline NS_ENUM_AVAILABLE_IOS(8_0),
 
 NSLayoutAttributeLeftMargin NS_ENUM_AVAILABLE_IOS(8_0),
 NSLayoutAttributeRightMargin NS_ENUM_AVAILABLE_IOS(8_0),
 NSLayoutAttributeTopMargin NS_ENUM_AVAILABLE_IOS(8_0),
 NSLayoutAttributeBottomMargin NS_ENUM_AVAILABLE_IOS(8_0),
 NSLayoutAttributeLeadingMargin NS_ENUM_AVAILABLE_IOS(8_0),
 NSLayoutAttributeTrailingMargin NS_ENUM_AVAILABLE_IOS(8_0),
 NSLayoutAttributeCenterXWithinMargins NS_ENUM_AVAILABLE_IOS(8_0),
 NSLayoutAttributeCenterYWithinMargins NS_ENUM_AVAILABLE_IOS(8_0),
 
 NSLayoutAttributeNotAnAttribute = 0
 };
 */

struct Dim
{
    private(set) var multiplier: CGFloat = 1
    private(set) var constant: CGFloat = 0
    
    static var zero: Dim
    {
        return Dim()
    }
    
    init() { }
    
    init(multiplier: CGFloat)
    {
        self.multiplier = multiplier
    }
    
    init(constant: CGFloat)
    {
        self.constant = constant
    }
    
    init(constant: CGFloat, multiplier: CGFloat)
    {
        self.constant = constant
        self.multiplier = multiplier
    }
}

struct Parameters
{
    let targetView: UIView
    let targetAttribute: NSLayoutAttribute
    private(set) var siblingView: UIView! = nil
    private(set) var siblingAttribute: NSLayoutAttribute = .notAnAttribute
    private(set) var relation: NSLayoutRelation = .equal
    
    init(targetView: UIView, targetAttribute: NSLayoutAttribute)
    {
        self.targetView = targetView
        self.targetAttribute = NSLayoutAttribute(rawValue: targetAttribute.rawValue)!
    }
    
    init(targetView: UIView, targetAttribute: UIView.Attribute, siblingView: UIView!)
    {
        self.targetView = targetView
        self.targetAttribute = NSLayoutAttribute(rawValue: targetAttribute.rawValue)!
        self.siblingView = siblingView
    }
    
    init(targetView: UIView, targetAttribute: UIView.Attribute, siblingView: UIView!, siblingAttribute: UIView.Attribute)
    {
        self.targetView = targetView
        self.siblingView = siblingView
        self.targetAttribute = NSLayoutAttribute(rawValue: targetAttribute.rawValue)!
        self.siblingAttribute = NSLayoutAttribute(rawValue: siblingAttribute.rawValue)!
    }
    
    init(targetView: UIView, targetAttribute: UIView.Attribute, siblingView: UIView!, siblingAttribute: UIView.Attribute, relation: NSLayoutRelation)
    {
        self.targetView = targetView
        self.siblingView = siblingView
        self.targetAttribute = NSLayoutAttribute(rawValue: targetAttribute.rawValue)!
        self.siblingAttribute = NSLayoutAttribute(rawValue: siblingAttribute.rawValue)!
        self.relation = relation
    }
    
    
}

struct ConstraintMapping
{
    let dim: Dim
    let parameters: Parameters
}

public extension UIView
{
    @objc enum Attribute: Int
    {
        case top = 3
        case bottom = 4
        case left = 1
        case right = 2
        
        case width = 7
        case height = 8
        
        case centerX = 9
        case centerY = 10
    }
    
    @objc enum LayoutDirection: Int
    {
        case vertical
        case horizontal
    }
    
    typealias Padding = CGFloat
    typealias Multiplier = CGFloat
    typealias Edge = Attribute
    typealias Dimension = Attribute
}

public class PaddingSize: NSObject
{
    let left: CGFloat
    let right: CGFloat
    let top: CGFloat
    let bottom: CGFloat
    
    static let zero = PaddingSize()
    
    init(left: CGFloat, right: CGFloat)
    {
        self.left = left
        self.right = right
        self.top = 0
        self.bottom = 0
    }
    
    init(top: CGFloat, bottom: CGFloat)
    {
        self.top = top
        self.bottom = bottom
        self.left = 0
        self.right = 0
    }
    
    private override init()
    {
        self.left = 0
        self.right = 0
        self.top = 0
        self.bottom = 0
    }
}

public extension UIView
{
    /// BRIDGING
    ////////////
    @objc func pinEdgesToParent(_ edges: NSArray) -> [NSLayoutConstraint]
    {
        return pinEdgesToParent(edges, padding: 0)
    }
    
    @objc func pinEdgesToParent(_ edges: NSArray, padding: Padding) -> [NSLayoutConstraint]
    {
        guard let edges = edges as? [NSNumber] else { return [NSLayoutConstraint]() }
        return pinEdgesToParent(edges.map {return Edge(rawValue: $0.intValue)!}, padding: padding)
    }

    // MARK:
    // MARK: Instance Methods

    /// PINNING
    ///////////
    func pinAllEdgesToSuperview() -> [NSLayoutConstraint]
    {
        return pinEdgesToParent([.left, .top, .bottom, .right])
    }
    
    func pinAllEdgesToSuperview(padding: Padding) -> [NSLayoutConstraint]
    {
        return pinEdgesToParent([.left, .top, .bottom, .right], padding: padding)
    }
    
    func pinEdgesToParent(_ edges: [Edge]) -> [NSLayoutConstraint]
    {
        return pinEdgesToParent(edges, padding: 0)
    }
    
    func pinEdgeToParent(_ edge: Edge, withPadding padding: Padding = 0.0) -> [NSLayoutConstraint]
    {
        return pinEdgeToParent(edge, withPadding: padding, andMultiplier: 1)
    }
    
    func pinEdgeToParent(_ edge: Edge, withPadding padding: Padding, andMultiplier multiplier: Multiplier) -> [NSLayoutConstraint]
    {
        let dim = Dim(constant: padding, multiplier: multiplier)
        let parameters = Parameters(targetView: self, targetAttribute: edge, siblingView: self.superview, siblingAttribute: edge)
        return setAttributesWithMapping(mappings: [ConstraintMapping(dim: dim, parameters: parameters)])
    }
    
    func pinEdgesToParent(_ edges: [Edge], padding: Padding) -> [NSLayoutConstraint]
    {
        var paddingMapping: [Edge: Padding] = [:]
        for edge in edges
        {
            if(edge == .right || edge == .bottom)
            {
                paddingMapping[edge] = -padding
                continue
            }
            paddingMapping[edge] = padding
        }
        return pinEdgesToParentWithPaddingMapping(paddingMapping)
    }
    
        func pinEdgesToParentWithPaddingMapping(_ paddingMapping: [Edge: Padding]) -> [NSLayoutConstraint]
        {
            var mappings: [ConstraintMapping] = []
            for (edge, padding) in paddingMapping
            {
                let parameters = Parameters(targetView: self, targetAttribute: edge, siblingView: self.superview, siblingAttribute: edge)
                let constraintMApping = ConstraintMapping(dim: Dim(constant: padding), parameters: parameters)
                mappings.append(constraintMApping)
            }
            return setAttributesWithMapping(mappings: mappings)
        }


    
    func centerInParent() -> [NSLayoutConstraint]
    {
        return self.alignAttribute(.centerX, toParentAttribute: .centerX) + self.alignAttribute(.centerY, toParentAttribute: .centerY)
    }

    func centerXInParent(padding: Padding = 0, multiplier: Multiplier = 1) -> [NSLayoutConstraint]
    {
        return self.alignAttribute(.centerX, toParentAttribute: .centerX, padding: padding, multiplier: multiplier)
    }
    
    func centerYInParent(padding: Padding = 0, multiplier: Multiplier = 1) -> [NSLayoutConstraint]
    {
        return self.alignAttribute(.centerY, toParentAttribute: .centerY, padding: padding, multiplier: multiplier)
    }
        
    /// DIMENSIONS
    //////////////
    func setHeightConstraint(_ height: CGFloat) -> [NSLayoutConstraint]
    {
        return createConstraintsWithAtrributeToDimMappings([.height: Dim(constant: height)])
    }
    
    func setWidthConstraint(_ width: CGFloat) -> [NSLayoutConstraint]
    {
        return createConstraintsWithAtrributeToDimMappings([.width: Dim(constant: width)])
    }
    
    func setWidthConstraint(_ width: CGFloat, andHeight height: CGFloat) -> [NSLayoutConstraint]
    {
        return createConstraintsWithAtrributeToDimMappings([.height: Dim(constant: height), .width: Dim(constant: width)])
    }
    
    func setWidthToHeightRatio(_ ratio: CGFloat) -> [NSLayoutConstraint]
    {
        return self.alignAttribute(.width, toSibling: self, withAttribute: .height, padding: 0, multiplier: ratio)
    }
    
    func setHeightToWidthRatio(_ ratio: CGFloat) -> [NSLayoutConstraint]
    {
        return self.alignAttribute(.height, toSibling: self, withAttribute: .width, padding: 0, multiplier: ratio)
    }
    
    func setWidthRelatedToParent(percent: CGFloat, constant: CGFloat = 0) -> [NSLayoutConstraint]
    {
        let dim = Dim(constant: constant, multiplier: percent)
        let parameters = Parameters(targetView: self, targetAttribute: .width, siblingView: self.superview, siblingAttribute: .width)
        return setAttributesWithMapping(mappings: [ConstraintMapping(dim: dim, parameters: parameters)])
    }
    
    func setMaxWidthRelatedToParent(percent: CGFloat, constant: CGFloat) -> [NSLayoutConstraint]
    {
        let dim = Dim(constant: constant, multiplier: percent)
        let parameters = Parameters(targetView: self, targetAttribute: .width, siblingView: self.superview, siblingAttribute: .width, relation: .lessThanOrEqual)
        return setAttributesWithMapping(mappings: [ConstraintMapping(dim: dim, parameters: parameters)])
    }
    
    func setHeightRelatedToParent(percent: CGFloat, constant: CGFloat) -> [NSLayoutConstraint]
    {
        let dim = Dim(constant: constant, multiplier: percent)
        let parameters = Parameters(targetView: self, targetAttribute: .height, siblingView: self.superview, siblingAttribute: .height)
        return setAttributesWithMapping(mappings: [ConstraintMapping(dim: dim, parameters: parameters)])
    }
    
    func setMaxHeightRelatedToParent(percent: CGFloat, constant: CGFloat) -> [NSLayoutConstraint]
    {
        let dim = Dim(constant: constant, multiplier: percent)
        let parameters = Parameters(targetView: self, targetAttribute: .width, siblingView: self.superview, siblingAttribute: .width, relation: .lessThanOrEqual)
        return setAttributesWithMapping(mappings: [ConstraintMapping(dim: dim, parameters: parameters)])
    }
    
    func setHeightAndWidthRelatedToParent(hPercent: CGFloat, wPercent: CGFloat) -> [NSLayoutConstraint]
    {
        return setHeightRelatedToParent(percent: hPercent, constant: 0) + setWidthRelatedToParent(percent: wPercent, constant: 0)
    }
    
    func setHeightRelatedToWidth(ratio: CGFloat) -> [NSLayoutConstraint]
    {
        let dim = Dim(constant: 0, multiplier: ratio)
        let parameters = Parameters(targetView: self, targetAttribute: .height, siblingView: self, siblingAttribute: .width)
        return setAttributesWithMapping(mappings: [ConstraintMapping(dim: dim, parameters: parameters)])
    }
    
    func setWidthRelatedToHeight(ratio: CGFloat) -> [NSLayoutConstraint]
    {
        let dim = Dim(constant: 0, multiplier: ratio)
        let parameters = Parameters(targetView: self, targetAttribute: .width, siblingView: self, siblingAttribute: .height)
        return setAttributesWithMapping(mappings: [ConstraintMapping(dim: dim, parameters: parameters)])
    }
    
    /// ALIGNMENT
    /////////////
    
    // align with parent
    func alignAttribute(_ attribute: Attribute, toParentAttribute parentAttribute: Attribute) -> [NSLayoutConstraint]
    {
        return alignAttribute(attribute, toParentAttribute: parentAttribute, padding: 0)
    }
    
    func alignAttribute(_ attribute: Attribute, toParentAttribute parentAttribute: Attribute, padding: Padding) -> [NSLayoutConstraint]
    {
        return alignAttribute(attribute, toParentAttribute: parentAttribute, padding: padding, multiplier: 1)
    }
    
    func alignAttribute(_ attribute: Attribute, toParentAttribute parentAttribute: Attribute, padding: Padding, multiplier: Multiplier) -> [NSLayoutConstraint]
    {
        return alignAttribute(attribute, toSibling: superview, withAttribute: parentAttribute, padding: padding, multiplier: multiplier)
    }
    
    // align with sibling
    func alignAttribute(_ attribute: Attribute, toSibling sibling: UIView!, withAttribute siblingAttribute: Attribute) -> [NSLayoutConstraint]
    {
        return alignAttribute(attribute, toSibling: sibling, withAttribute: siblingAttribute, padding: 0, multiplier: 1)
    }
    
    func alignAttribute(_ attribute: Attribute, toSibling sibling: UIView!, withAttribute siblingAttribute: Attribute, padding: Padding) -> [NSLayoutConstraint]
    {
        return alignAttribute(attribute, toSibling: sibling, withAttribute: siblingAttribute, padding: padding, multiplier: 1)
    }
    
    func alignAttribute(_ attribute: Attribute, toSibling sibling: UIView!, withAttribute siblingAttribute: Attribute, padding: Padding, multiplier: Multiplier) -> [NSLayoutConstraint]
    {
//        assertThatAttributeIsAlignable(attribute)
//        assertThatAttributeIsAlignable(siblingAttribute)
        
        let dim = Dim(constant: padding, multiplier: multiplier)
        let parameters = Parameters(targetView: self, targetAttribute: attribute, siblingView: sibling, siblingAttribute: siblingAttribute)
        return setAttributesWithMapping(mappings: [ConstraintMapping(dim: dim, parameters: parameters)])
    }
    
    // this function will arange views that are subviews of this view and also silings into horizontal or vertical stack
    
    func arangeSubviewsHorizontally(_ _subviews: [UIView], fixedWidth: CGFloat, withPadding padding: PaddingSize, andDistance distance: CGFloat)
    {
        for (index, view) in _subviews.enumerated()
        {
            if fixedWidth != 0
            {
                view.setWidthConstraint(fixedWidth).activate()
            }
            
            view.pinEdgesToParent([.top, .bottom]).activate()
            
            if index == 0
            {
                view.pinEdgeToParent(.left, withPadding: padding.left).activate()
                continue
            }

            view.alignAttribute(.left, toSibling: _subviews[index - 1], withAttribute: .right, padding: distance).activate()
            
            if index == _subviews.count - 1
            {
                view.pinEdgeToParent(.right, withPadding: padding.right).activate()
            }
            
        }
    }
    
    func arangeSubviewsVertically(_ _subviews: [UIView], fixedHeight: CGFloat, withPadding padding: PaddingSize, andDistance distance: CGFloat)
    {
        for (index, view) in _subviews.enumerated()
        {
            view.setHeightConstraint(fixedHeight).activate()
            
            view.pinEdgesToParent([.left, .right]).activate()
            
            if index == 0
            {
                view.pinEdgeToParent(.top, withPadding: padding.top).activate()
                continue
            }
            
            view.alignAttribute(.top, toSibling: _subviews[index - 1], withAttribute: .bottom, padding: distance).activate()
        }
    }
    
    func arangeSubviews(_ _subviews: [UIView], orientation: LayoutDirection, withPadding padding: PaddingSize, andDistance distance: CGFloat)
    {
        if orientation == .horizontal
        {
            arangeSubviewsHorizontally(_subviews, withPadding: padding, andDistance: distance)
        }
        else if orientation == .vertical
        {
            arangeSubviewsVertically(_subviews, withPadding: padding, andDistance: distance)
        }
        
    }

    private func arangeSubviewsHorizontally(_ _subviews: [UIView], withPadding padding: PaddingSize, andDistance distance: CGFloat)
    {
        for (index, view) in _subviews.enumerated()
        {
            if index > 0
            {
                view.alignAttribute(.width, toSibling: _subviews[index - 1], withAttribute: .width).activate()
            }
            
            view.pinEdgesToParent([.top, .bottom]).activate()
            
            if index == 0
            {
                view.pinEdgeToParent(.left, withPadding: padding.left).activate()
                continue
            }
            else if index == _subviews.count - 1
            {
                view.pinEdgeToParent(.right, withPadding: padding.right).activate()
            }
            
            view.alignAttribute(.left, toSibling: _subviews[index - 1], withAttribute: .right, padding: distance).activate()
        }
    }
    
    private func arangeSubviewsVertically(_ _subviews: [UIView], withPadding padding: PaddingSize, andDistance distance: CGFloat)
    {
        for (index, view) in _subviews.enumerated()
        {
            if index > 0
            {
                view.alignAttribute(.height, toSibling: _subviews[index - 1], withAttribute: .height).activate()
            }
            
            view.pinEdgesToParent([.left, .right]).activate()
            
            if index == 0
            {
                view.pinEdgeToParent(.top, withPadding: padding.top).activate()
                continue
            }
            else if index == _subviews.count - 1
            {
                view.pinEdgeToParent(.bottom, withPadding: padding.bottom).activate()
            }
            
            view.alignAttribute(.top, toSibling: _subviews[index - 1], withAttribute: .bottom, padding: distance).activate()
        }
    }
    
    func wrapSubviews(_ _subviews: [UIView], withFixedSize size: CGSize, orientation: LayoutDirection, padding: PaddingSize, andDistance distance: CGFloat)
    {
        if orientation == .horizontal
        {
            self.horizontallyWrapSubviews(_subviews, withFixedSize: size, padding: padding, andDistance: distance)
        }
        else
        {
            assert(false, "****** verticallyWrappSubviews * f-on not implemented!!!")
        }
    }
    
    private func horizontallyWrapSubviews(_ _subviews: [UIView], withFixedSize size: CGSize, padding: PaddingSize, andDistance distance: CGFloat)
    {
        for (index, view) in _subviews.enumerated()
        {
            view.setHeightConstraint(size.height).activate()
            view.setWidthConstraint(size.width).activate()
            
            if index > 0
            {
                view.alignAttribute(.left, toSibling: _subviews[index - 1], withAttribute: .right, padding: distance).activate()
                view.centerYInParent().activate()
            }
            
            if index == 0
            {
                view.pinEdgeToParent(.left, withPadding: padding.left).activate()
                view.pinEdgeToParent(.top, withPadding: padding.top).activate()
                view.pinEdgeToParent(.bottom, withPadding: padding.bottom).activate()
            }
            else if index == _subviews.count - 1
            {
                view.pinEdgeToParent(.right, withPadding: padding.right).activate()
                view.centerYInParent().activate()
            }
        }
    }

    // MARK:
    // MARK: Private Methods

    private func createConstraintsWithAtrributeToDimMappings(_ dimMappings: [Attribute: Dim]) ->  [NSLayoutConstraint]
    {
        var mappings: [ConstraintMapping] = []
        
        for (edge, dim) in dimMappings
        {
            let parameters = Parameters(targetView: self, targetAttribute: edge, siblingView: nil, siblingAttribute: edge)
            let mapping = ConstraintMapping(dim: dim, parameters: parameters)
            mappings.append(mapping)
        }
        return setAttributesWithMapping(mappings: mappings)
    }

    private func setAttributesWithMapping(mappings: [ConstraintMapping]) -> [NSLayoutConstraint]
    {
        var constraints: [NSLayoutConstraint] = []
        translatesAutoresizingMaskIntoConstraints = false
        
        for map in mappings
        {
            constraints.append(NSLayoutConstraint(item: map.parameters.targetView,
                                             attribute: map.parameters.targetAttribute,
                                             relatedBy: map.parameters.relation,
                                                toItem: map.parameters.siblingView,
                                             attribute: map.parameters.siblingAttribute,
                                            multiplier: map.dim.multiplier,
                                              constant: map.dim.constant))
        }
        return constraints
    }
    
    // MARK:
    // MARK: Helpers

    // aserters
    private func assertThatAttributeIsAlignable(_ attribute: Attribute)
    {
        assert(attribute == .height || attribute == .width , "use alignable attribute!!!")
    }
    
    internal func setRelativeWidthConstraint(_ view: UIView?, percent: CGFloat) -> [NSLayoutConstraint]
    {
        guard let relativeView = view else { return [NSLayoutConstraint]() }
        
        return [NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: relativeView, attribute: .width, multiplier: percent, constant: 0)]
    }
    
    typealias AnimationBlock = ()->()
    
    func animateConstraintChangesWithDuration(_ duration: Double, animationBlock: AnimationBlock?)
    {
        getLastAncessor()?.layoutIfNeeded()
        animationBlock?()

        UIView.animate(withDuration: duration, animations: {
            (self.getLastAncessor())?.layoutIfNeeded()
        })
    }
    
    private func getLastAncessor() -> UIView?
    {
        var superView = self.superview
        
        while superView != nil
        {
            superView = superView?.superview
        }
        
        return superView
    }
    
    @objc func getConstraintWithID(_ identifier: String) -> NSLayoutConstraint?
    {
        var counter1 = 0
        var counter2 = 0
        var c: NSLayoutConstraint? = nil
        guard let superview = self.superview else {return nil}
        
        for constraint in superview.constraints
        {
            if constraint.identifier == identifier
            {
                c = constraint
                counter1 += 1
            }
        }
        
        for constraint in constraints
        {
            if constraint.identifier == identifier
            {
                c = constraint
                counter2 += 1
            }
        }
        if counter1 > 1 || counter2 > 1
        {
            print(">>>>> There are more than one constraint named: \(identifier)!")
        }
        
        return c
    }
}

extension Array where Element: NSLayoutConstraint
{
    func activate()
    {
        NSLayoutConstraint.activate(self)
    }
    
    func deactivate()
    {
        NSLayoutConstraint.deactivate(self)
    }
    
    func setPriority(_ priority: UILayoutPriority)
    {
        for constraint in self
        {
            constraint.priority = priority
        }
    }
}


extension NSArray
{
    func activate()
    {
        if let constraints = self as? [NSLayoutConstraint]
        {
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    func deactivate()
    {
        if let constraints = self as? [NSLayoutConstraint]
        {
            NSLayoutConstraint.deactivate(constraints)
        }
    }
    
    func setPriority(_ priority: UILayoutPriority)
    {
        if let constraints = self as? [NSLayoutConstraint]
        {
            for constraint in constraints
            {
                constraint.priority = priority
            }
        }
    }
}


public extension NSLayoutConstraint
{
    func changeMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint
    {
        let newConstraint = NSLayoutConstraint(
            item: self.firstItem,
            attribute: self.firstAttribute,
            relatedBy: self.relation,
            toItem: self.secondItem,
            attribute: self.secondAttribute,
            multiplier: multiplier,
            constant: self.constant)
        
        newConstraint.priority = self.priority
        
        NSLayoutConstraint.deactivate([self])
        NSLayoutConstraint.activate([newConstraint])
        
        return newConstraint
    }
}

























