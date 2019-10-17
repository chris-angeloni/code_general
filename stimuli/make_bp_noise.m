function [n_bp, seed] = make_bp_noise(l, m, fs, bpass, max_a)

% function [n_bp, seed] = make_bp_noise(l, m, fs, bpass, max_a)
% Generates bandpassed noise with a 4th order Butterworth filter and
% rescales it to a given amplitude if specified.
%  INPUTS: 
%   l     = length of noise signal
%   m     = number of signals to generate
%   fs    = sampling frequency of signal       
%   bpass = vector of frequency band limits
%   max_a = amplitude to scale to (optional)
%  OUTPUTS:
%   n_bp  = filtered noise (matrix of size m x l)
%   seed  = seed to generate noise (so its possible to recreate later)

% Set the seed
seed = round(rand * 100000);
rng(seed);

% Generate noise
n = randn(m,l); %[t,f,S] = mt_specgram(n,fs,.25e-3,[],[],1);

% Bandpass filter the noise
[b, a] = butter(4, bpass/(fs/2), 'bandpass');
for i = 1:m
    n_bp(i,:) = filter(b,a,n(i,:));
    
    % Rescale
    if exist('max_a','var')
        n_bp(i,:) = n_bp(i,:) / max(abs(n_bp(i,:))) * max_a; %[t,f,S] = mt_specgram(n_bp,fs,.25e-3,[],[],1);
    end

end