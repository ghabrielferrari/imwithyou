//
//  ExperienceViewModel.swift
//  ImWithYou
//
//  Created by Gabriel Ferrari on 21/01/26.
//

import Foundation
import Combine

@MainActor
final class ExperienceViewModel: ObservableObject {

    enum State: Int, CaseIterable {
        case a, b, c, d, e
    }

    @Published var state: State = .a
    @Published var isDebugEnabled: Bool = false
    @Published var isAutoFlowEnabled: Bool = true

    private var flowTask: Task<Void, Never>?
    private let audio = AudioPlayer()

    func next() {
        let states = State.allCases
        guard let index = states.firstIndex(of: state) else { return }
        state = index < states.count - 1 ? states[index + 1] : .e
        updateAudio()
    }

    func reset() {
        stopAutoFlow()
        state = .a
        updateAudio()
        startAutoFlowIfNeeded()
    }

    func setState(_ newState: State) {
        state = newState
        updateAudio()
    }

    func startAutoFlowIfNeeded() {
        guard isAutoFlowEnabled, flowTask == nil else { return }

        flowTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                let delay: UInt64
                switch self.state {
                case .a: delay = 3_000_000_000
                case .b: delay = 2_500_000_000
                case .c: delay = 2_500_000_000
                case .d: delay = 2_000_000_000
                case .e: delay = 8_000_000_000   // tempo de “respirar” antes de reiniciar
                }

                try? await Task.sleep(nanoseconds: delay)
                if Task.isCancelled { break }

                if self.state == .e {
                    self.state = .a
                    self.updateAudio()
                    continue
                }

                self.next() // chama updateAudio()
            }

            self.flowTask = nil
        }
    }

    func stopAutoFlow() {
        flowTask?.cancel()
        flowTask = nil
    }

    private func updateAudio() {
        if state == .d || state == .e {
            audio.playLoop(fileName: "ambient", fileExtension: "wav", volume: 0.35)
        } else {
            audio.stop()
        }
    }

    deinit {
        flowTask?.cancel()
    }
}
