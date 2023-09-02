//
//  EditProfileView.swift
//  OnCall
//
//  Created by Andreas Ink on 8/26/23.
//

import SwiftUI
import SwiftData
import PhotosUI
import VisionKit

enum SelectedTextField {
    case Name
    case Description
    case Emoji
}

struct EditProfileView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @FocusState var selectedTextField: SelectedTextField?
    
    @Query var myInfo: [Person]
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImageData: Data?
    
    @State private var uploadError: Error? = nil
    @State private var showUploadError = false
    
    @State private var name = ""
  
    var body: some View {
        VStack(alignment: .leading) {
            PhotosPicker(
                selection: $selectedItems,
                matching: .images,
                photoLibrary: .shared()) {
                    if let selectedImageData {
                        Image(uiImage: UIImage(data: selectedImageData) ?? UIImage.add)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    } else {
                        VStack(alignment: .leading) {
                            Image(systemName: "photo")
                                .font(.largeTitle).bold()
                                .padding(.vertical)
                            Text((NSLocalizedString("Share a photo of yourself to share with your co caregiver or partner", comment: "")))
                                .font(.body)
                                .buttonStyle(.bordered)
                                .tint(.accentColor)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .buttonStyle(.bordered)
               
                .onChange(of: selectedItems) { oldItems, newItems in
                    Task {
                        for index in newItems.indices {
                            do {
                            if let itemData = try await selectedItems[index].loadTransferable(type: Data.self) {
                                
                                if let img = UIImage(data: itemData) {
                                    
                                    if let resizedImage = img.resized(to: CGSize(width: 350, height: 350)) {
                                        
                                        let person = await extractPerson(resizedImage)
                                        self.myInfo.first?.color = CodableColor.toCodable(color: img.getDominantColor() ?? .black)
                                        let view = ZStack {
                                            Color.clear
                                            Image(uiImage: person)
                                        }
                                       
                                        selectedImageData = ImageRenderer(content: view).uiImage?.pngData() ?? Data()
                                        self.myInfo.first?.imageData = selectedImageData

                                    }
                                   
                                }
                            }
                            } catch {
                                uploadError = error
                                showUploadError = true
                            }
                        }
                    }
                }
            
           
            TextField("Name (Andreas)", text: $name)
                .focused($selectedTextField, equals: .Name)
               
                .onSubmit {
                    //myInfo.description = myInfo.name + " "
                    selectedTextField = .Description
                }
                .onChange(of: selectedTextField) { oldValue, newValue in
                    if oldValue == .Name {
                       // myInfo.description = myInfo.name + " "
                    }
                }
            Button("Save") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .tint(.accentColor)
            
               
            Spacer()
        }
        .onAppear {
            if myInfo.isEmpty {
                modelContext.insert(Person())
            }
            selectedImageData = myInfo.first?.imageData
            name = myInfo.first?.name ?? ""
        }
        .padding()
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .alert(uploadError?.localizedDescription ?? "", isPresented: $showUploadError) {
            
        }
    }
    @MainActor
    func extractPerson(_ img: UIImage) async -> UIImage {
        let analyzer = ImageAnalyzer()
        let analysis = try? await analyzer.analyze(img, configuration: .init(.visualLookUp))
        let interaction = ImageAnalysisInteraction()
        interaction.analysis = analysis
        
        let subject = await interaction.subjects.first
        return (try? await subject?.image) ?? UIImage.add
    }
}
