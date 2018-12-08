//
//  ParticalAllocateTableNodeViewController.swift
//  ASTableNodeSample
//
//  Created by Yuta Tasaka on 2018/12/08.
//  Copyright © 2018 Yuta Tasaka. All rights reserved.
//

import AsyncDisplayKit

class PartialAllocateTableNodeViewController: ASViewController<ASTableNode> {

    fileprivate let lock = NSLock()
    fileprivate var _heightCaches = [Int: CGFloat]()
    fileprivate var heightCaches: [Int: CGFloat] {
        get {
            defer { lock.unlock() }
            lock.lock()
            return _heightCaches
        }
        set {
            defer { lock.unlock() }
            lock.lock()
            _heightCaches = newValue
        }
    }

    fileprivate var scrollingToTop = false
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

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        scrollingToTop = true
        resetPosts()
        return true
    }
}

extension PartialAllocateTableNodeViewController {
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

    fileprivate func resetPosts() {
        let currentCount = posts.count
        let newPosts = (currentCount..<(currentCount+Const.fetchCount)).map { (id) -> PostModel in
            return PostModel(id: id)
        }
        self.posts =  newPosts
        heightCaches = [Int: CGFloat]()
        node.reloadData()
    }
}

extension PartialAllocateTableNodeViewController: ASTableDataSource, ASTableDelegate {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        if let heightCache = heightCaches[indexPath.row], heightCache > 0 {
            return createDummyCell(heightCache: heightCache, row: indexPath.row)
        }
        let post = posts[indexPath.row]
        let nodeBlock: ASCellNodeBlock = {
            let cell = PostCellNode(postModel: post)
            return cell
        }
        scrollingToTop = false
        return nodeBlock
    }

    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        guard let indexPath = node.indexPath else { return }

        showCell(indexPath: indexPath)

        if indexPath.row == posts.count - 1 {
            appendPosts()
        }
    }

    func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode) {
        guard let indexPath = node.indexPath else { return }
        hideCell(indexPath: indexPath)
    }

    func createDummyCell(heightCache:  CGFloat, row: Int) -> ASCellNodeBlock {
        let height = heightCaches[row] ?? 0.0
        let width = node.bounds.width
        let nodeBlock: ASCellNodeBlock = {
            let cell = DummyCellNode()
            cell.style.preferredSize = CGSize(width: width, height: height)
            return cell
        }
        return nodeBlock
    }

    func showCell(indexPath: IndexPath) {
        if scrollingToTop { return }
        guard let _ = self.node.nodeForRow(at: indexPath) as? DummyCellNode else { return }
        var heightCaches = self.heightCaches
        heightCaches[indexPath.row] = 0.0
        self.heightCaches = heightCaches
        self.node.performBatchUpdates({ [weak self] in
            self?.node.reloadRows(at: [indexPath], with: .none)
        })
    }

    func hideCell(indexPath: IndexPath) {
        if scrollingToTop { return }

        guard let cell = node.nodeForRow(at: indexPath) else { return }
        let height = cell.frame.height

        node.performBatchUpdates({ [weak self] in
            if var heightCaches = self?.heightCaches {
                heightCaches[indexPath.row] = height
                self?.heightCaches = heightCaches
            }
            self?.node.reloadRows(at: [indexPath], with: .none)
        })
    }
}
