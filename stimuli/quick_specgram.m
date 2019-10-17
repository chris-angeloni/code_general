function S=quick_specgram(sound, rate, dt, fpass)
% Produce a spectrogram of a waveform.

if nargin < 3
    dt = .25e-3;
end

if nargin < 4
    fpass = [400 rate/2];
end

T1 = 8*dt;     % length of the time window in secs
T2 = dt;       % step size in secs
W = 1000;      % bandwith resolution
params.fpass = fpass;
params.pad = 0;
params.tapers = [W T1 1];
params.movingwin = [T1 T2];
params.Fs = rate;


[S.S,S.t,S.f] = mtspecgramc(sound, params.movingwin, params);
