//
//  CarrierServiceMock.swift
//  Trains
//
//  Created by МAK on 09.03.2026.
//

#if DEBUG
import Foundation

struct CarrierServiceMock: CarrierServiceProtocol {
    var delay: UInt64 = 300_000_000 // 0.3 c
    
    func getCarrierInfo(code: String) async throws -> CarrierResponse {
        try await Task.sleep(nanoseconds: delay)
        return .mock
    }
}
#endif
