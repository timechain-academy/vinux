//
//  SearchResultsView.swift
//  damus
//
//  Created by William Casarin on 2022-06-06.
//

import SwiftUI

enum Search {
    case profiles([(String, Profile)])
    case hashtag(String)
    case profile(String)
    case note(String)
    case hex(String)
    case d_tag(String)
    case name(String)
}

struct SearchResultsView: View {
    let damus_state: DamusState
    @Binding var search: String
    @State var result: Search? = nil
    
    func ProfileSearchResult(pk: String, res: Profile) -> some View {
        FollowUserView(target: .pubkey(pk), damus_state: damus_state)
    }
    
    
    @ViewBuilder
    func view(for search: Search) -> some View {
        switch search {
        case .profiles(let results):
            profileResults(results)
        case .hashtag(let ht):
            hashtagResult(ht)
        case .profile(let prof):
            profileResult(prof)
        case .hex(let h):
            hexResult(h)
        case .note(let nid):
            noteResult(nid)
        case .d_tag(let d_tag):
            dTagResult(d_tag)
        case .name(let name):
            nameResult(name)
        }
    }

    var MainContent: some View {
        ScrollView {
            if let result = result {
                view(for: result)
            } else {
                Text("none")
            }
        }
    }

    func profileResults(_ results: [(String, Profile)]) -> some View {
        LazyVStack {
            ForEach(results, id: \.0) { prof in
                ProfileSearchResult(pk: prof.0, res: prof.1)
            }
        }
    }

    func hashtagResult(_ ht: String) -> some View {
        let search_model = SearchModel(pool: damus_state.pool, search: .filter_hashtag([ht]))
        let dst = SearchView(appstate: damus_state, search: search_model)
        return NavigationLink(destination: dst) {
            Text("Search hashtag: #\(ht)")
        }
    }

    func profileResult(_ prof: String) -> some View {
        let decoded = try? bech32_decode(prof)
        let hex = hex_encode(decoded!.data)
        let prof_model = ProfileModel(pubkey: hex, damus: damus_state)
        let f = FollowersModel(damus_state: damus_state, target: prof)
        let dst = ProfileView(damus_state: damus_state, profile: prof_model, followers: f)
        return NavigationLink(destination: dst) {
            Text("Goto profile \(prof)")
        }
    }

    func hexResult(_ h: String) -> some View {
        let prof_model = ProfileModel(pubkey: h, damus: damus_state)
        let f = FollowersModel(damus_state: damus_state, target: h)
        let prof_view = ProfileView(damus_state: damus_state, profile: prof_model, followers: f)
        let ev_view = BuildThreadV2View(
            damus: damus_state,
            event_id: h
        )

        return VStack(spacing: 50) {
            NavigationLink(destination: prof_view) {
                Text("Goto profile \(h)")
            }
            NavigationLink(destination: ev_view) {
                Text("Goto post \(h)")
            }
        }
    }

    func noteResult(_ nid: String) -> some View {
        let decoded = try? bech32_decode(nid)
        let hex = hex_encode(decoded!.data)
        let ev_view = BuildThreadV2View(
            damus: damus_state,
            event_id: hex
        )
        return NavigationLink(destination: ev_view) {
            Text("Goto post \(nid)")
        }
    }

    func dTagResult(_ d_tag: String) -> some View {
        var filter = NostrFilter()
        filter.kinds = [NostrKind.repository_announcement.rawValue]
        filter.tags = ["d": [d_tag]]
        let search_model = SearchModel(pool: damus_state.pool, search: filter)
        let dst = SearchView(appstate: damus_state, search: search_model)
        return NavigationLink(destination: dst) {
            Text("Search for repo with id: \(d_tag)")
        }
    }

    func nameResult(_ name: String) -> some View {
        var filter = NostrFilter()
        filter.kinds = [NostrKind.repository_announcement.rawValue]
        filter.tags = ["name": [name]]
        let search_model = SearchModel(pool: damus_state.pool, search: filter)
        let dst = SearchView(appstate: damus_state, search: search_model)
        return NavigationLink(destination: dst) {
            Text("Search for repo with name: \(name)")
        }
    }
    
    func search_changed(_ new: String) {

        guard new.count != 0 else {
            return
        }
        
        if new.starts(with: "name:") {
            let name = String(new.dropFirst(5))
            self.result = .name(name)
            return
        }
        
        if new.starts(with: "d:") {
            let d_tag = String(new.dropFirst(2))
            self.result = .d_tag(d_tag)
            return
        }
        
        if new.first! == "#" {
            let ht = String(new.dropFirst())
            self.result = .hashtag(ht)
            return
        }
        
        if let _ = hex_decode(new), new.count == 64 {
            self.result = .hex(new)
            return
        }
        
        if new.starts(with: "npub") {
            if let _ = try? bech32_decode(new) {
                self.result = .profile(new)
                return
            }
        }
        
        if new.starts(with: "note") {
            if let _ = try? bech32_decode(new) {
                self.result = .note(new)
                return
            }
        }
        
        let profs = damus_state.profiles.profiles.enumerated()
        let results: [(String, Profile)] = profs.reduce(into: []) { acc, els in
            let pk = els.element.key
            let prof = els.element.value.profile
            let lowname = prof.name.map { $0.lowercased() }
            let lowdisp = prof.display_name.map { $0.lowercased() }
            let ok = new.count == 1 ?
            ((lowname?.starts(with: new) ?? false) ||
             (lowdisp?.starts(with: new) ?? false)) : (pk.starts(with: new) || String(new.dropFirst()) == pk
                || lowname?.contains(new) ?? false
                || lowdisp?.contains(new) ?? false)
            if ok {
                acc.append((pk, prof))
            }
        }
            
        self.result = .profiles(results)
    }
    
    var body: some View {
        MainContent
            .frame(maxHeight: .infinity)
            .onAppear {
                search_changed(search)
            }
            .onChange(of: search) { new in
                search_changed(new)
            }
    }
}

/*
struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsView(damus_state: test_damus_state(), s)
    }
}
 */
