import SwiftUI
import AVFoundation

struct CameraPermissionBadView: View {
    @State private var isAuthorized = false
    @State private var scannedCode: String?
    @State private var showCamera = false

    var body: some View {
        VStack {
            if showCamera {
                BarcodeScannerBadView(scannedCode: $scannedCode)
            } else {
                Text(scannedCode ?? (isAuthorized ? "Camera ready!" : "Camera permission required."))
                    .font(.headline)
                    .padding()

                Button(action: {
                    Task {
                        let authorized = await checkCameraAuthorization()
                        isAuthorized = authorized
                        if authorized {
                            showCamera = true
                        }
                    }
                }) {
                    Text(isAuthorized ? "Open Camera" : "Request Permission")
                        .padding()
                        .foregroundColor(.white)
                        .background(isAuthorized ? Color.green : Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                isAuthorized = await checkCameraAuthorization()
            }
        }
    }

    private func checkCameraAuthorization() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        if status == .authorized {
            return true
        } else if status == .notDetermined {
            return await AVCaptureDevice.requestAccess(for: .video)
        } else {
            return false
        }
    }
}

struct BarcodeScannerBadView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    @Binding var scannedCode: String?

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let controller = BarcodeScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
        // No updates needed
    }

//    func makeCoordinator() -> Coordinator {
////        Coordinator(self)
//    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: BarcodeScannerBadView

        init(_ parent: BarcodeScannerBadView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let scannedValue = metadataObject.stringValue {
                DispatchQueue.main.async {
                    self.parent.scannedCode = scannedValue
                }
            }
        }
    }
}

class BarcodeScannerViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var delegate: AVCaptureMetadataOutputObjectsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()

        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Failed to access camera.")
            return
        }

        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        } else {
            print("Failed to add video input.")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession?.canAddOutput(metadataOutput) == true {
            captureSession?.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .code128] // Add other barcode types as needed
        } else {
            print("Failed to add metadata output.")
            return
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession?.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
}
