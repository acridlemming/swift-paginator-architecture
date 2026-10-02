//
//  PaginatorProtocol.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

public protocol PaginatorProtocol<Item, Key>: Sendable {
    associatedtype Item
    associatedtype Key

    func fetch(
        key: Key,
        pageSize: Int
    ) async throws -> PaginatorPage<Item, Key>

    func fetchAround(
        key: Key,
        pageSize: Int,
        depthLevel: Int,
        direction: PageFetchDirection
    ) -> AsyncThrowingStream<PaginatorPage<Item, Key>, Error>

    func clear(key: Key) async throws
    
    func clearAll() async throws
}
