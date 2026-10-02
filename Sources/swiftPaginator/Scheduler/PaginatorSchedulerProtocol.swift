//
//  PaginatorSchedulerProtocol.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 20.09.2026.
//

public protocol PaginatorSchedulerProtocol<
    Item,
    Key
>: Sendable {
    associatedtype Item: Sendable
    associatedtype Key: Hashable & Sendable
    
    func schedule(
        request: PaginatorRequest<Key>,
        operation: @escaping @Sendable () async throws
            -> PaginatorPage<Item, Key>
    ) async throws -> PaginatorPage<Item, Key>
}
