//
//  VoiceCloneView.swift
//  sheng
//
//  Created by Tim on 8/6/25.
//

import SwiftUI
import AVFoundation

struct VoiceCloneView: View {
    @State private var voiceName: String = ""
    @State private var audioRecorder = AudioRecorderManager()
    @State private var showingPermissionAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("声音克隆")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("请输入声音名称", text: $voiceName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // 录音状态和时间显示
            if audioRecorder.isRecording {
                Text("正在录音: \(audioRecorder.formatTime(audioRecorder.recordingTime))")
                    .foregroundColor(.red)
                    .font(.headline)
            } else if audioRecorder.recordedAudioURL != nil {
                Text("录音完成: \(audioRecorder.formatTime(audioRecorder.recordingTime))")
                    .foregroundColor(.green)
                    .font(.headline)
            }
            
            HStack(spacing: 30) {
                // 录音按钮
                Button(action: {
                    if !audioRecorder.hasPermission {
                        // 请求麦克风权限
                        audioRecorder.checkPermission()
                        // 如果权限仍然被拒绝，显示提示
                        if !audioRecorder.hasPermission {
                            showingPermissionAlert = true
                        }
                        return
                    }
                    
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                    } else {
                        audioRecorder.startRecording()
                    }
                }) {
                    VStack {
                        Image(systemName: audioRecorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(audioRecorder.isRecording ? .red : .blue)
                        Text(audioRecorder.isRecording ? "停止录音" : "开始录音")
                    }
                }
                
                // 克隆按钮
                Button(action: {
                    print("开始克隆")
                    // 这里将添加克隆逻辑
                }) {
                    VStack {
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.purple)
                        Text("开始克隆")
                    }
                }
                .disabled(audioRecorder.recordedAudioData == nil || voiceName.isEmpty)
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .alert("需要麦克风权限", isPresented: $showingPermissionAlert) {
            Button("去设置", role: .none) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("请在设置中允许此应用使用麦克风，以便进行声音录制。")
        }
    }
}

#Preview {
    VoiceCloneView()
}