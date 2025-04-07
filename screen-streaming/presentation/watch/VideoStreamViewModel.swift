//
//  VideoStreamViewModel.swift
//  StreamingExample
//
//  Created by duc.vu1 on 23/3/25.
//

import VideoToolbox
import SwiftUI
import AVFoundation
import CoreMedia

//class VideoStreamViewModel: ObservableObject {
//    @Published var videoData: Data?
//    @Published var isPlaying = false
//    
//    // Video player view that can be used in SwiftUI
//    var videoPlayerView: some View {
//        VideoPlayerView(viewModel: self)
//    }
//    
//    // Update video data with new bytes
//    func updateBytes(_ data: Data) {
//        DispatchQueue.main.async {
//            self.videoData = data
//            self.objectWillChange.send()  // Explicitly notify observers of change
//        }
//    }
//    
//    // Simulate decoding and displaying video (for testing)
//    func decodeAndDisplay() {
//        // Create sample video data for testing
//        let sampleData = Data([0x00, 0x00, 0x00, 0x01, 0x67, 0x42, 0x00, 0x0A, 0xF8, 0x41, 0xA2])
//        updateBytes(sampleData)
//    }
//    
//    // Clear current video data
//    func clearVideoData() {
//        DispatchQueue.main.async {
//            self.videoData = nil
//            self.objectWillChange.send()
//        }
//    }
//}

