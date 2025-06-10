//
//  LanguageConfig.swift
//  sheng
//
//  Created by Tim on 8/6/25.
//

import Foundation
import SwiftUI
import Observation

struct LanguageConfig: Identifiable {
    let code: String
    let name: String
    let recordingPrompt: String
    let sampleStory: String
    
    var id: String { code }
}

@Observable
class LanguageManager {
    static let shared = LanguageManager()
    
    let supportedLanguages: [LanguageConfig] = [
        LanguageConfig(
            code: "zh-cn",
            name: "普通话",
            recordingPrompt: "请用清晰的普通话朗读以下内容：我是一个热爱生活的人，喜欢在阳光明媚的日子里散步。每当看到美丽的风景，我的心情就会变得特别愉快。",
            sampleStory: "在一个宁静的小镇上，住着一位善良的老人。他每天都会在花园里种植各种美丽的花朵。春天来临时，整个花园都会绽放出绚烂的色彩。邻居们经常来欣赏这些花朵，老人总是热情地与他们分享园艺的心得。他相信，美丽的事物应该与大家一起分享，这样才能让世界变得更加温暖。随着时间的流逝，这个小花园成为了整个小镇最受欢迎的地方，人们在这里找到了内心的平静与快乐。"
        ),
        LanguageConfig(
            code: "yue-cn",
            name: "粤语",
            recordingPrompt: "请用清晰的粤语朗读以下内容：我系一个钟意生活嘅人，钟意喺阳光普照嘅日子里面行街。每次见到靓嘅风景，我嘅心情就会变得特别开心。",
            sampleStory: "喺一个宁静嘅小镇度，住咗一个善良嘅老人家。佢每日都会喺花园里面种各种靓嘅花。春天嚟到嘅时候，成个花园都会开晒好靓嘅花。邻居成日嚟睇呢啲花，老人家总系好热情咁同佢哋分享种花嘅心得。佢相信，靓嘅嘢应该同大家一齐分享，咁样先可以令个世界变得更加温暖。随住时间过去，呢个小花园变咗成个小镇最受欢迎嘅地方，人哋喺呢度搵到内心嘅平静同快乐。"
        ),
        LanguageConfig(
            code: "en",
            name: "English",
            recordingPrompt: "Please read the following content clearly in English: I am a person who loves life and enjoys taking walks on sunny days. Whenever I see beautiful scenery, my mood becomes particularly joyful.",
            sampleStory: "In a quiet small town, there lived a kind old man. Every day, he would plant various beautiful flowers in his garden. When spring arrived, the entire garden would bloom with brilliant colors. Neighbors often came to admire these flowers, and the old man always warmly shared his gardening insights with them. He believed that beautiful things should be shared with everyone, as this would make the world warmer. As time passed, this small garden became the most popular place in the entire town, where people found inner peace and happiness."
        )
    ]
    
    var selectedLanguage: LanguageConfig
    
    private init() {
        self.selectedLanguage = supportedLanguages[0] // 默认选择普通话
    }
    
    func selectLanguage(by code: String) {
        if let language = supportedLanguages.first(where: { $0.code == code }) {
            selectedLanguage = language
        }
    }
    
    func getLanguage(by code: String) -> LanguageConfig? {
        return supportedLanguages.first(where: { $0.code == code })
    }
}