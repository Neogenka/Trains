//
//  CarrierInfoVIew.swift
//  Trains
//
//  Created by МAK on 09.03.2026.
//

import SwiftUI

struct CarrierInfoView: View {
    @StateObject private var viewModel: CarrierInfoViewModel
    @Environment(\.dismiss) private var dismiss
    
    private let logoAssetName: String?
    
    init(code: String, service: CarrierServiceProtocol, logoAssetName: String? = nil) {
        _viewModel = StateObject(wrappedValue: CarrierInfoViewModel(code: code, service: service))
        self.logoAssetName = logoAssetName
    }
    
    private enum Constants {
        enum Size {
            static let logoCardHeight: CGFloat = 104
            static let logoCorner: CGFloat = 24
        }
        enum Spacing {
            static let vstack: CGFloat = 16
            static let contentPadding: CGFloat = 16
            static let fieldSpacing: CGFloat = 4
        }
        enum FontSize {
            static let title: CGFloat = 22
            static let fieldTitle: CGFloat = 13
        }
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            content
        }
        .navigationTitle("Информация о перевозчике")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.ypBlack)
                }
            }
        }
        .onAppear { viewModel.load() }
        .tint(.ypBlue)
    }
    
    @ViewBuilder private var content: some View {
        switch viewModel.state {
            case .idle, .loading:
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .failed:
                EmptyView()
                
            case .loaded(let resp):
                ScrollView {
                    VStack(alignment: .leading, spacing: Constants.Spacing.vstack) {
                        makeLogoCard(urlString: resp.carrier?.logo)
                        
                        Text(resp.carrier?.title ?? "Перевозчик")
                            .font(.system(size: Constants.FontSize.title, weight: .bold))
                            .foregroundColor(.ypBlack)
                        
                        makeField(title: "E-mail") {
                            if let email = nonEmpty(resp.carrier?.email),
                               let url = URL(string: "mailto:\(email)") {
                                Link(email, destination: url)
                            } else if let email = nonEmpty(resp.carrier?.email) {
                                Text(email)
                            } else {
                                Text("—").foregroundStyle(.secondary)
                            }
                        }
                        
                        makeField(title: "Телефон") {
                            if let phone = nonEmpty(resp.carrier?.phone) {
                                let raw = phone
                                let digitsOnly = digits(raw)
                                if let url = URL(string: "tel:\(digitsOnly)"),
                                   !digitsOnly.isEmpty {
                                    Link(raw, destination: url)
                                } else {
                                    Text(raw)
                                }
                            } else {
                                Text("—").foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(Constants.Spacing.contentPadding)
                }
                .background(Color(.systemBackground))
        }
    }
    
    private func makeLogoCard(urlString: String?) -> some View {
        RoundedRectangle(cornerRadius: Constants.Size.logoCorner, style: .continuous)
            .fill(Color.ypWhiteUniversal)
            .frame(height: Constants.Size.logoCardHeight)
            .overlay {
                if let asset = logoAssetName, UIImage(named: asset) != nil {
                    Image(asset)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 80)
                        .padding(.horizontal, 24)
                } else if let s = nonEmpty(urlString), let url = URL(string: s) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxHeight: 80)
                    .padding(.horizontal, 24)
                } else {
                    Image(systemName: "building.2")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 80)
                        .foregroundColor(.ypGray)
                        .padding(.horizontal, 24)
                }
            }
    }
    
    private func makeField<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.fieldSpacing) {
            Text(title)
                .font(.regular17)
                .foregroundColor(.ypBlack)
            content()
                .font(.regular12)
                .foregroundColor(.ypBlue)
        }
    }
    
    private func nonEmpty(_ s: String?) -> String? {
        guard let s = s?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else { return nil }
        return s
    }
    
    private func digits(_ s: String) -> String { s.filter { $0.isNumber || $0 == "+" } }
}
