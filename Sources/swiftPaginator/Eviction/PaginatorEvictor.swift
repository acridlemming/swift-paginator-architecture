//
//  PaginatorEvictor.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

public struct PaginatorEvictor<Key: Hashable & Sendable>: Sendable {

    private let strategy: any PaginatorEvictionStrategy<Key>
    private let maxSize: Int

    public init(policy: PaginatorEvictionPolicy, maxSize: Int) {
        self.strategy = PaginatorEvictionStrategyFactory.make(
            for: policy
        )
        self.maxSize = maxSize
    }

    public func keysToEvict(
        from entries: [PaginatorCacheEntry<Key>]
    ) -> Set<Key> {
        strategy.keysToEvict(from: entries, maxSize: maxSize)
    }
}
