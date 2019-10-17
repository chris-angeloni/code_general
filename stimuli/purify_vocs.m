function [pure,a,f] = purify_vocs(call, fs, fpass, amp_thresh, dt)
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


[t,f,S] = mt_specgram(call, fs, dt, fpass, 1000, 0, 0);

% Purify it
[a,fi] = purify_specgram(S', 5, length(call), [], amp_thresh);


% Translated from frequency-index to frequency in Hz.
f = interp1(1:length(f), f, fi);
% Translate frequency components into units used by vary_pure_tone
pure = vary_pure_tone(a, f / fs);
