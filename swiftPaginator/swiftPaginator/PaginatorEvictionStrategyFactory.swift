//
//  PaginatorEvictionStrategyFactory.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

enum PaginatorEvictionStrategyFactory {

    static func make<Key>(
        for policy: PaginatorEvictionPolicy
    ) -> any PaginatorEvictionStrategy<Key> where Key: Hashable & Sendable {

        switch policy {
        case .LRU:
            LRUEvictionStrategy()
        }
    }
}