//struct VideoPlayerView: UIViewRepresentable {
//    @ObservedObject var viewModel: VideoStreamViewModel
//    
//    func makeUIView(context: Context) -> VideoRenderView {
//        return VideoRenderView()
//    }
//    
//    func updateUIView(_ uiView: VideoRenderView, context: Context) {
//        if let buffer = viewModel.sampleBuffer {
//            uiView.updateBuffer(buffer)
//        }
////        if let data = viewModel.videoData {
////            uiView.processH264Data(data)
////        }
//    }
//}
//
//class VideoRenderView: UIView {
//    private let videoLayer = AVSampleBufferDisplayLayer()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupLayer()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupLayer()
//    }
//
//    private func setupLayer() {
//        videoLayer.videoGravity = .resizeAspect
//        videoLayer.frame = self.bounds
//        self.layer.addSublayer(videoLayer)
//    }
//    
//    func updateBuffer(_ buffer: CMSampleBuffer) {
//        videoLayer.enqueue(buffer)
//    }
//
//    func processH264Data(_ data: Data) {
//        guard let sampleBuffer = createSampleBuffer(from: data) else {
//            print("Failed to create sample buffer")
//            return
//        }
//        videoLayer.enqueue(sampleBuffer) // Render H.264 frame
//    }
//}
//
//private func createSampleBuffer(from data: Data) -> CMSampleBuffer? {
//    // 1️⃣ Create a CMBlockBuffer from raw data
//    var blockBuffer: CMBlockBuffer?
//    let status = CMBlockBufferCreateWithMemoryBlock(
//        allocator: kCFAllocatorDefault,
//        memoryBlock: nil, // Let the system allocate memory
//        blockLength: data.count,
//        blockAllocator: nil,
//        customBlockSource: nil,
//        offsetToData: 0,
//        dataLength: data.count,
//        flags: 0,
//        blockBufferOut: &blockBuffer
//    )
//    
//    guard status == kCMBlockBufferNoErr, let blockBuffer = blockBuffer else {
//        print("Failed to create CMBlockBuffer")
//        return nil
//    }
//    
//    // 2️⃣ Copy data into the CMBlockBuffer
//    let copyStatus = CMBlockBufferReplaceDataBytes(
//        with: (data as NSData).bytes,
//        blockBuffer: blockBuffer,
//        offsetIntoDestination: 0,
//        dataLength: data.count
//    )
//    
//    guard copyStatus == kCMBlockBufferNoErr else {
//        print("Failed to copy data into CMBlockBuffer")
//        return nil
//    }
//
//    // 3️⃣ Create CMVideoFormatDescription (assuming H.264)
//    var formatDescription: CMVideoFormatDescription?
//    let formatStatus = CMVideoFormatDescriptionCreate(
//        allocator: kCFAllocatorDefault,
//        codecType: kCMVideoCodecType_H264,
//        width: 1280,
//        height: 720,
//        extensions: nil,
//        formatDescriptionOut: &formatDescription
//    )
//    
//    guard formatStatus == noErr, let formatDescription = formatDescription else {
//        print("Failed to create CMVideoFormatDescription")
//        return nil
//    }
//
//    // 4️⃣ Define Sample Timing
//    var timingInfo = CMSampleTimingInfo(
//        duration: CMTime.invalid,
//        presentationTimeStamp: CMTime.zero,
//        decodeTimeStamp: CMTime.zero
//    )
//
//    // 5️⃣ Create CMSampleBuffer
//    var sampleBuffer: CMSampleBuffer?
//    let sampleBufferStatus = CMSampleBufferCreateReady(
//        allocator: kCFAllocatorDefault,
//        dataBuffer: blockBuffer,
//        formatDescription: formatDescription,
//        sampleCount: 1,
//        sampleTimingEntryCount: 1,
//        sampleTimingArray: &timingInfo,
//        sampleSizeEntryCount: 1,
//        sampleSizeArray: [data.count],
//        sampleBufferOut: &sampleBuffer
//    )
//    
//    guard sampleBufferStatus == noErr else {
//        print("Failed to create CMSampleBuffer")
//        return nil
//    }
//
//    return sampleBuffer
//}
//
//class VideoStreamViewModel: ObservableObject {
//    @Published var videoData: Data? // This will hold the received video bytes
//    @Published var sampleBuffer: CMSampleBuffer?
//    
//    private var decompressionSession: VTDecompressionSession?
//    private var formatDescription: CMVideoFormatDescription?
//    
//    @ByInject var receiverRepository: PacketRepository
//
//    func updateBytes(_ bytes: Data) {
//        DispatchQueue.main.async {
//            self.videoData = bytes
//        }
//    }
//    
//    func decodeAndDisplay() {
//        guard let bytes = videoData else { return }
//        var blockBuffer: CMBlockBuffer?
//        var sampleBuffer: CMSampleBuffer?
//
//        // Create CMBlockBuffer from raw bytes
//        CMBlockBufferCreateWithMemoryBlock(
//            allocator: nil,
//            memoryBlock: nil,
//            blockLength: bytes.count,
//            blockAllocator: nil,
//            customBlockSource: nil,
//            offsetToData: 0,
//            dataLength: bytes.count,
//            flags: 0,
//            blockBufferOut: &blockBuffer
//        )
//
//        guard let blockBuffer = blockBuffer else { return }
//
//        CMBlockBufferReplaceDataBytes(
//            with: (bytes as NSData).bytes,
//            blockBuffer: blockBuffer,
//            offsetIntoDestination: 0,
//            dataLength: bytes.count
//        )
//
//        // **🔹 Create Format Description If Missing**
//        if formatDescription == nil {
//            let width: Int32 = 1280 // Replace with actual width
//            let height: Int32 = 720  // Replace with actual height
//            
//            let parameters = [kCVPixelBufferWidthKey: width,
//                              kCVPixelBufferHeightKey: height] as CFDictionary
//
//            let status = CMVideoFormatDescriptionCreate(
//                allocator: kCFAllocatorDefault,
//                codecType: kCMVideoCodecType_H264, // Ensure correct codec
//                width: width,
//                height: height,
//                extensions: parameters,
//                formatDescriptionOut: &formatDescription
//            )
//
//            if status != noErr {
//                print("❌ Failed to create CMVideoFormatDescription")
//                return
//            }
//        }
//
//        var timingInfo = CMSampleTimingInfo(
//            duration: CMTime.invalid,
//            presentationTimeStamp: CMTime.invalid,
//            decodeTimeStamp: CMTime.invalid
//        )
//
//        // Create CMSampleBuffer
//        let status = CMSampleBufferCreateReady(
//            allocator: kCFAllocatorDefault,
//            dataBuffer: blockBuffer,
//            formatDescription: formatDescription,
//            sampleCount: 1,
//            sampleTimingEntryCount: 1,
//            sampleTimingArray: &timingInfo,
//            sampleSizeEntryCount: 0,
//            sampleSizeArray: nil,
//            sampleBufferOut: &sampleBuffer
//        )
//
//        if status != noErr || sampleBuffer == nil {
//            print("❌ Failed to create CMSampleBuffer")
//            return
//        }
//    }
//    
//    func startReceiveData() {
//        Task {
//            receiverRepository.subscribe { receivedData in
//                DLog("🥲 data: \(receivedData)")
//                Task { @MainActor [weak self] in
//                    self?.processRawData(receivedData)
//                    // self?.videoData = data
//                }
//            }
//        }
//    }
//    
//    private func processRawData(_ data: Data) {
//        let width = 1920 // Your video width
//        let height = 1080 // Your video height
//        
//        var format: CMFormatDescription?
//        let status = CMVideoFormatDescriptionCreate(
//            allocator: kCFAllocatorDefault,
//            codecType: kCVPixelFormatType_32BGRA,
//            width: Int32(width),
//            height: Int32(height),
//            extensions: nil,
//            formatDescriptionOut: &format
//        )
//        
//        guard status == noErr, let format = format else {
//            return
//        }
//        
//        // Create pixel buffer
//        var pixelBuffer: CVPixelBuffer?
//        CVPixelBufferCreate(
//            kCFAllocatorDefault,
//            width,
//            height,
//            kCVPixelFormatType_32BGRA,
//            nil,
//            &pixelBuffer
//        )
//        
//        guard let pixelBuffer = pixelBuffer else {
//            return
//        }
//        
//        // Copy data to pixel buffer
//        CVPixelBufferLockBaseAddress(pixelBuffer, [])
//        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
//        data.copyBytes(to: baseAddress!.assumingMemoryBound(to: UInt8.self), count: data.count)
//        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
//        
//        // Create sample buffer
//        var sampleBuffer: CMSampleBuffer?
//        var timing = CMSampleTimingInfo(
//            duration: CMTime(value: 1, timescale: 30),
//            presentationTimeStamp: CMTime(value: 0, timescale: 1),
//            decodeTimeStamp: CMTime.invalid
//        )
//        
//        CMSampleBufferCreateForImageBuffer(
//            allocator: kCFAllocatorDefault,
//            imageBuffer: pixelBuffer,
//            dataReady: true,
//            makeDataReadyCallback: nil,
//            refcon: nil,
//            formatDescription: format,
//            sampleTiming: &timing,
//            sampleBufferOut: &sampleBuffer
//        )
//        
//        if let buffer = sampleBuffer {
//            DispatchQueue.main.async { [weak self] in
//                self?.sampleBuffer = buffer
////                self?.previewLayer.enqueue(buffer)
//            }
//        }
//    }
//}

