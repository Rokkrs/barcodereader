import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Binding var isScanning: Bool

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: BarcodeScannerView
        
        init(parent: BarcodeScannerView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let scannedValue = metadataObject.stringValue else { return }
            
            // Update the scanned code
            DispatchQueue.main.async {
                self.parent.scannedCode = scannedValue
                self.parent.isScanning = false // Stop scanning
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let scannerVC = uiViewController as? ScannerViewController else { return }
        scannerVC.updateScanningStatus(isScanning)
    }
}

class ScannerViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate: BarcodeScannerView.Coordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }

        if (captureSession?.canAddInput(videoInput) == true) {
            captureSession?.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession?.canAddOutput(metadataOutput) == true) {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr, .code128]
        } else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession?.startRunning()
    }

    func updateScanningStatus(_ isScanning: Bool) {
        if isScanning {
            captureSession?.startRunning()
        } else {
            captureSession?.stopRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
}

struct ContentView: View {
    @State private var scannedCode: String?
    @State private var isScanning: Bool = true

    var body: some View {
        VStack {
            if let code = scannedCode {
                Text("Scanned Code: \(code)")
                    .font(.title)
                    .padding()
            } else {
                Text("Scan a barcode!")
                    .font(.headline)
                    .padding()
            }
            
            BarcodeScannerView(scannedCode: $scannedCode, isScanning: $isScanning)
                .frame(height: 400)
                .cornerRadius(10)
                .padding()

            Button(action: {
                isScanning.toggle()
            }) {
                Text(isScanning ? "Stop Scanning" : "Start Scanning")
                    .foregroundColor(.white)
                    .padding()
                    .background(isScanning ? Color.red : Color.green)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}


struct CameraPermissionView: View {
    @State private var isAuthorized = false
    @State private var showCamera = false

    var body: some View {
        VStack {
            if showCamera {
                Text("Camera is ready to use!")
                    .font(.title)
                    .padding()
            } else {
                Text(isAuthorized ? "Camera permission granted." : "Camera permission required.")
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
                    Text(isAuthorized ? "Continue" : "Request Permission")
                        .padding()
                        .foregroundColor(.white)
                        .background(isAuthorized ? Color.green : Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
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
