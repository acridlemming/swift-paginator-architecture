//
//  PaginatorScheduler.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 20.09.2026.
//

public actor PaginatorScheduler: PaginatorSchedulerProtocol {

    private let maxConcurrentRequests: Int

    private var runningRequests = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []

    public init(maxConcurrentRequests: Int) {
        precondition(maxConcurrentRequests > 0)
        self.maxConcurrentRequests = maxConcurrentRequests
    }

    public func schedule<T: Sendable>(
        operation: @Sendable () async throws -> T
    ) async throws -> T {

        await acquireSlot()

        defer {
            releaseSlot()
        }

        return try await operation()
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
