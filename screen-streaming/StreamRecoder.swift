//
//  StreamRecoder.swift
//  StreamingExample
//
//  Created by duc.vu1 on 23/3/25.
//

import ReplayKit

protocol StreamRecordReceiver {
    func onReceive(data: Data)
}

final class StreamRecoder {
    static let shared = StreamRecoder()
    
    private var receivers: [StreamRecordReceiver] = []
    
    private init() {}
    
    private let rpRecorder = RPScreenRecorder.shared()
    
    public func subsribe(_ receiver: StreamRecordReceiver) {
        receivers.append(receiver)
    }
    
    public func startRecording(completion: @escaping (Data) -> Void) {
        guard rpRecorder.isAvailable else { return }
        
        if rpRecorder.isRecording { return }
        
//        rpRecorder.startRecording { error in
//            if let error = error {
//                DLog("❌ Error starting recording: \(error.localizedDescription)")
//            } else {
//                DLog("✅ Recording started!")
//            }
//        }
        rpRecorder.startCapture { [weak self] buffer, bufferType, error in
            if let error = error {
                DLog("❌ Error starting recording: \(error.localizedDescription)")
            } else {
                
                guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else { return }
                
                self?.processAndSendFrame(pixelBuffer, completion: completion)
            }
        }
    }
    
    public func stopRecording(completion: @escaping (UIViewController) -> Void) {
        DLog("... Process to stop!")
        rpRecorder.stopRecording { preview, error in
            if let error = error {
                DLog("❌ Error stopping recording: \(error.localizedDescription)")
            } else {
                DLog("✅ Recording stopped!")
                if let preview = preview {
                    completion(preview)
//                    preview.previewControllerDelegate = self
//                    self.present(preview, animated: true)
                }
            }
        }
    }
    
    private func processAndSendFrame(_ pixelBuffer: CVPixelBuffer, completion: @escaping (Data) -> Void) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent),
              let imageData = UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.5) else {
            return
        }
        
        // Send frame size first (4 bytes)
        var frameSize = UInt32(imageData.count)
        let sizeData = Data(bytes: &frameSize, count: MemoryLayout<UInt32>.size)
        
//        completion(sizeData)
        completion(imageData)
    }
}
