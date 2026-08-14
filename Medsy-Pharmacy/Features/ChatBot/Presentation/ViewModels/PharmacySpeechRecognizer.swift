//
//  PharmacySpeechRecognizer.swift
//  Medsy-Pharmacy
//
//  Pharmacy-scoped wrapper around SFSpeechRecognizer for live speech-to-text transcription.
//  Kept separate from the patient target's AiChatSpeechRecognizer per target isolation rules.

import Foundation
import Speech
import AVFoundation

final class PharmacySpeechRecognizer: NSObject, @unchecked Sendable {

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let recognizer: SFSpeechRecognizer?

    override init() {
        recognizer = SFSpeechRecognizer(locale: Locale.current)
        super.init()
    }

    func start(
        onPartial: @escaping (String) -> Void,
        onFinished: @escaping (String) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        SFSpeechRecognizer.requestAuthorization { status in
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
        stop()

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            onError(error)
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        guard format.sampleRate > 0 && format.channelCount > 0 else {
            onError(NSError(domain: "Speech", code: 2, userInfo: [NSLocalizedDescriptionKey: "Audio input unavailable."]))
            return
        }

        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result {
                let transcript = result.bestTranscription.formattedString
                if result.isFinal {
                    onFinished(transcript)
                } else {
                    onPartial(transcript)
                }
            }
            if let error {
                onError(error)
            }
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            onError(error)
        }
    }

    func stop() {
        guard audioEngine.isRunning else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
