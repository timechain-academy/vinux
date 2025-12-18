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

    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    nipService.setup()
                    gnostrService.setup()
                }
                .onReceive(timer) { _ in
                    nipService.fetch()
                    gnostrService.fetch()
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
    
