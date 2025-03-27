//
//  HomeScreen.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import SwiftUI

struct HomeScreen: View {
    private let recorder = StreamRecoder.shared
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Ip Address")
                Text(viewModel.ipAddress)
                    .font(.largeTitle)
                HStack {
                    Button("Start Streaming") {
                        viewModel.startStreaming()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Stop Streaming") {
                        viewModel.stopStreaming()
                        
                        recorder.stopRecording(completion: { _ in })
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Start sharing screen") {
                        recorder.startRecording { data in
                            viewModel.sendToServer(data: data)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                
                Spacer()
                
                TextField("Enter server address", text: $viewModel.serverAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                VStack {
                    Button("Connect") {
                        viewModel.connectToServer()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    NavigationLink("Open Stream view", destination: WatchStreamView())
                    Button("Echo test") {
                        viewModel.echo()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                NavigationLink("Open List", destination: ListScreen())
            }
            .navigationTitle("Home")
            .onAppear {
                viewModel.loadIpAddress()
            }
        }
    }
}
