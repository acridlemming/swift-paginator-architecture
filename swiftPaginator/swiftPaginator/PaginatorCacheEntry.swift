//
//  PaginatorCacheEntry.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

import Foundation

public struct PaginatorCacheEntry<Key: Hashable & Sendable>: Sendable {
    public let key: Key
    public let createdAt: Date
    public let lastAccessedAt: Date
}
