//
//  NewPostView.swift
//  Codepath-HW2
//
//  Created by Jeffrey Berdeal on 9/18/25.
//

import SwiftUI
import PhotosUI
import Photos
import CoreLocation
import ParseSwift

struct NewPostView: View {
    @Environment(\.dismiss) private var dismiss
    var onPosted: () -> Void
    
    @State private var pickerTask: Task<Void, Never>?
    @State private var showCamera = false
    @State private var showLibrary = false
    @State private var selection: PhotosPickerItem?
    @State private var uiImage: UIImage?
    @State private var caption = ""
    @State private var isUploading = false
    @State private var errorMessage: String?
    
    // metadata
    @State private var asset: PHAsset?
    @State private var creationDate: Date?
    @State private var coordinate: CLLocationCoordinate2D?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                
                imagePreview
                cameraLibraryButtons
                
                TextField("Write a caption (optional)", text: $caption)
                    .textFieldStyle(.roundedBorder)
                
                Spacer()
            }
            .padding(16)
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isUploading {
                        ProgressView()
                    } else {
                        Button("Post") {
                            isUploading = true
                            Task { await upload() }
                        }
                        .disabled(uiImage == nil || isUploading)
                    }
                }
            }
            .onChange(of: selection) { newItem in
                pickerTask?.cancel()
                pickerTask = Task {
                    guard let item = newItem else { return }
                    
                    if let data = try? await item.loadTransferable(type: Data.self),
                       !Task.isCancelled,
                       let img = UIImage(data: data) {
                        await MainActor.run { uiImage = img }
                    }
                    
                    if let a = await fetchAsset(for: item), !Task.isCancelled {
                        await MainActor.run {
                            asset = a
                            creationDate = a.creationDate
                            coordinate = a.location?.coordinate
                        }
                    }
                }
            }
            .onDisappear {
                pickerTask?.cancel()
            }
            .sheet(isPresented: $showCamera) {
                SystemCameraPicker { img in
                    uiImage = img
                    OneShotLocation.shared.request { coord in
                        if let c = coord {
                            self.coordinate = c
                        }
                    }
                }
            }
            .alert("Upload Failed", isPresented: .constant(errorMessage != nil), actions: {
                Button("OK") { errorMessage = nil }
            }, message: { Text(errorMessage ?? "") })
        }
    }
    
    // MARK: - Upload
    private func upload() async {
        guard let image = uiImage,
              let data = image.jpegData(compressionQuality: 0.85) else { return }
        
        isUploading = true
        do {
            let file = ParseFile(name: "image.jpg", data: data)
            
            var post = Post()
            post.author = AppUser.current
            post.caption = caption.isEmpty ? nil : caption
            post.image = file
            if let c = coordinate {
                post.location = try ParseGeoPoint(latitude: c.latitude, longitude: c.longitude)
            }
            
            _ = try await file.save()
            _ = try await post.save()
            
            if var me = AppUser.current {
                me.lastPostedAt = Date()
                _ = try await me.save()
            }
            
            await MainActor.run {
                isUploading = false
                onPosted()
                dismiss()
            }
        } catch {
            await MainActor.run {
                isUploading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Helper
    private func fetchAsset(for item: PhotosPickerItem) async -> PHAsset? {
        guard let id = try? await item.loadTransferable(type: String.self) else { return nil }
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        return result.firstObject
    }
}

// MARK: - Camera Picker
struct SystemCameraPicker: UIViewControllerRepresentable {
    var onImage: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: SystemCameraPicker
        init(_ parent: SystemCameraPicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.onImage(img)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

private extension NewPostView {
    @ViewBuilder
    var imagePreview: some View {
        if let img = uiImage {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipped()
                .cornerRadius(12)
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Text("No photo selected")
                        .foregroundColor(.secondary)
                )
        }
    }
    
    var cameraLibraryButtons: some View {
        HStack(spacing: 12) {
            Button("Open Camera") { showCamera = true }
                .frame(maxWidth: .infinity, minHeight: 50)
                .buttonStyle(.borderedProminent)
            
            Button("Choose Photo") { showLibrary = true }
                .frame(maxWidth: .infinity, minHeight: 50)
                .buttonStyle(.borderedProminent)
                .photosPicker(isPresented: $showLibrary, selection: $selection, matching: .images)
        }
    }
}
