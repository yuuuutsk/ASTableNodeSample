//
//  PostCellNode.swift
//  ASTableNodeSample
//
//  Created by Yuta Tasaka on 2018/12/08.
//  Copyright © 2018 Yuta Tasaka. All rights reserved.
//

import AsyncDisplayKit

class PostCellNode: ASCellNode {

    fileprivate let textNodes: [ASTextNode]

    init(postModel: PostModel) {
        let count = 100
        self.textNodes = (0...count).map({ (_) -> ASTextNode in
            let node = ASTextNode()
            node.style.preferredSize = CGSize(width: 2, height: 140.0)
            node.attributedText = NSAttributedString(string: "\(postModel.id)")
            node.backgroundColor = .gray
            return node
        })
        super.init()
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let horizontalStack = ASStackLayoutSpec.horizontal()
        horizontalStack.alignItems = .center
        horizontalStack.children = textNodes

        return horizontalStack
    }
}
