//
//  AiChatSpeechRecognizer.swift
//  Medsy
//

import Foundation
import Speech
import AVFoundation

/// Wraps SFSpeechRecognizer for live speech-to-text transcription.
final class AiChatSpeechRecognizer: NSObject, @unchecked Sendable {

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let recognizer: SFSpeechRecognizer?

    override init() {
        recognizer = SFSpeechRecognizer(locale: Locale.current)
        super.init()
        print("🎙️ [SpeechRecognizer] Initialized — locale: \(Locale.current.identifier), recognizer available: \(recognizer?.isAvailable ?? false)")
    }

    func start(
        onPartial: @escaping (String) -> Void,
        onFinished: @escaping (String) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        print("🎙️ [SpeechRecognizer] Requesting authorization…")
        SFSpeechRecognizer.requestAuthorization { status in
            print("🎙️ [SpeechRecognizer] Authorization status: \(status.rawValue) (\(status == .authorized ? "✅ authorized" : "❌ not authorized"))")
            guard status == .authorized else {
                onError(NSError(domain: "Speech", code: 1, userInfo: [NSLocalizedDescriptionKey: "Permission denied"]))
                return
            }
            DispatchQueue.main.async {
                self.beginRecognition(onPartial: onPartial, onFinished: onFinished, onError: onError)
            }
        }
    }

    private func beginRecognition(
        onPartial: @escaping (String) -> Void,
        onFinished: @escaping (String) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        print("🎙️ [SpeechRecognizer] beginRecognition — stopping previous session if any")
        stop()

        let audioSession = AVAudioSession.sharedInstance()
        print("🎙️ [SpeechRecognizer] Setting up AVAudioSession (category: playAndRecord)…")
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("🎙️ [SpeechRecognizer] AVAudioSession activated ✅")
        } catch {
            print("🎙️ [SpeechRecognizer] ❌ AVAudioSession setup failed: \(error)")
            onError(error)
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        print("🎙️ [SpeechRecognizer] inputNode format — sampleRate: \(format.sampleRate), channels: \(format.channelCount)")

        // Guard: Simulator can return 0 Hz / 0-channel format when no mic is routed
        guard format.sampleRate > 0 && format.channelCount > 0 else {
            print("🎙️ [SpeechRecognizer] ❌ Invalid audio format — mic not available in simulator. sampleRate=\(format.sampleRate) channels=\(format.channelCount)")
            onError(NSError(domain: "Speech", code: 2, userInfo: [NSLocalizedDescriptionKey: "Audio input is unavailable. Please check simulator/device microphone settings."]))
            return
        }

        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result {
                let transcript = result.bestTranscription.formattedString
                print("🎙️ [SpeechRecognizer] Partial: \"\(transcript)\" isFinal=\(result.isFinal)")
                if result.isFinal {
                    onFinished(transcript)
                } else {
                    onPartial(transcript)
                }
            }
            if let error {
                print("🎙️ [SpeechRecognizer] ❌ Recognition error: \(error)")
                onError(error)
            }
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        print("🎙️ [SpeechRecognizer] Starting audio engine…")
        do {
            try audioEngine.start()
            print("🎙️ [SpeechRecognizer] Audio engine running ✅ — listening for speech")
        } catch {
            print("🎙️ [SpeechRecognizer] ❌ Audio engine start failed: \(error)")
            onError(error)
        }
    }

    func stop() {
        guard audioEngine.isRunning else {
            print("🎙️ [SpeechRecognizer] stop() called but engine was not running — skipping")
            return
        }
        print("🎙️ [SpeechRecognizer] Stopping audio engine and cleaning up…")
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        try? AVAudioSession.sharedInstance().setActive(false)
        print("🎙️ [SpeechRecognizer] Stopped ✅")
    }
}

