//
//  PaginatorProtocol.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

public protocol PaginatorProtocol<Item, Key> {
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
    ) async throws -> PaginatorPage<Item, Key>

    func clear(key: Key) async throws
    
    func clearAll() async throws
}
