//
//  PaginatorDataSource.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

public protocol PaginatorDataSource<T, Key>: Sendable {
    associatedtype T
    associatedtype Key
    
    /// Fetch the key page
    func fetch(
        key: Key,
        pageSize: Int
    ) async throws -> PaginatorPage<T, Key>
    
    /// Prefetch pages around the key page
    func fetchAround(
        key: Key,
        pageSize: Int,
        depthLevel: Int,
        direction: PageFetchDirection
    ) async throws -> PaginatorPage<T, Key>
}
