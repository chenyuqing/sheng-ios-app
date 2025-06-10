//
//  AudioRecorderManager.swift
//  sheng
//
//  Created by Tim on 8/6/25.
//

import Foundation
import AVFoundation
import SwiftUI
import Observation

@Observable
class AudioRecorderManager: NSObject {
    var isRecording = false
    var recordingTime: TimeInterval = 0
    var hasPermission = false
    var recordedAudioURL: URL? = nil
    var recordedAudioData: Data? = nil
    
    private var audioRecorder: AVAudioRecorder? = nil
    private var timer: Timer? = nil
    private var audioSession: AVAudioSession? = nil
    
    override init() {
        super.init()
        checkPermission()
    }
    
    func checkPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPermission = granted
            }
        }
    }
    
    func startRecording() {
        // 停止任何正在进行的录制
        stopRecording()
        
        // 重置录制状态
        resetRecording()
        
        // 配置音频会话
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession?.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession?.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("无法设置音频会话: \(error.localizedDescription)")
            return
        }
        
        // 创建临时文件URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        
        // 配置录音设置
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        // 创建录音机
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            
            if audioRecorder?.record() == true {
                isRecording = true
                recordingTime = 0
                
                // 启动计时器更新录制时间
                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                    guard let self = self else { return }
                    self.recordingTime += 0.1
                }
            } else {
                print("录音启动失败")
            }
        } catch {
            print("无法创建录音机: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        // 停止录音
        if isRecording {
            audioRecorder?.stop()
            isRecording = false
            timer?.invalidate()
            timer = nil
            
            // 保存录音文件并转换为Data
            if let url = audioRecorder?.url {
                recordedAudioURL = url
                do {
                    recordedAudioData = try Data(contentsOf: url)
                    print("录音已保存: \(url.path)")
                } catch {
                    print("无法读取录音数据: \(error.localizedDescription)")
                }
            }
        }
        
        // 停用音频会话
        do {
            try audioSession?.setActive(false)
        } catch {
            print("无法停用音频会话: \(error.localizedDescription)")
        }
    }
    
    func resetRecording() {
        recordingTime = 0
        recordedAudioURL = nil
        recordedAudioData = nil
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorderManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("录音未成功完成")
            resetRecording()
        }
        isRecording = false
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("录音编码错误: \(error.localizedDescription)")
        }
        stopRecording()
        resetRecording()
    }
}