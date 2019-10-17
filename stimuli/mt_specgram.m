function [t,f,S] = mt_specgram(sound, fs, dt, fpass, W, pad, plot)

%function [t,f,S] = mt_specgram(sound, fs, dt, fpass, W, pad, plot)
%
% INPUTS
%  sound = timeseries input
%  fs    = sampling rate
%  dt    = window width
%  fpass = included frequencies
%  W     = bandwidth resolution
%  pad   = padding of time bins as a factor of greatest power of 2 (eg. 1 =
%          closest power, 2 = next closest, 0 = no padding, etc)
%  plot  = plot on or off
%
% OUTPUTS
%  S     = amplitude matrix
%  t     = time vector
%  f     = freq vector

if ~exist('plot','var') || isempty(plot)
    plot = 0;
end

if ~exist('pad','var') || isempty(pad)
    pad = 0;
end

if ~exist('fpass','var') || isempty(fpass)
    fpass = [400 fs/2];
end

if ~exist('dt','var') || isempty(dt)
    dt = .25e-3;
end

if ~exist('W','var') || isempty(W)
    W = 1000;     % bandwidth resolution
end

T1 = 8 * dt;  % time window length (s)
T2 = dt;      % step size (s)
params.fpass = fpass;
params.pad = pad;
params.tapers = [W T1 1];
params.movingwin = [T1 T2];
params.Fs = fs;

[S,t,f] = mtspecgramc(sound, params.movingwin, params);
S = S';

% Plot
if plot == 1
    h = plot_specgram(S,t,f,-140);
    %colorbar;
elseif plot == 2
    imagesc(t,f,S);
    set(gca,'YDir','normal');
    colorbar;  
end