//
//  ContentView.swift
//  sheng
//
//  Created by Tim on 8/6/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首页")
                }
                .tag(0)
            
            VoiceCloneView()
                .tabItem {
                    Image(systemName: "waveform.circle.fill")
                    Text("声音克隆")
                }
                .tag(1)
            
            TTSView()
                .tabItem {
                    Image(systemName: "speaker.wave.3.fill")
                    Text("语音合成")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

struct MainView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // 应用标题
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("声音工坊")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("专业的声音克隆与语音合成工具")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // 功能卡片
                    VStack(spacing: 20) {
                        // 声音克隆卡片
                        Button(action: {
                            selectedTab = 1
                        }) {
                            FeatureCard(
                                icon: "waveform.circle.fill",
                                title: "声音克隆",
                                description: "录制10秒语音，创建专属声音模型",
                                color: .blue,
                                features: ["支持普通话、粤语、英语", "高质量声音复制", "快速训练生成"]
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // 语音合成卡片
                        Button(action: {
                            selectedTab = 2
                        }) {
                            FeatureCard(
                                icon: "speaker.wave.3.fill",
                                title: "语音合成",
                                description: "将文字转换为自然流畅的语音",
                                color: .green,
                                features: ["多种语音选择", "语速自由调节", "预设精彩故事"]
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    
                    // 特性介绍
                    VStack(spacing: 16) {
                        Text("核心特性")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            FeatureItem(icon: "mic.fill", title: "高质量录音", description: "专业级音频处理")
                            FeatureItem(icon: "brain.head.profile", title: "AI驱动", description: "先进的语音技术")
                            FeatureItem(icon: "globe", title: "多语言支持", description: "普通话、粤语、英语")
                            FeatureItem(icon: "speedometer", title: "快速生成", description: "秒级语音合成")
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .onChange(of: selectedTab) { newValue in
            // 这里可以添加切换逻辑，但由于我们在TabView中，实际切换由父视图处理
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let features: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(features, id: \.self) { feature in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(color)
                        
                        Text(feature)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}