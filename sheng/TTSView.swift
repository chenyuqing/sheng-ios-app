//
//  TTSView.swift
//  sheng
//
//  Created by Tim on 8/6/25.
//

import SwiftUI
import AVFoundation

struct TTSView: View {
    @State private var inputText = ""
    @State private var apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
    @State private var isValidatingKey = false
    @State private var isKeyValid = false
    @State private var hasCheckedKey = false
    @State private var isSynthesizing = false
    @State private var selectedVoice = "default_voice.pt"
    @State private var selectedLanguage = "zh-cn"
    @State private var speechSpeed = 1.0
    @State private var showSettings = false
    @State private var errorMessage: String? = nil
    
    // 音频播放器
    @State private var audioPlayer = AudioPlayerManager()
    
    // API 服务
    private var apiService: OpenVoiceAPIService {
        OpenVoiceAPIService(apiKey: apiKey)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // API 密钥验证状态
                if !apiKey.isEmpty && hasCheckedKey {
                    HStack {
                        Image(systemName: isKeyValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isKeyValid ? .green : .red)
                        Text(isKeyValid ? "API 密钥有效" : "API 密钥无效")
                            .font(.subheadline)
                            .foregroundColor(isKeyValid ? .green : .red)
                        
                        Spacer()
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Text("更改")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                } else if apiKey.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("请设置 API 密钥")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Text("设置")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 文本输入
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("输入文本")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    TextEditor(text: $inputText)
                        .frame(minHeight: 150)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                // 错误信息显示
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                // 合成按钮
                Button(action: {
                    Task {
                        await synthesizeSpeech()
                    }
                }) {
                    HStack {
                        if isSynthesizing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        }
                        
                        Text(isSynthesizing ? "合成中..." : "开始合成")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isKeyValid && !inputText.isEmpty && !isSynthesizing ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!isKeyValid || inputText.isEmpty || isSynthesizing)
                .padding(.horizontal)
                
                // 播放控制
                if audioPlayer.isAudioAvailable {
                    HStack(spacing: 20) {
                        Button(action: {
                            audioPlayer.togglePlayback()
                        }) {
                            Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        
                        if audioPlayer.isPlaying {
                            Text("正在播放...")
                                .foregroundColor(.blue)
                        } else {
                            Text("点击播放")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("文本转语音")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                APIKeySettingsView(apiKey: $apiKey, onSave: {
                    UserDefaults.standard.set(apiKey, forKey: "apiKey")
                    validateAPIKey()
                })
            }
            .onAppear {
                validateAPIKey()
            }
        }
    }
    
    // 验证 API 密钥
    private func validateAPIKey() {
        guard !apiKey.isEmpty else {
            hasCheckedKey = true
            isKeyValid = false
            return
        }
        
        isValidatingKey = true
        
        Task {
            let result = await apiService.validateAPIKey()
            
            DispatchQueue.main.async {
                isValidatingKey = false
                hasCheckedKey = true
                
                switch result {
                case .success(let isValid):
                    isKeyValid = isValid
                case .failure(let error):
                    isKeyValid = false
                    errorMessage = "验证失败: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // 合成语音
    private func synthesizeSpeech() async {
        guard isKeyValid, !inputText.isEmpty else { return }
        
        DispatchQueue.main.async {
            isSynthesizing = true
            errorMessage = nil
        }
        
        let result = await apiService.textToSpeech(
            text: inputText,
            voice: selectedVoice,
            language: selectedLanguage,
            speed: speechSpeed
        )
        
        DispatchQueue.main.async {
            isSynthesizing = false
            
            switch result {
            case .success(let audioData):
                audioPlayer.playAudio(from: audioData)
            case .failure(let error):
                errorMessage = "合成失败: \(error.localizedDescription)"
            }
        }
    }
}

// API 密钥设置视图
struct APIKeySettingsView: View {
    @Binding var apiKey: String
    @State private var tempApiKey: String = ""
    @Environment(\.dismiss) private var dismiss
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API 密钥设置")) {
                    TextField("输入 API 密钥", text: $tempApiKey)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section {
                    Button("保存") {
                        apiKey = tempApiKey
                        onSave()
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("设置")
            .navigationBarItems(trailing: Button("取消") {
                dismiss()
            })
            .onAppear {
                tempApiKey = apiKey
            }
        }
    }
}

#Preview {
    TTSView()
}