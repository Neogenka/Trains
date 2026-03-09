//
//  CarrierService.swift
//  Trains
//
//  Created by МAK on 17.01.2026.
//

import OpenAPIRuntime
import Foundation

typealias CarrierResponse = Components.Schemas.CarrierResponse

protocol CarrierServiceProtocol {
    func getCarrierInfo(code: String) async throws -> CarrierResponse
}

final class CarrierService: CarrierServiceProtocol {
    
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getCarrierInfo(code: String) async throws -> CarrierResponse {
        let response = try await client.getCarrierInfo(query: .init(apikey: apikey, code: code))
        return try response.ok.body.json
    }
    
    func debugCarrierStructure(_ response: CarrierResponse) {
        dump(response)
    }
}

extension Components.Schemas.CarrierResponse {
    static var mock: Components.Schemas.CarrierResponse {
        return Components.Schemas.CarrierResponse(
            carrier: .init(
                code: 680,
                contacts: "",
                url: "http://www.turkishairlines.com/",
                title: "Turkish Airlines",
                phone: "444 08 49",
                address: "Bakırköy/ İstanbul",
                logo: "https://yastat.net/s3/rasp/media/data/company/logo/thy_kopya.jpg",
                email: "",
                codes: .init(
                    icao: "THY",
                    sirena: nil,
                    iata: "TK"
                )
            )
        )
    }
}
