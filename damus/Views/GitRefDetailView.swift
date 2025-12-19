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
    }

    private func findCommit() {
        repo.open()
        
        if !repo.exists() {
            self.commitMessage = "Repository not found locally. Please clone it first."
            return
        }

        repo.updateCommitGraph()
        
        if let commit = repo.commitGraph.commits.first(where: { $0.id.description == commitHash }) {
            self.commitMessage = commit.message
        } else {
            self.commitMessage = "Commit not found locally. Fetching from remote..."
            let allRemotes = repo.getRemotes()
            if let remoteOrigin = allRemotes.first {
                repo.fetch(remoteOrigin)
                // After fetch, we'd ideally refresh. For now, the user needs to re-open.
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.repo.updateCommitGraph()
                    if let commit = self.repo.commitGraph.commits.first(where: { $0.id.description == self.commitHash }) {
                        self.commitMessage = commit.message
                    } else {
                        self.commitMessage = "Commit not found after fetching."
                    }
                }
            } else {
                self.commitMessage = "Commit not found and no remote to fetch from."
            }
        }
    }
}
