//
//  PaginatorConfig.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

public struct PaginatorConfig {
    let maxParallelCalls: Int
    
    // MARK: - In-memory cache properties
    let inMemotyCacheSize: Int
    let inMemoryEvictionPolicy: PaginatorEvictionPolicy
    
    // MARK: - Store cache properties
    let storeCacheSize: Int?
    let storeEvictionPolicy: PaginatorEvictionPolicy?
    
    init(
        maxParallelCalls: Int = 3,
        inMemotyCacheSize: Int,
        inMemoryEvictionPolicy: PaginatorEvictionPolicy,
        storeCacheSize: Int?,
        storeEvictionPolicy: PaginatorEvictionPolicy?
    ) {
        self.maxParallelCalls = maxParallelCalls
        self.inMemotyCacheSize = inMemotyCacheSize
        self.inMemoryEvictionPolicy = inMemoryEvictionPolicy
        self.storeCacheSize = storeCacheSize
        self.storeEvictionPolicy = storeEvictionPolicy
    }
}

// Stubs
public extension PaginatorConfig {
    
    /// Default
    static let `default`: Self = .init(
        maxParallelCalls: 3,
        inMemotyCacheSize: 5,
        inMemoryEvictionPolicy: .LRU,
        storeCacheSize: nil,
        storeEvictionPolicy: nil
    )
}


