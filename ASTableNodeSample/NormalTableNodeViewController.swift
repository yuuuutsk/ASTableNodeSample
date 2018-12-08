//
//  ViewController.swift
//  ASTableNodeSample
//
//  Created by Yuta Tasaka on 2018/12/08.
//  Copyright © 2018 Yuta Tasaka. All rights reserved.
//

import AsyncDisplayKit

class NormalTableNodeViewController: ASViewController<ASTableNode> {

    fileprivate var posts = [PostModel]()

    fileprivate struct Const {
        static let fetchCount = 20
    }

    init() {
        super.init(node: ASTableNode())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appendPosts()

        node.allowsSelection = false
        node.view.separatorStyle = .none
        node.dataSource = self
        node.delegate = self
        node.leadingScreensForBatching = 2.5
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension NormalTableNodeViewController {
    fileprivate func appendPosts() {
        var currentCount = posts.count
        let newPosts = (currentCount..<(currentCount+Const.fetchCount)).map { (id) -> PostModel in
            return PostModel(id: id)
        }
        let indexPaths = newPosts.map { _ -> IndexPath in
            let indexPath = IndexPath(row: currentCount, section: 0)
            currentCount += 1
            return indexPath
        }
        node.performBatchUpdates({ [weak self] in
            self?.posts += newPosts
            self?.node.insertRows(at: indexPaths, with: .none)
        }, completion: nil)
    }
}

extension NormalTableNodeViewController: ASTableDataSource, ASTableDelegate {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = posts[indexPath.row]
        let nodeBlock: ASCellNodeBlock = {
            let cell = PostCellNode(postModel: post)
            return cell
        }
        return nodeBlock
    }
    
    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        guard let indexPath = node.indexPath else { return }

        if indexPath.row == posts.count - 1 {
            appendPosts()
        }
    }

    func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode) {
        guard let indexPath = node.indexPath else { return }
    }
}
