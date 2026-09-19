//
//  InMemoryPaginatorCache.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

import Foundation

public actor InMemoryPaginatorCache<
    Item: Sendable,
    Key: Hashable & Sendable
>: PaginatorCache {

    private struct Entry {
        let page: PaginatorPage<Item, Key>
        let createdAt: Date
        var lastAccessedAt: Date
    }

    private var storage: [Key: Entry] = [:]

    public func page(for key: Key) -> PaginatorPage<Item, Key>? {
        guard var entry = storage[key] else {
            return nil
        }

        entry.lastAccessedAt = Date()
        storage[key] = entry

        return entry.page
    }

    public func insert(
        _ page: PaginatorPage<Item, Key>,
        for key: Key
    ) {
        let now = Date()

        storage[key] = Entry(
            page: page,
            createdAt: now,
            lastAccessedAt: now
        )
    }

    public func entries() -> [PaginatorCacheEntry<Key>] {
        storage.map {
            PaginatorCacheEntry(
                key: $0.key,
                createdAt: $0.value.createdAt,
                lastAccessedAt: $0.value.lastAccessedAt
            )
        }
    }
    
    public func remove(for key: Key) {
        storage.removeValue(forKey: key)
    }
    
    public func removeAll() {
        storage.removeAll()
    }
}
