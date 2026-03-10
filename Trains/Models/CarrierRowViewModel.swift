//
//  CarrierRowViewModel.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import SwiftUI

// MARK: - ViewModel
struct CarrierRowViewModel: Identifiable, Hashable, Sendable{
    
    enum BrandIconResolver {
        static func assetName(for carrierName: String, code: String) -> String? {
            let n = carrierName.lowercased()
            
            if code == "680" || n.contains("ржд") || n.contains("фпк") {
                return "rzd"
            }
            
            return nil
        }
    }
    
    let id = UUID()
    let carrierName: String
    let logoSystemName: String?
    let logoURL: URL?
    let dateText: String
    let departTime: String
    let arriveTime: String
    let durationText: String
    let note: String?
    let carrierCode: String
    let hasTransfers: Bool
    
    var forcedAsset: String? {
        BrandIconResolver.assetName(for: carrierName, code: carrierCode)
    }
    var finalLogoURL: URL? {
        forcedAsset == nil ? logoURL : nil
    }
    var finalLogoSystemName: String? {
        forcedAsset ?? Self.getSystemIconName(for: carrierName)
    }
    
    var departureHour: Int? {
        let comps = departTime.split(separator: ":")
        guard comps.count == 2, let hour = Int(comps[0]) else { return nil }
        return hour
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(
        carrierName: String,
        logoSystemName: String?,
        logoURL: URL? = nil,
        dateText: String,
        departTime: String,
        arriveTime: String,
        durationText: String,
        note: String?,
        carrierCode: String,
        hasTransfers: Bool
    ) {
        self.carrierName = carrierName
        self.logoSystemName = logoSystemName
        self.logoURL = logoURL
        self.dateText = dateText
        self.departTime = departTime
        self.arriveTime = arriveTime
        self.durationText = durationText
        self.note = note
        self.carrierCode = carrierCode
        self.hasTransfers = hasTransfers
    }
    
    static func getSystemIconName(for carrierName: String) -> String? {
        let lowercasedName = carrierName.lowercased()
        
        if lowercasedName.contains("жд") || lowercasedName.contains("ржд") || lowercasedName.contains("железнодорож") {
            return "tram"
        }
        
        return "questionmark"
    }
    
    static func formatDates(departure: String, arrival: String) -> (date: String, departTime: String, arriveTime: String) {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        guard let departureDate = isoFormatter.date(from: departure),
              let arrivalDate = isoFormatter.date(from: arrival) else {
            return ("--", "--:--", "--:--")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let dateText = dateFormatter.string(from: departureDate)
        let departTime = timeFormatter.string(from: departureDate)
        let arriveTime = timeFormatter.string(from: arrivalDate)
        
        return (dateText, departTime, arriveTime)
    }
    
    static func formatDuration(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)ч \(minutes)м"
        } else if hours > 0 {
            return "\(hours)ч"
        } else {
            return "\(minutes)м"
        }
    }
    
    static func calculateDuration(departure: String, arrival: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        guard let departureDate = isoFormatter.date(from: departure),
              let arrivalDate = isoFormatter.date(from: arrival) else {
            return ""
        }
        
        let interval = arrivalDate.timeIntervalSince(departureDate)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)ч \(minutes)м"
        } else if hours > 0 {
            return "\(hours)ч"
        } else {
            return "\(minutes)м"
        }
    }
    
    init?(from segment: Components.Schemas.Segment, carrierService: CarrierServiceProtocol? = nil) async {
        guard let thread = segment.thread else {
            return nil
        }
        
        let carrierName = thread.carrier?.title ?? "Неизвестный перевозчик"
        let carrierCode = thread.carrier?.code?.description ?? thread.number ?? "unknown"
        
        guard let departureString = segment.departure,
              let arrivalString = segment.arrival else {
            return nil
        }
        
        let (dateText, departTime, arriveTime) = Self.formatDates(
            departure: departureString,
            arrival: arrivalString
        )
        
        let durationText: String
        if let durationSeconds = segment.duration {
            durationText = Self.formatDuration(seconds: Int(durationSeconds))
        } else {
            durationText = Self.calculateDuration(
                departure: departureString,
                arrival: arrivalString
            )
        }
        
        let note: String?
        if segment.has_transfers == true {
            note = thread.transport_type
        } else {
            note = nil
        }
        
        let logoURL: URL? = await {
            if let carrierService = carrierService, let code = thread.carrier?.code?.description {
                do {
                    let carrierInfo = try await carrierService.getCarrierInfo(code: code)
                    if let logoString = carrierInfo.carrier?.logo, !logoString.isEmpty, let url = URL(string: logoString) {
                        return url
                    }
                    if let logoSvgString = carrierInfo.carrier?.logo_svg, !logoSvgString.isEmpty, let url = URL(string: logoSvgString) {
                        return url
                    }
                } catch {
                    print("Ошибка получения информации о перевозчике \(code): \(error)")
                }
            }
            return nil
        }()
        
        let logoSystemName = logoURL == nil ? Self.getSystemIconName(for: carrierName) : nil
        
        self.init(
            carrierName: carrierName,
            logoSystemName: logoSystemName,
            logoURL: logoURL,
            dateText: dateText,
            departTime: departTime,
            arriveTime: arriveTime,
            durationText: durationText,
            note: note,
            carrierCode: carrierCode,
            hasTransfers: segment.has_transfers ?? false
        )
    }
    
}

extension CarrierRowViewModel {
    static let mock: [CarrierRowViewModel] = [
        .init(carrierName: "РЖД", logoSystemName: "rzd",
              dateText: "14 января", departTime: "22:30", arriveTime: "08:15",
              durationText: "20 часов", note: "С пересадкой в Костроме", carrierCode: "680", hasTransfers: true),
        .init(carrierName: "ФГК", logoSystemName: "fgk",
              dateText: "15 января", departTime: "01:15", arriveTime: "09:00",
              durationText: "9 часов", note: nil, carrierCode: "681", hasTransfers: false),
        .init(carrierName: "Урал логистика", logoSystemName: "ural",
              dateText: "15 января", departTime: "12:30", arriveTime: "21:00",
              durationText: "9 часов", note: nil, carrierCode: "682", hasTransfers: false),
        .init(carrierName: "РЖД", logoSystemName: "rzd",
              dateText: "17 января", departTime: "22:30", arriveTime: "08:15",
              durationText: "20 часов", note: "С пересадкой в Костроме", carrierCode: "680", hasTransfers: true),
        .init(carrierName: "РЖД", logoSystemName: "rzd",
              dateText: "17 января", departTime: "22:30", arriveTime: "08:15",
              durationText: "20 часов", note: "С пересадкой в Костроме", carrierCode: "680", hasTransfers: true),
        .init(carrierName: "Урал логистика", logoSystemName: "ural",
              dateText: "17 января", departTime: "12:30", arriveTime: "21:00",
              durationText: "9 часов", note: nil, carrierCode: "682", hasTransfers: false)
    ]
}

#Preview("CarrierTableRow • Dark", traits: .sizeThatFitsLayout) {
    CarrierTableRow(
        viewModel: CarrierRowViewModel(
            carrierName: "РЖД",
            logoSystemName: "rzd",
            dateText: "14 января",
            departTime: "10:00",
            arriveTime: "14:30",
            durationText: "4 ч 30 мин",
            note: "С пересадкой в Костроме",
            carrierCode: "680",
            hasTransfers: true
        )
    )
    .padding(16)
    .background(Color.black)
    .environment(\.colorScheme, .dark)
}
