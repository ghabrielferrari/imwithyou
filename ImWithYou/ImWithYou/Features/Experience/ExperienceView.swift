//
//  ExperienceView.swift
//  ImWithYou
//
//  Created by Gabriel Ferrari on 21/01/26.
//

import SwiftUI

struct ExperienceView: View {
    @StateObject private var vm = ExperienceViewModel()
    @State private var showDebug = false

    var body: some View {
        VStack {
            Spacer()

            if vm.state == .a {
                Text("Don't cross alone…")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .foregroundStyle(.white.opacity(0.35))
            }

            Spacer()

            if !vm.isAutoFlowEnabled {
                Button("Continuar") {
                    vm.next()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background)
        .animation(.easeInOut(duration: 0.6), value: vm.state)
        .onAppear {
            vm.startAutoFlowIfNeeded()
        }
        .onDisappear {
            vm.stopAutoFlow()
        }
        .onChange(of: vm.isAutoFlowEnabled) {
            vm.startAutoFlowIfNeeded()
        }
        .sheet(isPresented: $showDebug) {
            DebugPanel(
                state: vm.state,
                onPickState: { vm.setState($0) },
                onReset: { vm.reset() },
                isDebugEnabled: $vm.isDebugEnabled,
                isAutoFlowEnabled: $vm.isAutoFlowEnabled
            )
        }
        .toolbar {
            if vm.isDebugEnabled {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Debug") {
                        showDebug = true
                    }
                }
            }
        }
        .onTapGesture(count: 3) {
            vm.isDebugEnabled.toggle()
        }
    }

    private var background: some View {
        RadialGradient(
            colors: gradientColors,
            center: .top,
            startRadius: 40,
            endRadius: 900
        )
        .ignoresSafeArea()
    }

    private var gradientColors: [Color] {
        switch vm.state {
        case .a: return [Color(.systemGray5), Color(.systemGray)]
        case .b: return [Color(.systemGray4), Color(.systemGray2)]
        case .c: return [Color(.systemGray3), Color(.systemGray4)]
        case .d: return [Color(.systemGray4), Color(.systemGray)]
        case .e: return [Color(.systemGray4), Color(.systemGray2)]
        }
    }
}

private struct DebugPanel: View {
    let state: ExperienceViewModel.State
    let onPickState: (ExperienceViewModel.State) -> Void
    let onReset: () -> Void
    @Binding var isDebugEnabled: Bool
    @Binding var isAutoFlowEnabled: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Estado atual") {
                    Text(label(for: state))
                }

                Section("Ir para") {
                    ForEach(ExperienceViewModel.State.allCases, id: \.self) { s in
                        Button(label(for: s)) {
                            onPickState(s)
                        }
                    }
                }

                Section("Fluxo") {
                    Toggle("Auto Flow", isOn: $isAutoFlowEnabled)
                }

                Section {
                    Button("Recomeçar") {
                        onReset()
                    }
                }

                Section {
                    Toggle("Debug ativo", isOn: $isDebugEnabled)
                }
            }
            .navigationTitle("Debug")
        }
    }

    private func label(for state: ExperienceViewModel.State) -> String {
        switch state {
        case .a: return "A — Presença"
        case .b: return "B — Travessia"
        case .c: return "C — Abrigo"
        case .d: return "D — Abrigo Firme"
        case .e: return "E — Abrigo Respirando"
        }
    }
}
