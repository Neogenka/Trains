//
//  ContentView.swift
//  Trains
//
//  Created by МAK on 17.01.2026.
//

import SwiftUI
import OpenAPIURLSession

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
                TestAPI.testFetchStations()
                TestAPI.testFetchCarrier()
                TestAPI.testFetchCopyright()
                TestAPI.testFetchNearestSettlement()
                TestAPI.testFetchSearch()
                TestAPI.testFetchStationSchedule()
                TestAPI.testFetchStationsList()
                TestAPI.testFetchThread()
        }
    }
}

enum TestAPI {
    static let apiKey = "057faf93-e4ac-414c-94fe-2a73190ce827"
    static var client: Client {
        get throws {
            Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
        }
    }
    
    static func testFetchStations() {
        Task {
            do {
                let service = NearestStationsService(
                    client: try client,
                    apikey: apiKey
                )

                print("Fetching stations...")
                let stations = try await service.getNearestStations(
                    lat: 59.864177,
                    lng: 30.319163,
                    distance: 50
                )
                print("Successfully fetched stations: \(stations)")
            } catch {
                print("Error fetching stations: \(error)")
            }
        }
    }
    
    static func testFetchCarrier(){
        Task {
            do {
                let service = CarrierService(
                    client: try client,
                    apikey: apiKey
                )

                print("Fetching carriers...")
                let carriers = try await service.getCarrierInfo(code: "680")
                
                print("Successfully fetched carriers: \(carriers)")
            } catch {
                print("Error fetching carriers: \(error)")
            }
        }
    }
    
    static func testFetchCopyright(){
        Task {
            do {
                let service = CopyrightService(
                    client: try client,
                    apikey: apiKey
                )
                print("Fetching copyright...")
                let copyright = try await service.getCopyright()
                print("Successfully fetched copyright: \(copyright)")
            } catch {
                print("Error fetching copyright: \(error)")
            }
        }
    }
    
    static func testFetchNearestSettlement(){
        Task {
            do {
                let service = NearestSettlementService(
                    client: try client,
                    apikey: apiKey
                )
                print("Fetching nearestSettlement...")
                let nearestSettlement = try await service.getNearestCity(lat: 59.864177, lng: 30.319163)
                print("Successfully fetched nearestSettlement: \(nearestSettlement)")
            } catch {
                print("Error fetching nearestSettlement: \(error)")
            }
        }
    }
    
    static func testFetchStationSchedule(){
        Task {
            do {
                let service = ScheduleService(
                    client: try client,
                    apikey: apiKey
                )
                
                print("Fetching stationSchedule...")
                let stationSchedule = try await service.getStationSchedule(station: "s9600213")
                print("Successfully fetched stationSchedule: \(stationSchedule)")
            } catch {
                print("Error fetching stationSchedule: \(error)")
            }
        }
    }
    
    static func testFetchSearch(){
        Task {
            do {
                let service = SearchService(
                    client: try client,
                    apikey: apiKey
                )
                
                print("Fetching search...")
                let search = try await service.getScheduleBetweenStations(from: "c146", to: "c213")
                print("Successfully fetched search: \(search)")
            } catch {
                print("Error fetching search: \(error)")
            }
        }
    }
    
    static func testFetchStationsList(){
        Task {
            do {
                let service = StationsListService(
                    client: try client,
                    apikey: apiKey
                )
                
                print("Fetching stationsList...")
                let stationsList = try await service.getAllStations()
                print("Successfully fetched stationsList: \(stationsList)")
            } catch {
                print("Error fetching stationsList: \(error)")
            }
        }
    }
    
    static func testFetchThread(){
        Task {
            do {
                let service = ThreadService(
                    client: try client,
                    apikey: apiKey
                )
                
                print("Fetching thread...")
                let thread = try await service.getRouteStations(uid: "098S_3_2") /// находим UID через SearchService
                print("Successfully fetched thread: \(thread)")
            } catch {
                print("Error fetching thread: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
