//
//  WatchStreamViewV2.swift
//  screen-streaming
//
//  Created by duc.vu1 on 6/4/25.
//

import SwiftUI

struct WatchStreamViewV2: View {
    @StateObject private var viewModel = WatchStreamViewModelV2()
    
    var body: some View {
        ZStack {
            Color.gray // Background
                .edgesIgnoringSafeArea(.all)
            
            VideoDisplayRepresentable(viewModel: viewModel)
                .frame(width: 300, height: 500)
                .background(Color.black)
                .border(Color.red, width: 2)
        }
        .onAppear {
            viewModel.startReceiveData()
        }
    }
}
