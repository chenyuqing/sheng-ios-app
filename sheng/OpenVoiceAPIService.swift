//
//  OpenVoiceAPIService.swift
//  sheng
//
//  Created by Tim on 8/6/25.
//

import Foundation
import AVFoundation

class OpenVoiceAPIService {
    private let baseURL: String
    private let apiKey: String
    private let session: URLSession
    
    init(baseURL: String = "http://localhost:8000", apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.session = URLSession.shared
    }
    
    // 验证 API 密钥是否有效
    func validateAPIKey() async -> Result<Bool, APIServiceError> {
        guard let url = URL(string: "\(baseURL)/validate-key") else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }
            
            if httpResponse.statusCode == 200 {
                return .success(true)
            } else if httpResponse.statusCode == 401 {
                return .success(false)
            } else {
                return .failure(.httpError(httpResponse.statusCode))
            }
        } catch {
            return .failure(.serverError(error.localizedDescription))
        }
    }
    
    // 文本转语音
    func textToSpeech(text: String, voice: String, language: String, speed: Double) async -> Result<Data, APIServiceError> {
        guard let url = URL(string: "\(baseURL)/tts") else {
            return .failure(.invalidURL)
        }
        
        let speechRequest = SpeechRequest(text: text, voice: voice, language: language, speed: speed)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(speechRequest)
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }
            
            if httpResponse.statusCode == 200 {
                return .success(data)
            } else {
                return .failure(.httpError(httpResponse.statusCode))
            }
        } catch let error as EncodingError {
            return .failure(.encodingError)
        } catch {
            return .failure(.serverError(error.localizedDescription))
        }
    }
}

// MARK: - Request Models
struct SpeechRequest: Codable {
    let model: String
    let input: String
    let voice: String
    let language: String
    let responseFormat: String
    let speed: Double
    
    enum CodingKeys: String, CodingKey {
        case model, input, voice, language, speed
        case responseFormat = "response_format"
    }
    
    init(text: String, 
         voice: String = "default_voice.pt",
         language: String = "zh-cn",
         speed: Double = 1.0) {
        self.model = "openvoice-v2"
        self.input = text
        self.voice = voice
        self.language = language
        self.responseFormat = "wav"
        self.speed = speed
    }
}

// MARK: - Response Models
struct VoicesResponse: Codable {
    let voices: [Voice]
}

struct Voice: Codable, Identifiable {
    let voiceId: String
    let voiceName: String
    let type: String
    
    var id: String { voiceId }
    
    enum CodingKeys: String, CodingKey {
        case voiceId = "voice_id"
        case voiceName = "voice_name"
        case type
    }
}

struct CloneVoiceResponse: Codable {
    let message: String
    let voiceId: String
    let voiceName: String
    let fullVoicePath: String
    
    enum CodingKeys: String, CodingKey {
        case message
        case voiceId = "voice_id"
        case voiceName = "voice_name"
        case fullVoicePath = "full_voice_path"
    }
}

enum APIServiceError: Error {
    case invalidURL
    case invalidResponse
    case serverError(String)
    case httpError(Int)
    case encodingError
    case decodingError
}