//
//  GnostrService.swift
//  damus
//
//  Created by William Casarin on 2022-05-04.
//

import Foundation
import MiniGit

class GnostrService {
    let repo_url = "https://github.com/gnostr-org/gnostr.git"
    let repo_name = "gnostr"
    
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
        print("Cloning gnostr repository from \(repo_url)")
        repository.clone(repo_url)
    }
    
    func fetch() {
        let allRemotes = repository.getRemotes()
        if let remoteOrigin = allRemotes.first {
            print("Fetching gnostr repository from \(remoteOrigin.url ?? "unknown remote")")
            repository.fetch(remoteOrigin)
        }
    }
}
