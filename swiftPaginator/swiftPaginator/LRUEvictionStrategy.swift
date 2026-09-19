//
//  LRUEvictionStrategy.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

public struct LRUEvictionStrategy<Key: Hashable & Sendable>:
    PaginatorEvictionStrategy {

    public func keysToEvict(
        from entries: [PaginatorCacheEntry<Key>],
        maxSize: Int
    ) -> Set<Key> {

        guard entries.count > maxSize else {
            return []
        }

        let count = entries.count - maxSize

        return Set(
            entries
                .sorted {
                    $0.lastAccessedAt < $1.lastAccessedAt
                }
                .prefix(count)
                .map(\.key)
        )
    }
}
