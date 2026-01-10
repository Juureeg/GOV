// QRCodeScannerView.swift
//  Make sure to create this new file in your project

import SwiftUI
import AVFoundation

// MARK: - QR Code Scanner View
struct QRCodeScannerView: View {
    @Binding var isPresented: Bool
    var onCodeFound: (String) -> Void

    var body: some View {
        ZStack {
            // The camera preview layer
            QRCodeCameraView(isPresented: $isPresented, onCodeFound: onCodeFound)

            VStack {
                // Top-aligned Cancel Button
                HStack {
                    Spacer() // Pushes the button to the right
                    Button(action: {
                        isPresented = false // Dismiss the view
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
                Spacer() // Pushes the button to the top
            }
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
    }
}


// MARK: - QR Code Camera View (UIViewControllerRepresentable)
// This is the core component that manages the AVFoundation camera session.
struct QRCodeCameraView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onCodeFound: (String) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let session = AVCaptureSession()
        
        // 1. Get the camera device
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get the camera device")
            return viewController
        }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Failed to create video input: \(error)")
            return viewController
        }

        // 2. Add input to the session
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            print("Cannot add video input to the session")
            return viewController
        }

        // 3. Add metadata output for QR code scanning
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr] // We only care about QR codes
        } else {
            print("Cannot add metadata output to the session")
            return viewController
        }

        // 4. Create the preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        // Start the session on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
        
        // Store the session in the coordinator
        context.coordinator.session = session
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRCodeCameraView
        var session: AVCaptureSession?

        init(_ parent: QRCodeCameraView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            // Check if we already found a code
            guard let metadataObject = metadataObjects.first else { return }
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // Stop the session to prevent multiple scans
            session?.stopRunning()
            
            // Pass the found code back to the parent view
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) // Vibrate on success
            parent.onCodeFound(stringValue)
            
            // Dismiss the scanner view
            parent.isPresented = false
        }
    }
}
