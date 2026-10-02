//
//  PaginatorScheduler.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 20.09.2026.
//

public actor PaginatorScheduler<
    Item: Sendable,
    Key: Hashable & Sendable
>: PaginatorSchedulerProtocol {

    private let maxConcurrentRequests: Int

    private var runningRequests = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []
    
    private var inFlight: [
        PaginatorRequest<Key>: Task<PaginatorPage<Item, Key>, Error>
    ] = [:]

    public init(maxConcurrentRequests: Int) {
        precondition(maxConcurrentRequests > 0)
        self.maxConcurrentRequests = maxConcurrentRequests
    }

    public func schedule(
        request: PaginatorRequest<Key>,
        operation: @escaping @Sendable () async throws
            -> PaginatorPage<Item, Key>
    ) async throws -> PaginatorPage<Item, Key> {

        if let task = inFlight[request] {
            return try await task.value
        }

        let task = Task {
            await acquireSlot()

            defer {
                releaseSlot()
            }

            return try await operation()
        }

        inFlight[request] = task

        defer {
            inFlight[request] = nil
        }

        return try await task.value
    }
}

private extension PaginatorScheduler {

    func acquireSlot() async {
        guard runningRequests >= maxConcurrentRequests else {
            runningRequests += 1
            return
        }

        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    func releaseSlot() {
        if waiters.isEmpty {
            runningRequests -= 1
        } else {
            let continuation = waiters.removeFirst()
            continuation.resume()
        }
    }
}