class VideoRenderView: UIView {
    private let videoLayer = AVSampleBufferDisplayLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }

    private func setupLayer() {
        videoLayer.videoGravity = .resizeAspect
        videoLayer.frame = self.bounds
        self.layer.addSublayer(videoLayer)
    }

    func updateBuffer(_ buffer: CMSampleBuffer) {
        videoLayer.enqueue(buffer)
    }

    func processH264Data(_ data: Data) {
        guard let sampleBuffer = createSampleBuffer(from: data) else {
            print("Failed to create sample buffer")
            return
        }
        videoLayer.enqueue(sampleBuffer) // Render H.264 frame
    }
}

// NSView-based video display
class VideoDisplayView: UIView {
    private let videoLayer = AVSampleBufferDisplayLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayer() {
        videoLayer.videoGravity = .resizeAspect
        videoLayer.frame = self.bounds
        self.layer.addSublayer(videoLayer)
    }

    func updateBuffer(_ buffer: CMSampleBuffer) {
        videoLayer.enqueue(buffer)
    }

    func processH264Data(_ data: Data) {
        guard let sampleBuffer = createSampleBuffer(from: data) else {
            print("Failed to create sample buffer")
            return
        }
        videoLayer.enqueue(sampleBuffer) // Render H.264 frame
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoLayer.frame = bounds
    }
    
