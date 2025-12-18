//
//  WebView.swift
//  damus
//
//  Created by William Casarin on 2022-05-04.
//

import SwiftUI
import WebKit

extension URL: Identifiable {
    public var id: String {
        self.absoluteString
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
