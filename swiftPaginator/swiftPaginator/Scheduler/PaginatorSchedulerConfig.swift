//
//  PaginatorSchedulerConfig.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 20.09.2026.
//

public struct PaginatorSchedulerConfig: Sendable {
    public let maxConcurrentRequests: Int

    public init(maxConcurrentRequests: Int = 3) {
        self.maxConcurrentRequests = maxConcurrentRequests
    }
}
