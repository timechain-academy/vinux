import SwiftUI
import GnostrGit

struct GitRefDetailView: View {
    let repo_name: String
    let refName: String
    let commitHash: String
    
    @StateObject private var repo: GitRepository
    @State private var commitMessage: String = "Loading..."

    init(repo_name: String, refName: String, commitHash: String) {
        self.repo_name = repo_name
        self.refName = refName
        self.commitHash = commitHash
        
        let localRepoLocation = documentURL.appendingPathComponent(repo_name)
        self._repo = StateObject(wrappedValue: GitRepository(localRepoLocation, credentialManager))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(refName)
                .font(.title)
                .bold()
            
            Text(commitHash)
                .font(.body.monospaced())
                .foregroundColor(.gray)
            
            Divider()
            
            Text(commitMessage)
                .font(.body)
            
            Spacer()
        }
        .padding()
        .onAppear(perform: findCommit)
        .onChange(of: repo.remoteProgress.inProgress) { inProgress in
            if !inProgress {
                self.repo.updateCommitGraph()
                if let commit = self.repo.commitGraph.commits.first(where: { $0.id.description == self.commitHash }) {
                    self.commitMessage = commit.message
                } else {
                    self.commitMessage = "Commit not found after fetching."
                }
            }
        }
    }

    private func findCommit() {
        repo.open()
        
        if !repo.exists() {
            self.commitMessage = "Repository not found locally. Please clone it first."
            return
        }

        print("Updating commit graph...")
        repo.updateCommitGraph()
        print("Commit graph updated. Commits found: \(repo.commitGraph.commits.count)")
        
        if let commit = repo.commitGraph.commits.first(where: { $0.id.description == commitHash }) {
            print("Commit found: \(commit.id.description)")
            self.commitMessage = commit.message
        } else {
            print("Commit with hash \(commitHash) not found locally.")
            self.commitMessage = "Commit not found locally. Fetching from remote..."
            let allRemotes = repo.getRemotes()
            if let remoteOrigin = allRemotes.first {
                repo.fetch(remoteOrigin)
            } else {
                self.commitMessage = "Commit not found and no remote to fetch from."
            }
        }
    }
}
