//
//  SettingsView.swift
//  Trains
//
//  Created by МAK on 18.02.2026.
//

import SwiftUI
import Combine
import Observation

struct SettingsView: View {
    
    @State private var model = SettingsViewModel()
    @State private var cancelLables = Set<AnyCancellable>()
    
    private enum Theme {
        static let onColor: Color   = .ypBlue
        static let offColor: Color  = .ypGray.opacity(0.3)
        static let thumbColor: Color = .white
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                List {
                    HStack {
                        Text("Темная тема")
                            .font(.regular17)
                            .foregroundColor(.ypBlack)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { model.isDarkThemeEnabled },
                            set: { model.toggleDarkTheme($0) }
                        ))
                        .labelsHidden()
                        .tint(Theme.onColor)
                    }
                    .listRowInsets(.init(top: 19, leading: 16, bottom: 19, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .padding(.top, 24)
                    
                    Button {
                        model.openAgreement()
                    } label: {
                        HStack {
                            Text("Пользовательское соглашение")
                                .font(.regular17)
                                .foregroundColor(.ypBlack)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .frame(width: 24.0, height: 24.0)
                                .foregroundColor(.ypBlack)
                        }
                    }
                    .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .environment(\.defaultMinListRowHeight, 60)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: Binding(
                get: { model.showUserAgreement },
                set: { model.showUserAgreement = $0 }
            )) {
                UserAgreementWebScreen()
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 6) {
                    Text("Приложение использует API «Яндекс.Расписания»")
                        .font(.regular12)
                        .foregroundColor(.ypBlack)
                        .multilineTextAlignment(.center)
                    Text("Версия 1.0 (beta)")
                        .font(.regular12)
                        .foregroundColor(.ypBlack)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .background(Color(.systemBackground))
            }
            .onAppear {
                model.themeDidChange
                    .receive(on: DispatchQueue.main)
                    .sink { _ in
                    }
                    .store(in: &cancelLables)
            }
        }
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SettingsView()
        .preferredColorScheme(.dark)
}
