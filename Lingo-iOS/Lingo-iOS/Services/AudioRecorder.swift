//
//  AudioRecorder.swift
//  Lingo
//
//  Audio recording with AVFoundation and real-time volume monitoring
//

import Foundation
import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var volume: Float = 0.0
    @Published var errorMessage: String?

    private var audioRecorder: AVAudioRecorder?
    private var audioEngine: AVAudioEngine?
    private var volumeTimer: Timer?
    private var recordingURL: URL?

    override init() {
        super.init()
        setupAudioSession()
    }

    // MARK: - Setup

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            errorMessage = "Failed to set up audio session: \(error.localizedDescription)"
        }
    }

    // MARK: - Permissions

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    // MARK: - Recording

    func startRecording() {
        // Check permission first
        Task {
            let hasPermission = await requestPermission()
            guard hasPermission else {
                await MainActor.run {
                    self.errorMessage = "Microphone permission denied"
                }
                return
            }

            await MainActor.run {
                self.beginRecording()
            }
        }
    }

    private func beginRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        recordingURL = documentsPath.appendingPathComponent("recording-\(Date().timeIntervalSince1970).m4a")

        guard let url = recordingURL else {
            errorMessage = "Failed to create recording URL"
            return
        }

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()

            isRecording = true
            errorMessage = nil

            // Start volume monitoring
            startVolumeMonitoring()
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }

    func stopRecording() async -> Data? {
        audioRecorder?.stop()
        stopVolumeMonitoring()

        await MainActor.run {
            self.isRecording = false
            self.volume = 0.0
        }

        guard let url = recordingURL else {
            return nil
        }

        do {
            let audioData = try Data(contentsOf: url)

            // Clean up the temporary file
            try? FileManager.default.removeItem(at: url)

            return audioData
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to read recording: \(error.localizedDescription)"
            }
            return nil
        }
    }

    // MARK: - Volume Monitoring

    private func startVolumeMonitoring() {
        volumeTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateVolume()
        }
    }

    private func stopVolumeMonitoring() {
        volumeTimer?.invalidate()
        volumeTimer = nil
    }

    private func updateVolume() {
        guard let recorder = audioRecorder, recorder.isRecording else {
            return
        }

        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0)

        // Convert decibels to 0-1 range
        // averagePower ranges from -160 (silence) to 0 (max)
        let normalizedVolume = pow(10, averagePower / 20)
        let clampedVolume = max(0, min(1, normalizedVolume))

        DispatchQueue.main.async {
            self.volume = clampedVolume
        }
    }

    // MARK: - Cleanup

    func cleanup() {
        audioRecorder?.stop()
        stopVolumeMonitoring()
        audioRecorder = nil

        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
