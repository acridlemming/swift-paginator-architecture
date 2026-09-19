//
//  CallbackPaginator.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 19.09.2026.
//

public final class CallbackPaginator<
    Item,
    Key: Hashable,
    DataSource: PaginatorDataSource<Item, Key>,
    Validator: PageValidator<Item>
>: PaginatorProtocol {
    /// Data source to load data
    private let dataSource: DataSource
    /// Controls the data in cache
    private let validator: Validator
    /// On-disk cache
    private let onDiskCache: (any PaginatorStore<Item, Key>)?
    private var onDiskPaginatorEvictor: PaginatorEvictor<Key>?
    /// Pagination config
    private let config: PaginatorConfig
    /// In-Memory cache
    private let inMemoryCache = InMemoryPaginatorCache<Item, Key>()
    private let inMemoryPaginatorEvictor: PaginatorEvictor<Key>
    
    public init(
        dataSource: DataSource,
        validator: Validator,
        onDiskCache: (any PaginatorStore<Item, Key>)? = nil,
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
        setupOnDiskPaginatorEvictor()
    }
    
    public func fetch(key: Key, pageSize: Int) async throws -> PaginatorPage<Item, Key> {
        if let page = await inMemoryCache.page(for: key) {
            return page
        }
        
        if let page = try await onDiskCache?.page(for: key) {
            return page
        }
        
        let page = try await dataSource.fetch(
            key: key,
            pageSize: pageSize
        )
        
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
    ) async throws -> PaginatorPage<Item, Key> {

        let page = try await fetch(
            key: key,
            pageSize: pageSize
        )

        guard depthLevel > 0 else {
            return page
        }

        switch direction {

        case .forward:
            try? await fetchForward(
                from: page,
                pageSize: pageSize,
                depth: depthLevel
            )

        case .backward:
            try? await fetchBackward(
                from: page,
                pageSize: pageSize,
                depth: depthLevel
            )

        case .all:
            async let forward: Void? = try? fetchForward(
                from: page,
                pageSize: pageSize,
                depth: depthLevel
            )

            async let backward: Void? = try? fetchBackward(
                from: page,
                pageSize: pageSize,
                depth: depthLevel
            )

            _ = await (forward, backward)
        }

        return page
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
    func fetchForward(
        from page: PaginatorPage<Item, Key>,
        pageSize: Int,
        depth: Int
    ) async throws {

        var nextKey = page.nextKey

        for _ in 0..<depth {
            guard let key = nextKey else {
                break
            }

            let nextPage = try await fetch(
                key: key,
                pageSize: pageSize
            )

            nextKey = nextPage.nextKey
        }
    }
    
    func fetchBackward(
        from page: PaginatorPage<Item, Key>,
        pageSize: Int,
        depth: Int
    ) async throws {

        var previousKey = page.prevKey

        for _ in 0..<depth {
            guard let key = previousKey else {
                break
            }

            let previousPage = try await fetch(
                key: key,
                pageSize: pageSize
            )

            previousKey = previousPage.prevKey
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
    
    func setupOnDiskPaginatorEvictor() {
        guard let policy = config.storeEvictionPolicy,
              let size = config.storeCacheSize
        else { return }
        onDiskPaginatorEvictor = PaginatorEvictor(policy: policy, maxSize: size)
    }
}
