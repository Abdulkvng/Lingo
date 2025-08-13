import { useState, useRef, useCallback } from 'react';

type UseRecorderProps = {
    onRecordingComplete: (blob: Blob) => void;
};

export const useRecorder = ({ onRecordingComplete }: UseRecorderProps) => {
    const [isRecording, setIsRecording] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [volume, setVolume] = useState(0);

    const mediaRecorderRef = useRef<MediaRecorder | null>(null);
    const audioChunksRef = useRef<Blob[]>([]);
    const audioContextRef = useRef<AudioContext | null>(null);
    const animationFrameIdRef = useRef<number | null>(null);

    const startRecording = useCallback(async () => {
        setError(null);
        if (isRecording) return;

        try {
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            
            const recorder = new MediaRecorder(stream);
            mediaRecorderRef.current = recorder;
            audioChunksRef.current = [];

            recorder.ondataavailable = (event) => {
                if (event.data.size > 0) {
                    audioChunksRef.current.push(event.data);
                }
            };

            recorder.onstop = () => {
                const audioBlob = new Blob(audioChunksRef.current, { type: 'audio/webm' });
                onRecordingComplete(audioBlob);

                // Full resource cleanup
                if (audioContextRef.current && audioContextRef.current.state !== 'closed') {
                    audioContextRef.current.close();
                }
                if (animationFrameIdRef.current) {
                    cancelAnimationFrame(animationFrameIdRef.current);
                }
                stream.getTracks().forEach(track => track.stop());
                audioChunksRef.current = [];
            };
            
            const context = new (window.AudioContext || (window as any).webkitAudioContext)();
            audioContextRef.current = context;
            const source = context.createMediaStreamSource(stream);
            const analyser = context.createAnalyser();
            analyser.fftSize = 256;
            const dataArray = new Uint8Array(analyser.frequencyBinCount);
            source.connect(analyser);

            const updateVolume = () => {
                if (analyser && context.state === 'running') {
                    analyser.getByteTimeDomainData(dataArray);
                    let sumSquares = 0.0;
                    for (let i = 0; i < dataArray.length; i++) {
                        const v = (dataArray[i] / 128.0) - 1.0; // Normalize to -1.0 to 1.0
                        sumSquares += v * v;
                    }
                    const rms = Math.sqrt(sumSquares / dataArray.length);
                    setVolume(Math.min(1, rms * 2.5)); // Clamp and amplify for better visualization
                    animationFrameIdRef.current = requestAnimationFrame(updateVolume);
                }
            };
            
            recorder.start();
            setIsRecording(true);
            updateVolume();

        } catch (err) {
            console.error("Error starting recording:", err);
            setError("Microphone access was denied. Please allow microphone access in your browser settings.");
            setIsRecording(false);
        }
    }, [isRecording, onRecordingComplete]);

    const stopRecording = useCallback(() => {
        if (isRecording && mediaRecorderRef.current && mediaRecorderRef.current.state === "recording") {
            mediaRecorderRef.current.stop();
        }
        setIsRecording(false);
        setVolume(0);
        if (animationFrameIdRef.current) {
            cancelAnimationFrame(animationFrameIdRef.current);
        }
    }, [isRecording]);

    return { isRecording, startRecording, stopRecording, error, volume };
};
