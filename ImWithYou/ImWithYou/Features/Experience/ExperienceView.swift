//
//  ExperienceView.swift
//  ImWithYou
//
//  Created by Gabriel Ferrari on 21/01/26.
//

import SwiftUI

struct ExperienceView: View {
    @StateObject private var vm = ExperienceViewModel()
    @State private var isDebugSheetPresented = false

    var body: some View {
        VStack {
            Spacer()

            if vm.state == .a {
                Text("Don't cross alone…")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .foregroundStyle(.white.opacity(0.35))
                    .transition(.opacity)
            }

            Spacer()

            // botao temporário apenas para MVP funcional
            Button("Continuar") { vm.next() }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 12)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background)
        .animation(.easeInOut(duration: 0.6), value: vm.state)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if vm.isDebugEnabled {
                    Button("Debug") { isDebugSheetPresented = true }
                }
            }
        }
        .sheet(isPresented: $isDebugSheetPresented) {
            DebugPanel(
                state: vm.state,
                onPickState: { vm.setState($0) },
                onReset: { vm.reset() },
                isDebugEnabled: $vm.isDebugEnabled
            )
            .presentationDetents([.medium])
        }
        .onTapGesture(count: 3) {
            // gesto discreto: triplo toque alterna debug (nao aparece para o usuario final)
            vm.isDebugEnabled.toggle()
        }
    }

    private var background: some View {
        RadialGradient(
            colors: GradientPalette.colors(for: vm.state),
            center: .top,
            startRadius: 40,
            endRadius: 900
        )
        .ignoresSafeArea()
    }
}

private struct DebugPanel: View {
    let state: ExperienceViewModel.State
    let onPickState: (ExperienceViewModel.State) -> Void
    let onReset: () -> Void
    @Binding var isDebugEnabled: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Estado atual") {
                    Text(String(describing: state).uppercased())
                }

                Section("Ir para") {
                    ForEach(ExperienceViewModel.State.allCases, id: \.self) { s in
                        Button(s.label) { onPickState(s) }
                    }
                }

                Section {
                    Button("Recomeçar") { onReset() }
                }

                Section {
                    Toggle("Debug ativo", isOn: $isDebugEnabled)
                }
            }
            .navigationTitle("Debug")
        }
    }
}

private extension ExperienceViewModel.State {
    var label: String {
        switch self {
        case .a: return "A — Presença"
        case .b: return "B — Travessia"
        case .c: return "C — Abrigo"
        case .d: return "D — Abrigo Firme"
        case .e: return "E — Abrigo Respirando"
        }
    }
}

private enum GradientPalette {
    static func colors(for state: ExperienceViewModel.State) -> [Color] {
        switch state {
        case .a: return [Color(.systemGray5), Color(.systemGray)]
        case .b: return [Color(.systemGray4), Color(.systemGray2)]
        case .c: return [Color(.systemGray3), Color(.systemGray4)]
        case .d: return [Color(.systemGray4), Color(.systemGray)]
        case .e: return [Color(.systemGray4), Color(.systemGray2)]
        }
    }
}
