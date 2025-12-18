//
//  WebView.swift
//  damus
//
//  Created by William Casarin on 2022-05-04.
//

import SwiftUI
import WebKit
import Combine

extension URL: Identifiable {
    public var id: String {
        self.absoluteString
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    @ObservedObject var viewModel: WebViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }


    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        viewModel.webView = webView
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // The initial load is handled in makeUIView
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var viewModel: WebViewModel
        var webView: WKWebView?

        init(_ parent: WebView, viewModel: WebViewModel) {
            self.parent = parent
            self.viewModel = viewModel
            super.init()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.webView = webView
            self.viewModel.canGoBack = webView.canGoBack
            self.viewModel.canGoForward = webView.canGoForward
        }
    }
}

class WebViewModel: ObservableObject {
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var repo_url: String? = nil
    @Published var repo_name: String? = nil
    @Published var commitsToFetch: [String] = []
    
    var webView: WKWebView?
    var onCloneTapped: ((String, String, [String]) -> Void)?

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func refresh() {
        webView?.reload()
    }
    
    func clone() {
        if let url = repo_url, let name = repo_name {
            onCloneTapped?(url, name, commitsToFetch)
        }
    }
}
