//
//  WatchStreamViewModelV2.swift
//  screen-streaming
//
//  Created by duc.vu1 on 6/4/25.
//

import VideoToolbox
import SwiftUI
import AVFoundation
import CoreMedia

class WatchStreamViewModelV2: ObservableObject {
    @Published var videoData: Data? // This will hold the received video bytes
    @Published var sampleBuffer: CMSampleBuffer?
    
    @ByInject var packetRepo: PacketRepository
    
    func startReceiveData() {
        packetRepo.subscribe { [weak self] data in
            DLog("🥲 ====> data:  \(data.count)")
            Task { @MainActor in
                self?.videoData = data
            }
        }
    }
}


// SwiftUI wrapper for macOS
struct VideoDisplayRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: WatchStreamViewModelV2
    
    func makeUIView(context: Context) -> DisplayView {
        let view = DisplayView()
        print("🆕 DisplayView created")
        return view
    }
    
    func updateUIView(_ uiView: DisplayView, context: Context) {
        print("🟢 updateUIView called. Data size: \(viewModel.videoData?.count ?? 0)")
        print("📐 View frame: \(uiView.frame)")
        print("🔍 View window: \(String(describing: uiView.window))")
        print("👀 View is hidden: \(uiView.isHidden)")
        print("🎯 View alpha: \(uiView.alpha)")
        
        if let data = viewModel.videoData {
            uiView.displayFrame(from: data)
        }
    }
}

class DisplayView: UIView {
    private var displayLayer: AVSampleBufferDisplayLayer
    private var lastPresentationTime: CMTime = .zero
    
    init() {
        displayLayer = AVSampleBufferDisplayLayer()
        displayLayer.videoGravity = .resizeAspectFill
        displayLayer.backgroundColor = UIColor.black.cgColor
        displayLayer.frame = CGRect(x: 0, y: 0, width: 300, height: 500) // Set initial frame
        
        super.init(frame: .zero)
        
        // Set up layer-hosting
        layer.addSublayer(displayLayer)
        backgroundColor = .black
        
        // Make sure we're on top
        layer.zPosition = 1000
        
        // Add debug border
        layer.borderWidth = 2
        layer.borderColor = UIColor.red.cgColor
        
        // Force layout
        setNeedsLayout()
        layoutIfNeeded()
        
        print("🏗️ DisplayView initialized with frame: \(frame)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("🔄 LayoutSubviews called")
        displayLayer.frame = bounds
        print("📏 Layer frame updated: \(bounds)")
        print("🎯 Layer is ready: \(displayLayer.isReadyForMoreMediaData)")
        print("🔍 Layer error: \(String(describing: displayLayer.error))")
        print("👁️ Layer is visible: \(!isHidden)")
        print("🎨 Layer opacity: \(layer.opacity)")
    }
    
    func displayFrame(from data: Data) {
        print("🎥 Processing frame of size: \(data.count) bytes")
        
        guard let image = UIImage(data: data),
              let cgImage = image.cgImage else {
            print("❌ Failed to create image from data")
            return
        }
        
        print("🖼️ Image created: \(cgImage.width)x\(cgImage.height)")
        
        let pixelBuffer = createPixelBuffer(from: cgImage)
        guard let pixelBuffer = pixelBuffer else { return }
        
        // Calculate next presentation time
        let frameDuration = CMTime(value: 1, timescale: 30)
        lastPresentationTime = lastPresentationTime + frameDuration
        
        var timing = CMSampleTimingInfo(
            duration: frameDuration,
            presentationTimeStamp: lastPresentationTime,
            decodeTimeStamp: .invalid
        )
        
        var formatDesc: CMVideoFormatDescription?
        let status = CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDesc
        )
        
        guard status == noErr, let formatDesc = formatDesc else {
            print("❌ Failed to create format description")
            return
        }
        
        var sampleBuffer: CMSampleBuffer?
        let sampleBufferStatus = CMSampleBufferCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: formatDesc,
            sampleTiming: &timing,
            sampleBufferOut: &sampleBuffer
        )
        
        guard sampleBufferStatus == noErr, let sampleBuffer = sampleBuffer else {
            print("❌ Failed to create sample buffer")
            return
        }
        
        print("📺 Layer ready for media: \(displayLayer.isReadyForMoreMediaData)")
        print("⏱️ Enqueueing frame at time: \(lastPresentationTime.seconds)")
        
        if displayLayer.isReadyForMoreMediaData {
            displayLayer.enqueue(sampleBuffer)
            print("✅ Frame enqueued successfully")
            
            // Force display update
            displayLayer.setNeedsDisplay()
            setNeedsDisplay()
        } else {
            print("⚠️ Layer is not ready for more media data")
        }
    }
    
    private func createPixelBuffer(from cgImage: CGImage) -> CVPixelBuffer? {
        let width = cgImage.width
        let height = cgImage.height
        
        // Create pixel buffer attributes
        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
            kCVPixelBufferMetalCompatibilityKey: true,
            kCVPixelBufferIOSurfacePropertiesKey: [:]
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let pixelBuffer = pixelBuffer else {
            print("❌ Failed to create pixel buffer with status: \(status)")
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        
        guard let context = CGContext(
            data: pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ) else {
            print("❌ Failed to create CGContext")
            return nil
        }
        
        // Clear the context
        context.clear(CGRect(x: 0, y: 0, width: width, height: height))
        
        // Draw the image
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Force a flush
        context.flush()
        
        return pixelBuffer
    }
}
