//
//  RelatedPreferences.swift
//  IdeaBox
//
//  Created by Copilot on 10/28/25.
//

import Foundation

enum RelatedPreferences {
    private static let maxNKey = "related.maxN"
    private static let tauKey = "related.thresholdTau"

    static var maxN: Int {
        get { max(5, min(20, UserDefaults.standard.integer(forKey: maxNKey) == 0 ? 10 : UserDefaults.standard.integer(forKey: maxNKey))) }
        set { UserDefaults.standard.set(max(5, min(20, newValue)), forKey: maxNKey) }
    }

    static var tau: Float {
        get {
            let v = UserDefaults.standard.float(forKey: tauKey)
            return v == 0 ? 0.65 : max(0.4, min(0.9, v))
        }
        set {
            let clamped = max(0.4, min(0.9, newValue))
            UserDefaults.standard.set(clamped, forKey: tauKey)
        }
    }
}
