function [pure,a,f] = purify_call(call, fs, mask)
% [pure, a, f] = purify_call(call, fs, mask)
%   Reduce a call to an amplitude- and frequency-modulated pure tone.
% 
% Parameters:
%   call : waveform of the call
%   fs : sampling frequency of the call waveform in Hz
%   mask : optional, masking vector
%
% Returns:
%   pure : purified waveform
%   a : extracted amplitude vector
%   f : extracted frequency vector


S = quick_specgram(call, fs);


% The second argument to purify_specgram is the bandwidth of the tones
% we are trying to select for.
if nargin == 3,
    [a,fi] = purify_specgram(S.S, 5, length(call), mask);
else
    [a,fi] = purify_specgram(S.S, 5, length(call));
end

% Translated from frequency-index to frequency in Hz.
f = interp1(1:length(S.f), S.f, fi);
% Translate frequency components into units used by vary_pure_tone
pure = vary_pure_tone(a, f / fs);
