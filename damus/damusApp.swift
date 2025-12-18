//
//  damusApp.swift
//  damus
//
//  Created by William Casarin on 2022-04-01.
//

import SwiftUI

struct RepoInfo: Identifiable {
    let id = UUID()
    let url: String
    let name: String
    let commitsToFetch: [String]
}

@main
struct damusApp: App {
    let nipService = NipService()
    let gnostrService = GnostrService()
    let timer = Timer.publish(every: 3600, on: .main, in: .common).autoconnect() // Fetch every hour
    @StateObject var webViewURL = WebViewURL()
    @StateObject var webViewModel = WebViewModel()
    @State private var repoToClone: RepoInfo?
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                ZStack {
                    MainView()
                        .environmentObject(webViewURL)
                        .environmentObject(webViewModel)
                        .onAppear {
                            nipService.setup()
                            gnostrService.setup()
                            webViewModel.onCloneTapped = { url, name, commits in
                                self.repoToClone = RepoInfo(url: url, name: name, commitsToFetch: commits)
                            }
                        }
                        .onReceive(timer) { _ in
                            nipService.fetch()
                            gnostrService.fetch()
                        }
                    
                    if let url = webViewURL.url {
                        VStack {
                            HStack {
                                Button(action: {
                                    webViewModel.goBack()
                                }) {
                                    Image(systemName: "chevron.left")
                                }
                                .disabled(!webViewModel.canGoBack)
                                
                                Button(action: {
                                    webViewModel.goForward()
                                }) {
                                    Image(systemName: "chevron.right")
                                }
                                .disabled(!webViewModel.canGoForward)
                                
                                Button(action: {
                                    webViewModel.refresh()
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                }
                                
                                Spacer()
                                
                                if webViewModel.repo_url != nil {
                                    Button(action: {
                                        webViewModel.clone()
                                    }) {
                                        Image(systemName: "arrow.down.circle")
                                    }
                                }
                                
                                Button(action: {
                                    webViewURL.url = nil
                                }) {
                                    Image(systemName: "xmark")
                                }
                            }
                            .padding()
                            
                            WebView(url: url, viewModel: webViewModel)
                        }
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 20)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                }
            }
            .sheet(item: $repoToClone) { repoInfo in
                GitView(repo_url: repoInfo.url, repo_name: repoInfo.name, commitsToFetch: repoInfo.commitsToFetch)
            }
        }
    }
    
    struct MainView: View {
        @State var needs_setup = false;
        @State var keypair: Keypair? = nil;
        @EnvironmentObject var webViewURL: WebViewURL
        
        var body: some View {
            Group {
                if let kp = keypair, !needs_setup {
                    ContentView(keypair: kp)
                } else {
                    SetupView()
                        .onReceive(handle_notify(.login)) { notif in
                            needs_setup = false
                            keypair = get_saved_keypair()
                        }
                }
            }
            .background(
                KeyPressView {
                    webViewURL.url = nil
                }
            )
            .onReceive(handle_notify(.logout)) { _ in
                try? clear_keypair()
                keypair = nil
            }
            .onAppear {
                keypair = get_saved_keypair()
            }
        }
    }
    
    func needs_setup() -> Keypair? {
        return get_saved_keypair()
    }
    
}
