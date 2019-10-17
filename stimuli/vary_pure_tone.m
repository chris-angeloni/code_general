function wave = vary_pure_tone( envelope, freq )
% Generate a waveform with instantaneous frequency freq and amplitude
% envelope at any given time. Frequency is measured relative to the
% sample rate.

if length(envelope) ~= length(freq)
    error('Envelope and frequency descriptors are of different lengths');
end

phase = cumsum(freq);
wave = sin(2*pi*phase) .* envelope;