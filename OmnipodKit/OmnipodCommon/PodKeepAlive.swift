//
//  PodKeepAlive.swift
//  OmnipodKit
//
//  Created by Joe Moran on 7/21/26.
//  Copyright © 2026 Joe Moran. All rights reserved.
//

import Foundation

enum PodKeepAlive: Int, CaseIterable, Codable {
    case disabled
    case silentTune
    case rileyLink
    case whenOpen

    var title: String {
        switch self {
        case .disabled:
            return LocalizedString("Disabled", comment: "Title string for PodKeepAlive.disabled")
        case .silentTune:
            return LocalizedString("Silent Tune", comment: "Title string for PodKeepAlive.silentTune")
        case .rileyLink:
            return LocalizedString("RileyLink", comment: "Title string for PodKeepAlive.rileyLink")
        case .whenOpen:
            return LocalizedString("When Open", comment: "Title string for PodKeepAlive.whenOpen")
        }
    }

    // The displayed name for the UI -- maps the internal only "When Open" mode as "Disabled"
    var displayTitle: String {
        switch self {
        case .disabled, .silentTune, .rileyLink:
            return self.title
        case .whenOpen:
            return PodKeepAlive.disabled.title /// display this internal only mode as disabled in the UI
        }
    }

    var description: String {
        switch self {
        case .disabled:
            return LocalizedString("Pod keep alive disabled (nominal behavior).", comment: "Description for PodKeepAlive.disabled")
        case .silentTune:
            return LocalizedString("Pod keep alive enabled using a silent tune. If silent tune is interrupted by other apps, pod keep alive stops working. The silent tune consumes extra iPhone battery.", comment: "Description for PodKeepAlive.silentTune")
        case .rileyLink:
            return LocalizedString("Pod keep alive enabled using a selected RileyLink-compatible device in the pump view. This method uses less iPhone battery than the Silent Tune method.", comment: "Description for PodKeepAlive.rileyLink")
        case .whenOpen:
            return "" /// Should never be displayed, now for internal use only
        }
    }

    /// Modes that keep the pod connected even while the app is backgrounded / phone locked (silentTune via
    /// a background silent-tune, rileyLink via a BLE wake device). The connection layer holds the pod
    /// connected in these modes instead of applying connect-on-demand's idle/background disconnect.
    /// `.whenOpen` keeps alive only while foregrounded (already covered by the foreground keep-alive), and
    /// `.disabled` is nominal connect-on-demand — both are false here.
    var keepsPodConnectedInBackground: Bool {
        switch self {
        case .disabled:
            return false /// No additional pod status requests to keep pod connected
        case .silentTune:
            return true /// Always tries to stay connected by playing a silent tune in background
        case .rileyLink:
            return true /// Always tries to stay connected by using RileyLink BLE wakeups
        case .whenOpen:
            return false /// Only tries to keep pod connected when in foregrounded, but not in background
        }
    }

    /// Modes that use a timer based keep alive either in foreground or background.
    var usesTimerBasedKeepAlives: Bool {
        switch self {
        case .disabled:
            return false /// No additional pod status requests to keep pod connected
        case .silentTune:
            return true /// Uses timer based keep alives, both when in foreground and in background
        case .rileyLink:
            return false /// Uses BLE wakeups instead of timers
        case .whenOpen:
            return true /// Uses timer based keep alives, but only when in foreground
        }
    }
}
