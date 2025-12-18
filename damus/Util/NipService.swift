//
//  NipService.swift
//  damus
//
//  Created by William Casarin on 2022-05-04.
//

import Foundation
import MiniGit

class NipService {
    let repo_url = "https://github.com/nostr-protocol/nips.git"
    let repo_name = "nips"
    
    let documentURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    lazy var localRepoLocation = documentURL.appendingPathComponent(repo_name)
    lazy var repository = GitRepository(localRepoLocation, credentialManager)
    
    func setup() {
        if repository.exists() {
            fetch()
        } else {
            clone()
        }
    }
    
    func clone() {
        print("Cloning NIPs repository from \(repo_url)")
        repository.clone(repo_url)
    }
    
    func fetch() {
        let allRemotes = repository.getRemotes()
        if let remoteOrigin = allRemotes.first {
            print("Fetching NIPs repository from \(remoteOrigin.url ?? "unknown remote")")
            repository.fetch(remoteOrigin)
        }
    }
}