    func displayFrame(from data: Data) {
        guard let image = UIImage(data: data),
              let cgImage = image.cgImage else {
            return
        }
        
        let pixelBuffer = createPixelBuffer(from: cgImage)
        guard let pixelBuffer = pixelBuffer else { return }
        
        var timing = CMSampleTimingInfo(
            duration: CMTime(value: 1, timescale: 30),
            presentationTimeStamp: CMTime(value: 0, timescale: 1),
            decodeTimeStamp: .invalid
        )
        
        var formatDesc: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDesc
        )
        
        guard let formatDesc = formatDesc else { return }
        
        var sampleBuffer: CMSampleBuffer?
        CMSampleBufferCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: formatDesc,
            sampleTiming: &timing,
            sampleBufferOut: &sampleBuffer
        )
        
        if let sampleBuffer = sampleBuffer {
            videoLayer.enqueue(sampleBuffer)
        }
    }
    
    private func createPixelBuffer(from cgImage: CGImage) -> CVPixelBuffer? {
        let width = cgImage.width
        let height = cgImage.height
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            nil,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let pixelBuffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
        
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        )
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return pixelBuffer
    }
}

struct VideoPlayerView: UIViewRepresentable {
    @ObservedObject var viewModel: VideoStreamViewModel

    func makeUIView(context: Context) -> VideoDisplayView {
        return VideoDisplayView()
    }

    func updateUIView(_ uiView: VideoDisplayView, context: Context) {
        if let data = viewModel.videoData {
            uiView.displayFrame(from: data)
        }
    }
}

private func createSampleBuffer(from data: Data) -> CMSampleBuffer? {
    // 1️⃣ Create a CMBlockBuffer from raw data
    var blockBuffer: CMBlockBuffer?
    let status = CMBlockBufferCreateWithMemoryBlock(
        allocator: kCFAllocatorDefault,
        memoryBlock: nil, // Let the system allocate memory
        blockLength: data.count,
        blockAllocator: nil,
        customBlockSource: nil,
        offsetToData: 0,
        dataLength: data.count,
        flags: 0,
        blockBufferOut: &blockBuffer
    )
    
    guard status == kCMBlockBufferNoErr, let blockBuffer = blockBuffer else {
        print("Failed to create CMBlockBuffer")
        return nil
    }
    
    // 2️⃣ Copy data into the CMBlockBuffer
    let copyStatus = CMBlockBufferReplaceDataBytes(
        with: (data as NSData).bytes,
        blockBuffer: blockBuffer,
        offsetIntoDestination: 0,
        dataLength: data.count
    )
    
    guard copyStatus == kCMBlockBufferNoErr else {
        print("Failed to copy data into CMBlockBuffer")
        return nil
    }

    // 3️⃣ Create CMVideoFormatDescription (assuming H.264)
    var formatDescription: CMVideoFormatDescription?
    let formatStatus = CMVideoFormatDescriptionCreate(
        allocator: kCFAllocatorDefault,
        codecType: kCMVideoCodecType_H264,
        width: 1280,
        height: 720,
        extensions: nil,
        formatDescriptionOut: &formatDescription
    )
    
    guard formatStatus == noErr, let formatDescription = formatDescription else {
        print("Failed to create CMVideoFormatDescription")
        return nil
    }

    // 4️⃣ Define Sample Timing
    var timingInfo = CMSampleTimingInfo(
        duration: CMTime.invalid,
        presentationTimeStamp: CMTime.zero,
        decodeTimeStamp: CMTime.zero
    )

    // 5️⃣ Create CMSampleBuffer
    var sampleBuffer: CMSampleBuffer?
    let sampleBufferStatus = CMSampleBufferCreateReady(
        allocator: kCFAllocatorDefault,
        dataBuffer: blockBuffer,
        formatDescription: formatDescription,
        sampleCount: 1,
        sampleTimingEntryCount: 1,
        sampleTimingArray: &timingInfo,
        sampleSizeEntryCount: 1,
        sampleSizeArray: [data.count],
        sampleBufferOut: &sampleBuffer
    )
    
    guard sampleBufferStatus == noErr else {
        print("Failed to create CMSampleBuffer")
        return nil
    }

    return sampleBuffer
}

class VideoStreamViewModel: ObservableObject {
    @Published var videoData: Data? // This will hold the received video bytes
    @Published var sampleBuffer: CMSampleBuffer?
    
