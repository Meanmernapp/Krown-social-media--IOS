//
//  WebView.swift
//  Krown
//
//  Created by Ivan Kodrnja on 01.11.2021..
//  Copyright © 2021 KrownUnity. All rights reserved.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

    var url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
