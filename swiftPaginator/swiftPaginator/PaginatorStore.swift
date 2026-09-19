//
//  PaginatorStore.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

public protocol PaginatorStore<Item, Key>: Sendable {
    associatedtype Item
    associatedtype Key: Hashable & Sendable

    func page(for key: Key) async throws -> PaginatorPage<Item, Key>?

    func save(
        _ page: PaginatorPage<Item, Key>,
        for key: Key
    ) async throws

    func remove(for key: Key) async throws

    func removeAll() async throws
    
    func entries() async throws -> [PaginatorCacheEntry<Key>]
}
