//
//  ContentView.swift
//  Desafio13
//
//  Created by Turma01-7 on 11/05/26.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    
    @State private var classificationLabel = ""
    @State private var selectedImage = UIImage(named: "pato")
    
    let images = ["arara", "coruja", "estrela-do-mar", "gorgulho", "lagarto", "ovo-galinha", "pato"]
    
    var body: some View{
        ZStack{
            Color("fundo")
                .ignoresSafeArea()
            VStack() {
                
                Text("MobiliNet")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(Color.blue)
                
                Text("Classificador de Imagem")
                    .font(.title)
                    .bold()
                
                if let image = selectedImage {
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 10)
                                .padding(.horizontal, 20)
                        )
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(images, id: \.self) { imageName in
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                                .clipped()
                                .onTapGesture {
                                    
                                    selectedImage = UIImage(named: imageName)
                                    classificationLabel = ""
                                }
                        }
                    }
                    .padding(10)
                }
                List{
                    HStack{
                        Image(systemName: "text.page.badge.magnifyingglass")
                            .tint(.red)
                        Text("Resultado da Análise")
                            .bold()
                    }
                    if classificationLabel.isEmpty {
                        
                        Text("Pronto para analisar")
                            .bold()
                        
                    } else {
                        
                        Text("Identificado: \(classificationLabel)")
                            .bold()
                    }                }
                
                Spacer()
                
                HStack{
                    Button(action: {
                        classifyImage()
                    }) {
                        Image(systemName: "doc.viewfinder")
                        Text("Analisar Agora")
                    }
                    .padding()
                    .frame(width: 350)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
            }
        }
    }
    
    func classifyImage() {
        
        guard let uiImage = selectedImage,
              let ciImage = CIImage(image: uiImage) else {
            classificationLabel = "Erro ao converter imagem"
            return
        }
        
        do {
            
            let model = try VNCoreMLModel(
                for: MobileNetV2(configuration: MLModelConfiguration()).model
            )
            
            let request = VNCoreMLRequest(model: model) { request, error in
                
                if let results = request.results as? [VNClassificationObservation],
                   let topResult = results.first {
                    
                    DispatchQueue.main.async {
                        
                        classificationLabel = "\(topResult.identifier) (\(String(format: "%.2f", topResult.confidence * 100))%)"
                    }
                    
                } else {
                    
                    classificationLabel = "Nenhum resultado encontrado"
                }
            }
            
            let handler = VNImageRequestHandler(
                ciImage: ciImage,
                options: [:]
            )
            
            DispatchQueue.global().async {
                
                do {
                    
                    try handler.perform([request])
                    
                } catch {
                    
                    classificationLabel = """
                    Erro na classificação:
                    \(error.localizedDescription)
                    """
                }
            }
            
        } catch {
            
            classificationLabel = "Falha ao carregar modelo ML"
        }
    }
}


#Preview {
    ContentView()
}
