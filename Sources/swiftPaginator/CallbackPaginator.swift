//
//  CallbackPaginator.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

public final class CallbackPaginator<
    Item: Sendable,
    Key: Hashable & Sendable,
    DataSource: PaginatorDataSource<Item, Key>
>: PaginatorProtocol {
    /// Data source to load data
    private let dataSource: DataSource
    /// Controls the data in cache
    private let validator: (any PageValidator<Item>)?
    /// Scheduler
    private let scheduler: any PaginatorSchedulerProtocol<Item, Key>
    /// On-disk cache
    private let onDiskCache: (any PaginatorStore<Item, Key>)?
    private let onDiskPaginatorEvictor: PaginatorEvictor<Key>?
    /// Pagination config
    private let config: PaginatorConfig
    /// In-Memory cache
    private let inMemoryCache = InMemoryPaginatorCache<Item, Key>()
    private let inMemoryPaginatorEvictor: PaginatorEvictor<Key>
    
    public init(
        dataSource: DataSource,
        validator: (any PageValidator<Item>)? = nil,
        onDiskCache: (any PaginatorStore<Item, Key>)? = nil,
        scheduler: (any PaginatorSchedulerProtocol<Item, Key>)? = nil,
        config: PaginatorConfig = .default
    ) {
        self.dataSource = dataSource
        self.validator = validator
        self.onDiskCache = onDiskCache
        self.config = config
        self.inMemoryPaginatorEvictor = PaginatorEvictor(
            policy: config.inMemoryEvictionPolicy,
            maxSize: config.inMemotyCacheSize
        )
        self.scheduler = scheduler ?? PaginatorScheduler(
            maxConcurrentRequests: config.maxParallelCalls
        )
        if let policy = config.storeEvictionPolicy,
           let size = config.storeCacheSize {
            self.onDiskPaginatorEvictor = PaginatorEvictor(policy: policy, maxSize: size)
        } else {
            self.onDiskPaginatorEvictor = nil
        }
    }
    
    public func fetch(key: Key, pageSize: Int) async throws -> PaginatorPage<Item, Key> {
        if let page = await inMemoryCache.page(for: key) {
            return page
        }
        
        if let page = try await onDiskCache?.page(for: key) {
            return page
        }
        
        let page = try await scheduler.schedule(request: .init(key: key, pageSize: pageSize)) {
            try await self.dataSource.fetch(
                key: key,
                pageSize: pageSize
            )
        }
        
        await cacheInMemory(page, for: key)
        
        do {
            try await cacheOnDisk(page, for: key)
        } catch {
            // MARK: - add logs
        }
        
        return page
    }
    
    public func fetchAround(
        key: Key,
        pageSize: Int,
        depthLevel: Int,
        direction: PageFetchDirection
    ) -> AsyncThrowingStream<PaginatorPage<Item, Key>, Error> {

        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let page = try await fetch(
                        key: key,
                        pageSize: pageSize
                    )

                    continuation.yield(page)

                    switch direction {
                    case .forward:
                        try await streamForward(
                            from: page,
                            pageSize: pageSize,
                            depth: depthLevel,
                            continuation: continuation
                        )

                    case .backward:
                        try await streamBackward(
                            from: page,
                            pageSize: pageSize,
                            depth: depthLevel,
                            continuation: continuation
                        )

                    case .all:
                        // requires a little more thought
                        break
                    }

                    continuation.finish()

                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    public func clear(key: Key) async throws {
        await inMemoryCache.remove(for: key)
        
        try await onDiskCache?.remove(for: key)
    }
    
    public func clearAll() async throws {
        await inMemoryCache.removeAll()
        
        try await onDiskCache?.removeAll()
    }
}

private extension CallbackPaginator {
    private func streamForward(
        from page: PaginatorPage<Item, Key>,
        pageSize: Int,
        depth: Int,
        continuation: AsyncThrowingStream<
            PaginatorPage<Item, Key>,
            Error
        >.Continuation
    ) async throws {

        var nextKey = page.nextKey

        for _ in 0..<depth {
            try Task.checkCancellation()

            guard let key = nextKey else {
                return
            }

            let page = try await fetch(
                key: key,
                pageSize: pageSize
            )

            continuation.yield(page)

            nextKey = page.nextKey
        }
    }
    
    private func streamBackward(
        from page: PaginatorPage<Item, Key>,
        pageSize: Int,
        depth: Int,
        continuation: AsyncThrowingStream<
            PaginatorPage<Item, Key>,
            Error
        >.Continuation
    ) async throws {

        var prevKey = page.prevKey

        for _ in 0..<depth {
            try Task.checkCancellation()

            guard let key = prevKey else {
                return
            }

            let page = try await fetch(
                key: key,
                pageSize: pageSize
            )

            continuation.yield(page)

            prevKey = page.prevKey
        }
    }
    
    func cacheInMemory(
        _ page: PaginatorPage<Item, Key>,
        for key: Key
    ) async {

        await inMemoryCache.insert(page, for: key)

        let entries = await inMemoryCache.entries()

        let keysToEvict = inMemoryPaginatorEvictor.keysToEvict(
            from: entries
        )

        for key in keysToEvict {
            await inMemoryCache.remove(for: key)
        }
    }
    
    func cacheOnDisk(
        _ page: PaginatorPage<Item, Key>,
        for key: Key
    ) async throws {
        
        guard let onDiskCache else { return }

        try await onDiskCache.save(page, for: key)
        
        guard let onDiskPaginatorEvictor else { return }

        let entries = try await onDiskCache.entries()

        let keysToEvict = onDiskPaginatorEvictor.keysToEvict(
            from: entries
        )

        for key in keysToEvict {
            try await onDiskCache.remove(for: key)
        }
    }
}
