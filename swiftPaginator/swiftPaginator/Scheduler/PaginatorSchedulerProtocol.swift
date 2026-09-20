//
//  PaginatorSchedulerProtocol.swift
//  swiftPaginator
//
//  Created by Anton Chushialov on 20.09.2026.
//

public protocol PaginatorSchedulerProtocol: Sendable {
    func schedule<T: Sendable>(
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T
}
