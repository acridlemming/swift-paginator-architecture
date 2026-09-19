//
//  PaginatorEvictionStrategy.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

public protocol PaginatorEvictionStrategy<Key>: Sendable {
    associatedtype Key: Hashable & Sendable

    func keysToEvict(
        from entries: [PaginatorCacheEntry<Key>],
        maxSize: Int
    ) -> Set<Key>
}
