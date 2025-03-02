//
//  SimpleSpeechToText.swift
//  CravePhone
//
//  Path: /Users/jj/Desktop/IOS Applications/crave-trinity-frontend/CravePhone/Utilities/SimpleSpeechToText.swift
//

import Foundation

public enum SpeechRecognitionError: Error, LocalizedError {
    case notAuthorized
    case recognizerUnavailable
    case audioSessionFailed(String)
    case recognitionFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Speech recognition permission not granted."
        case .recognizerUnavailable:
            return "Speech recognizer is currently unavailable."
        case let .audioSessionFailed(message),
             let .recognitionFailed(message):
            return message
        }
    }
}

public protocol SpeechToTextServiceProtocol: AnyObject {
    /// Ask user for permission. Returns `true` if granted, `false` otherwise.
    func requestAuthorization() async -> Bool
    
    /// Attempts to start speech recognition.
    /// - Returns: `true` if successfully started, `false` otherwise.
    /// - Throws: `SpeechRecognitionError` if something prevents speech recognition from starting
    func startRecording() throws -> Bool
    
    /// Stops recording and ends recognition gracefully.
    func stopRecording()
    
    /// A closure for partial or final text updates.
    var onTextUpdated: ((String) -> Void)? { get set }
}
