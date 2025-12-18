//
//  damusApp.swift
//  damus
//
//  Created by William Casarin on 2022-04-01.
//

import SwiftUI

@main
struct damusApp: App {
    let nipService = NipService()
    let gnostrService = GnostrService()
    let timer = Timer.publish(every: 3600, on: .main, in: .common).autoconnect() // Fetch every hour
    @StateObject var webViewURL = WebViewURL()

    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                ZStack {
                    MainView()
                        .environmentObject(webViewURL)
                        .onAppear {
                            nipService.setup()
                            gnostrService.setup()
                        }
                        .onReceive(timer) { _ in
                            nipService.fetch()
                            gnostrService.fetch()
                        }

                    if let url = webViewURL.url {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                webViewURL.url = nil
                            }
                        
                        WebView(url: url)
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 20)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                }
            }
        }
    }
}

struct MainView: View {
    @State var needs_setup = false;
    @State var keypair: Keypair? = nil;
    
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
    
