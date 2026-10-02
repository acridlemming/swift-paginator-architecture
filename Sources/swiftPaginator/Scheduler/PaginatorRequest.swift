//
//  PaginatorRequest.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 20.09.2026.
//

public struct PaginatorRequest<Key: Hashable & Sendable>: Hashable, Sendable {
    public let key: Key
    public let pageSize: Int

    public init(key: Key, pageSize: Int) {
        self.key = key
        self.pageSize = pageSize
    }
}
