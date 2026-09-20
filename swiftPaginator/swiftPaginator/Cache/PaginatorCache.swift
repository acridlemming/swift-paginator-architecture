//
//  PaginatorCache.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

public protocol PaginatorCache<Item, Key>: Sendable {
    associatedtype Item: Sendable
    associatedtype Key: Hashable & Sendable

    func page(
        for key: Key
    ) async -> PaginatorPage<Item, Key>?

    func insert(
        _ page: PaginatorPage<Item, Key>,
        for key: Key
    ) async

    func remove(
        for key: Key
    ) async

    func removeAll() async
}
