//
//  Kompas_idTests.swift
//  Kompas.idTests
//
//  Created by Farhan on 02/08/25.
//

import XCTest
@testable import Kompas_id

final class BookmarkManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        #if DEBUG
        BookmarkManager.shared.useInMemoryStore()
        BookmarkManager.shared.removeAllBookmarks()
        #endif
    }

    func makeArticle(id: String? = nil, title: String = "Judul", published: String = "now") -> GenericArticle {
        return GenericArticle(id: id, title: title, publishedTime: published, description: nil, imageDescription: nil, mediaCount: nil, image: nil)
    }

    func testBookmarkAddAndExists() {
        let article = makeArticle(title: "Satu", published: "1")
        let identifier = article.id ?? article.generateID()

        XCTAssertFalse(BookmarkManager.shared.isArticleBookmarked(identifier))

        BookmarkManager.shared.bookmarkArticle(article)
        XCTAssertTrue(BookmarkManager.shared.isArticleBookmarked(identifier))
    }

    func testDuplicateBookmarkNotDuplicated() {
        let article = makeArticle(title: "Sama", published: "1")
        BookmarkManager.shared.bookmarkArticle(article)
        BookmarkManager.shared.bookmarkArticle(article)

        let list = BookmarkManager.shared.fetchBookmarkedArticles()
        XCTAssertEqual(list.count, 1)
    }

    func testRemoveBookmarkById() {
        let article = makeArticle(title: "Hapus", published: "2")
        let id = article.id ?? article.generateID()
        BookmarkManager.shared.bookmarkArticle(article)
        XCTAssertTrue(BookmarkManager.shared.isArticleBookmarked(id))

        BookmarkManager.shared.removeBookmark(for: id)
        XCTAssertFalse(BookmarkManager.shared.isArticleBookmarked(id))
    }

    func testSortingByTimestampDescending() {
        let a1 = makeArticle(title: "A1", published: "1")
        let a2 = makeArticle(title: "A2", published: "2")
        BookmarkManager.shared.bookmarkArticle(a1)

        usleep(20_000)
        BookmarkManager.shared.bookmarkArticle(a2)

        let list = BookmarkManager.shared.fetchBookmarkedArticles()
        XCTAssertEqual(list.first?.title, "A2")
    }
}
