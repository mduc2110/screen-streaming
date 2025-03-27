//
//  WatchStreamView.swift
//  StreamingExample
//
//  Created by duc.vu1 on 24/3/25.
//

import SwiftUI

struct WatchStreamView: View {
    @StateObject private var viewModel = VideoStreamViewModel()
    
    var body: some View {
        Text("WatchStreamView")
        VideoPlayerView(viewModel: viewModel)
            .frame(width: 300, height: 500)
            .background(Color.gray)
            .onAppear {
                viewModel.startReceiveData()
            }
    }
}
