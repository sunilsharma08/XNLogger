//
//  SwiftUIExampleView.swift
//  XNLoggerExample
//
//  Created by Sunil Sharma.
//  Copyright © 2024 Sunil Sharma. All rights reserved.
//

import SwiftUI
import XNLogger

struct SwiftUIExampleView: View {

    var dismiss: () -> Void

    @State private var showLogger = false
    @State private var logEvents: [String] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {

                // MARK: - Actions

                Group {
                    Button("Show Logger (Manual)") {
                        showLogger = true
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Make GET Request (async/await)") {
                        Task {
                            await makeAsyncRequest()
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Make POST Request") {
                        makePostRequest()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Divider()

                // MARK: - Live Log Events (AsyncStream)

                Text("Live Log Events (via AsyncStream)")
                    .font(.headline)

                if logEvents.isEmpty {
                    Text("No events yet. Make a request to see logs here.")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    List(logEvents.indices, id: \.self) { index in
                        Text(logEvents[index])
                            .font(.system(.caption, design: .monospaced))
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("SwiftUI Example")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showLogger) {
            XNLoggerView()
                .ignoresSafeArea()
        }
        .task {
            // Subscribe to log events using AsyncStream
            for await event in XNLogger.shared.logStream {
                let entry: String
                switch event {
                case .request(let logData):
                    let url = logData.urlRequest.url?.absoluteString ?? "unknown"
                    entry = "REQ: \(url)"
                case .response(let logData):
                    let url = logData.urlRequest.url?.absoluteString ?? "unknown"
                    let status: String
                    if let httpResp = logData.response as? HTTPURLResponse {
                        status = "\(httpResp.statusCode)"
                    } else {
                        status = "n/a"
                    }
                    entry = "RESP [\(status)]: \(url)"
                }
                logEvents.insert(entry, at: 0)
                // Keep list manageable
                if logEvents.count > 50 {
                    logEvents = Array(logEvents.prefix(50))
                }
            }
        }
    }

    // MARK: - Network Requests

    private func makeAsyncRequest() async {
        guard let url = URL(string: "https://httpbin.org/get") else { return }
        do {
            let (_, _) = try await URLSession.shared.data(from: url)
        } catch {
            print("Request failed: \(error)")
        }
    }

    private func makePostRequest() {
        guard let url = URL(string: "https://httpbin.org/post") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["message": "Hello from SwiftUI"]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("POST failed: \(error)")
            }
        }.resume()
    }
}
