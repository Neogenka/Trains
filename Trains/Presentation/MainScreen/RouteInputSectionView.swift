//
//  RouteInputSectionView.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import SwiftUI

struct StationLite: Hashable, Identifiable, Sendable {
    var id = UUID()
    let title: String
    let code: String
}

struct RouteInputSectionView: View {
    
    private enum Constants {
        enum Padding {
            static let horizontal: CGFloat = 16.0
            static let vertical: CGFloat = 16.0
            static let leading: CGFloat = 20.0
        }
        enum Size {
            static let viewHeight: CGFloat = 128.0
            static let button: CGFloat = 36.0
            static let searchButtonWidth: CGFloat = 150.0
            static let searchButtonHeight: CGFloat = 60.0
        }
        enum Spacing {
            static let view: CGFloat = 12.0
            static let field: CGFloat = 8.0
        }
        enum FontSize {
            static let label: CGFloat = 17.0
            static let labelButton: CGFloat = 17
        }
        enum Colors {
            static let textField: Color = .ypGray
            static let squarepathButton: Color = .ypWhiteUniversal
            static let cardBackground: Color = .ypWhiteUniversal
            static let searchButtonBackground: Color = .ypBlue
        }
        enum CornerRadius {
            static let view: Double = 20.0
            static let searchButton: CGFloat = 16.0
        }
        enum Animation {
            static let duration: Double = 0.2
            static let swapSpringResponse: Double = 0.25
            static let swapSpringDamping: Double = 0.9
        }
        enum Placeholder {
            static let from = "Откуда"
            static let to   = "Куда"
        }
        enum Titles {
            static let searchButton = "Найти"
        }
        enum Images {
            enum System {
                static let squarePathButton = "arrow.2.squarepath"
            }
        }
    }
    
    @State private var from: StationLite?
    @State private var to: StationLite?
    
    @State private var isShowingFromSearch = false
    @State private var isShowingToSearch = false
    @EnvironmentObject private var app: AppState
    private let cityService: CityServiceProtocol
    
    let actionButton: () -> Void
    let actionSearchButton: (_ from: StationLite, _ to: StationLite) -> Void
    
    private var hasBothInputs: Bool {
        from != nil && to != nil
    }
    
    init(
        cityService: CityServiceProtocol,
        actionButton: @escaping () -> Void,
        actionSearchButton: @escaping (_ from: StationLite, _ to: StationLite) -> Void
    ) {
        self.cityService = cityService
        self.actionButton = actionButton
        self.actionSearchButton = actionSearchButton
    }
    
    var body: some View {
        VStack(spacing: Constants.Spacing.view) {
            ZStack {
                Color.ypBlue.cornerRadius(Constants.CornerRadius.view)
                HStack {
                    searchCityField
                    squarePathButton
                }
                .padding(.horizontal, Constants.Padding.horizontal)
                .padding(.vertical, Constants.Padding.vertical)
            }
            .frame(height: Constants.Size.viewHeight)
            .padding(.horizontal, Constants.Padding.horizontal)
            
            searchButton
                .opacity(hasBothInputs ? 1 : 0)
                .scaleEffect(hasBothInputs ? 1 : 0.98)
                .disabled(!hasBothInputs)
                .allowsHitTesting(hasBothInputs)
                .animation(.easeInOut(duration: Constants.Animation.duration), value: hasBothInputs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 184)
        .animation(.easeInOut(duration: Constants.Animation.duration), value: hasBothInputs)
        .fullScreenCover(isPresented: $isShowingFromSearch) {
            CitySearchView(
                cityService: cityService,
                onSelect: { city in
                    from = city
                    isShowingFromSearch = false
                },
                app: app
            )
        }
        .fullScreenCover(isPresented: $isShowingToSearch) {
            CitySearchView(
                cityService: cityService,
                onSelect: { city in
                    to = city
                    isShowingToSearch = false
                },
                app: app
            )
        }
    }
    
    private var searchCityField: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: Constants.Spacing.field) {
                    Button { isShowingFromSearch = true } label: {
                        HStack {
                            Text(from?.title ?? Constants.Placeholder.from)
                                .foregroundColor(from == nil ? Constants.Colors.textField : .ypBlackUniversal)
                                .font(.system(size: Constants.FontSize.label, weight: .regular))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Spacer().frame(height: 14)
                    
                    Button { isShowingToSearch = true } label: {
                        HStack {
                            Text(to?.title ?? Constants.Placeholder.to)
                                .foregroundColor(to == nil ? Constants.Colors.textField : .ypBlackUniversal)
                                .font(.system(size: Constants.FontSize.label, weight: .regular))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, Constants.Padding.vertical)
                .padding(.horizontal, Constants.Padding.leading)
                .background(Color.ypWhiteUniversal)
                .cornerRadius(Constants.CornerRadius.view)
                .frame(height: 96)
            }
        }
    }
    
    private var squarePathButton: some View {
        let isDisabled = (from == nil && to == nil)
        
        return Button {
            withAnimation(.spring(response: Constants.Animation.swapSpringResponse,
                                  dampingFraction: Constants.Animation.swapSpringDamping)) {
                swap(&from, &to)
            }
            actionButton()
        } label: {
            Image(systemName: Constants.Images.System.squarePathButton)
                .foregroundColor(.ypBlue)
                .frame(width: Constants.Size.button, height: Constants.Size.button)
        }
        .background(Constants.Colors.squarepathButton)
        .clipShape(Circle())
        .disabled(isDisabled)
    }
    
    private var searchButton: some View {
        Button {
            if let from, let to {
                actionSearchButton(from, to)
            }
        }label:{
            Text(Constants.Titles.searchButton)
                .font(.system(size: Constants.FontSize.labelButton, weight: .bold))
                .foregroundColor(Constants.Colors.cardBackground)
                .frame(width: Constants.Size.searchButtonWidth, height: Constants.Size.searchButtonHeight)
                .background(Constants.Colors.searchButtonBackground)
                .cornerRadius(Constants.CornerRadius.searchButton)
        }
        .buttonStyle(.plain)
        .disabled(!hasBothInputs)
    }
}

#Preview {
    RouteInputSectionView(cityService: MockCityService(),
                          actionButton: {},
                          actionSearchButton: {from,to in })
}