    private var decompressionSession: VTDecompressionSession?
    private var formatDescription: CMVideoFormatDescription?
    
    @ByInject var streamReceiver: PacketRepository
    
    func decodeAndDisplay() {
        guard let bytes = videoData else { return }
        var blockBuffer: CMBlockBuffer?
        var sampleBuffer: CMSampleBuffer?

        // Create CMBlockBuffer from raw bytes
        CMBlockBufferCreateWithMemoryBlock(
            allocator: nil,
            memoryBlock: nil,
            blockLength: bytes.count,
            blockAllocator: nil,
            customBlockSource: nil,
            offsetToData: 0,
            dataLength: bytes.count,
            flags: 0,
            blockBufferOut: &blockBuffer
        )

        guard let blockBuffer = blockBuffer else { return }

        CMBlockBufferReplaceDataBytes(
            with: (bytes as NSData).bytes,
            blockBuffer: blockBuffer,
            offsetIntoDestination: 0,
            dataLength: bytes.count
        )

        // **🔹 Create Format Description If Missing**
        if formatDescription == nil {
            let width: Int32 = 1280 // Replace with actual width
            let height: Int32 = 720  // Replace with actual height
            
            let parameters = [kCVPixelBufferWidthKey: width,
                              kCVPixelBufferHeightKey: height] as CFDictionary

            let status = CMVideoFormatDescriptionCreate(
                allocator: kCFAllocatorDefault,
                codecType: kCMVideoCodecType_H264, // Ensure correct codec
                width: width,
                height: height,
                extensions: parameters,
                formatDescriptionOut: &formatDescription
            )

            if status != noErr {
                print("❌ Failed to create CMVideoFormatDescription")
                return
            }
        }

        var timingInfo = CMSampleTimingInfo(
            duration: CMTime.invalid,
            presentationTimeStamp: CMTime.invalid,
            decodeTimeStamp: CMTime.invalid
        )

        // Create CMSampleBuffer
        let status = CMSampleBufferCreateReady(
            allocator: kCFAllocatorDefault,
            dataBuffer: blockBuffer,
            formatDescription: formatDescription,
            sampleCount: 1,
            sampleTimingEntryCount: 1,
            sampleTimingArray: &timingInfo,
            sampleSizeEntryCount: 0,
            sampleSizeArray: nil,
            sampleBufferOut: &sampleBuffer
        )

        if status != noErr || sampleBuffer == nil {
            print("❌ Failed to create CMSampleBuffer")
            return
        }
    }
    
    func startReceiveData() {
        streamReceiver.subscribe { [weak self] data in
            DLog("🥲 ====> data:  \(data.count)")
            Task { @MainActor in
                self?.videoData = data
            }
        }
    }
    
    private func processRawData(_ data: Data) {
        let width = 1920 // Your video width
        let height = 1080 // Your video height
        
        var format: CMFormatDescription?
        let status = CMVideoFormatDescriptionCreate(
            allocator: kCFAllocatorDefault,
            codecType: kCVPixelFormatType_32BGRA,
            width: Int32(width),
            height: Int32(height),
            extensions: nil,
            formatDescriptionOut: &format
        )
        
        guard status == noErr, let format = format else {
            return
        }
        
        // Create pixel buffer
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            nil,
            &pixelBuffer
        )
        
        guard let pixelBuffer = pixelBuffer else {
            return
        }
        
        // Copy data to pixel buffer
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        data.copyBytes(to: baseAddress!.assumingMemoryBound(to: UInt8.self), count: data.count)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        
        // Create sample buffer
        var sampleBuffer: CMSampleBuffer?
        var timing = CMSampleTimingInfo(
            duration: CMTime(value: 1, timescale: 30),
            presentationTimeStamp: CMTime(value: 0, timescale: 1),
            decodeTimeStamp: CMTime.invalid
        )
        
        CMSampleBufferCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: format,
            sampleTiming: &timing,
            sampleBufferOut: &sampleBuffer
        )
        
        if let buffer = sampleBuffer {
            DispatchQueue.main.async { [weak self] in
                self?.sampleBuffer = buffer
//                self?.previewLayer.enqueue(buffer)
            }
        }
    }
}
