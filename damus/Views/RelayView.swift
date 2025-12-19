//
//  RelayView.swift
//  damus
//
//  Created by William Casarin on 2022-10-16.
//

import SwiftUI

struct RelayView: View {
    let state: DamusState
    let relay: String
    
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    @State var conn_color: Color = .gray
    @State private var isSelected: Bool = false
    @State private var relayInfo: RelayInformation? // This was removed by mistake

    func fetchRelayInfo() {
        guard let url = URL(string: relay) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/nostr+json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            if let decodedInfo = try? decoder.decode(RelayInformation.self, from: data) {
                DispatchQueue.main.async {
                    self.relayInfo = decodedInfo
                }
            }
        }.resume()
    }
    
    func update_connection_color() {
        for relay in state.pool.relays {
            if relay.id == self.relay {
                let c = relay.connection
                if c.isConnected {
                    conn_color = .green
                } else if c.isConnecting || c.isReconnecting {
                    conn_color = .yellow
                } else {
                    conn_color = .red
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .frame(width: 8.0, height: 8.0)
                    .foregroundColor(conn_color)
                Text(relayInfo?.name ?? relay)
                    .font(isSelected ? .title2 : .headline)
            }
            Text(relay) // Always display the URL
                .font(.caption)
                .foregroundColor(.gray)
            
            if isSelected {
                if let info = relayInfo {
                    if let description = info.description {
                        Text(description)
                            .font(.body) // Enlarge font
                    }
                    if let supportedNips = info.supportedNips {
                        Text("NIPs: \(supportedNips.map(String.init).joined(separator: ", "))")
                            .font(.subheadline) // Enlarge font
                            .foregroundColor(.gray)
                    }
                }
            } else {
                if let info = relayInfo {
                    if let description = info.description {
                        Text(description)
                            .font(.footnote)
                            .lineLimit(1) // Show only one line when not selected
                    }
                }
            }
        }
        .onTapGesture {
            withAnimation {
                self.isSelected.toggle()
            }
        }
        .onReceive(timer) { _ in
            update_connection_color()
        }
        .onAppear() {
            update_connection_color()
            fetchRelayInfo()
        }
        .swipeActions {
            if let privkey = state.keypair.privkey {
                RemoveAction(privkey: privkey)
            }
        }
        .contextMenu {
            CopyAction(relay: relay)
            
            if let privkey = state.keypair.privkey {
                RemoveAction(privkey: privkey)
            }
        }
    }
    
    func CopyAction(relay: String) -> some View {
        Button {
            UIPasteboard.general.setValue(relay, forPasteboardType: "public.plain-text")
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }
    }
    
    func RemoveAction(privkey: String) -> some View {
        Button {
            guard let ev = state.contacts.event else {
                return
            }
            
            let descriptors = state.pool.descriptors
            guard let new_ev = remove_relay( ev: ev, current_relays: descriptors, privkey: privkey, relay: relay) else {
                return
            }
            
            process_contact_event(pool: state.pool, contacts: state.contacts, pubkey: state.pubkey, ev: new_ev)
            state.pool.send(.event(new_ev))
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
    }
}

struct RelayView_Previews: PreviewProvider {
    static var previews: some View {
        RelayView(state: test_damus_state(), relay: "wss://relay.damus.io", conn_color: .red)
    }
}
