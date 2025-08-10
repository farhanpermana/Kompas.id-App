//
//  BookmarkManager.swift
//  Kompas.id
//
//  Created by Farhan on 07/08/25.
//

import CoreData
import UIKit
import RxSwift
import RxRelay

class BookmarkManager {
    static let shared = BookmarkManager()
    
    private init() {}
    
    let bookmarkStatusChanged = PublishRelay<Void>()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BookmarksModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private func makeIdentifier(for article: GenericArticle) -> String {
        return article.id ?? article.generateID()
    }

    func bookmarkArticle(_ article: GenericArticle) {
        context.performAndWait { [weak self] in
            guard let self = self else { return }
            let identifier = self.makeIdentifier(for: article)

            if self.isArticleBookmarked(identifier) {
                self.bookmarkStatusChanged.accept(())
                return
            }
            let bookmark = BookmarkedArticle(context: self.context)
            bookmark.title = article.title
            bookmark.publishedTime = article.publishedTime
            bookmark.identifier = identifier
            bookmark.timeStamp = Date()
            self.saveContext()
            self.bookmarkStatusChanged.accept(())
        }
    }
    
    func removeBookmark(for article: GenericArticle) {
        removeBookmark(for: makeIdentifier(for: article))
    }
    
    func removeBookmark(for articleID: String) {
        context.performAndWait { [weak self] in
            guard let self = self else { return }
            let fetchRequest: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", articleID)
            do {
                let bookmarks = try self.context.fetch(fetchRequest)
                for bookmark in bookmarks {
                    self.context.delete(bookmark)
                }
                self.saveContext()
                self.bookmarkStatusChanged.accept(())
            } catch {
                print("Error fetching bookmarks by ID: \(error)")
            }
        }
    }
    
    func isArticleBookmarked(_ articleID: String) -> Bool {
        var exists = false
        context.performAndWait {
            let fetchRequest: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", articleID)
            do {
                let count = try context.count(for: fetchRequest)
                exists = count > 0
            } catch {
                print("Error checking bookmark: \(error)")
                exists = false
            }
        }
        return exists
    }
    
    func fetchBookmarkedArticles() -> [BookmarkedArticle] {
        var results: [BookmarkedArticle] = []
        context.performAndWait {
            let fetchRequest: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
            let sort = NSSortDescriptor(key: "timeStamp", ascending: false)
            fetchRequest.sortDescriptors = [sort]
            do {
                results = try context.fetch(fetchRequest)
            } catch {
                print("Error fetching bookmarks: \(error)")
                results = []
            }
        }
        return results
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            print("Failed saving context: \(nserror), \(nserror.userInfo)")
            context.rollback()
        }
    }

#if DEBUG
    /// testing purpose
    func useInMemoryStore() {
        let container = NSPersistentContainer(name: "BookmarksModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error configuring in-memory store: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.persistentContainer = container
    }

    func removeAllBookmarks() {
        context.performAndWait {
            let fetchRequest: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
            do {
                let bookmarks = try context.fetch(fetchRequest)
                for b in bookmarks { context.delete(b) }
                saveContext()
            } catch {
                print("Failed to clear bookmarks: \(error)")
            }
        }
    }
#endif
}
