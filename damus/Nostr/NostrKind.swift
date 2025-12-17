//
//  NostrKind.swift
//  damus
//
//  Created by William Casarin on 2022-04-27.
//

import Foundation

enum NostrKind: Int {
    case metadata = 0
    case text = 1
    case contacts = 3
    case dm = 4
    case delete = 5
    case boost = 6
    case like = 7
    case channel_create = 40
    case channel_meta = 41
    case chat = 42
    case repository_announcement = 30617
    case repository_state_announcement = 30618
    case repository_reply = 1111
    case repository_patch = 1617
    case repository_issue_open = 1630
    case repository_issue_applied = 1631
    case repository_issue_closed = 1632
    case repository_issue_draft = 1633
}
