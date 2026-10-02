//
//  PaginatorPage.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

/// Data for a single page
public final class PaginatorPage<T: Sendable, Key: Sendable>: Sendable {
    /// Content of the page
    public let content: [T]
    /// Page's key
    let key: Key
    /// Expiration time (for cache updates)
    let expirationTime: String?
    /// Previous key
    let prevKey: Key?
    /// Next key
    public let nextKey: Key?
    
    public init(
        content: [T],
        key: Key,
        expirationTime: String?,
        prevKey: Key?,
        nextKey: Key?
    ) {
        self.content = content
        self.key = key
        self.expirationTime = expirationTime
        self.prevKey = prevKey
        self.nextKey = nextKey
    }
}
