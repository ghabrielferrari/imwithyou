//
//  ExperienceViewModel.swift
//  ImWithYou
//
//  Created by Gabriel Ferrari on 21/01/26.
//

import Foundation
import Combine

final class ExperienceViewModel: ObservableObject {
    enum State: Int, CaseIterable {
        case a, b, c, d, e
    }

    @Published var state: State = .a
    @Published var isDebugEnabled: Bool = false

    func next() {
        let all = State.allCases
        guard let i = all.firstIndex(of: state) else { return }
        state = (i < all.count - 1) ? all[i + 1] : .e
    }

    func reset() {
        state = .a
    }

    func setState(_ newState: State) {
        state = newState
    }
}
