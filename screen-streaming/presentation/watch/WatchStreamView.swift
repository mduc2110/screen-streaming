//
//  WatchStreamView.swift
//  screen-streaming
//
//  Created by duc.vu1 on 6/4/25.
//

import SwiftUI

struct WatchStreamView: View {
    @StateObject private var viewModel = WatchStreamViewModel()
    
    var body: some View {
        ZStack {
            Color.gray // Background
                .edgesIgnoringSafeArea(.all)
            
            VideoDisplayRepresentable(viewModel: viewModel)
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            viewModel.startReceiveData()
        }
    }
}
