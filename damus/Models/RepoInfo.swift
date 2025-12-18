//
//  RepoInfo.swift
//  damus
//
//  Created by William Casarin on 2022-05-04.
//

import Foundation

struct RepoInfo: Identifiable {
    let id = UUID()
    let url: String
    let name: String
    let commitsToFetch: [String]
}
