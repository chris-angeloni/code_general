function [s,t] = genTone(fs,f,d,amp,ramp,phase)

if ~exist('ramp','var') || isempty(ramp)
    ramp = 0;
end
if ~exist('phase','var') || isempty(phase) 
    phase = 0;
end
if ~exist('amp','var') || isempty(amp)
    amp = 1;
end

if ramp > 0
    n = round(fs*(d + 2*ramp));
    r = make_ramp(ramp*fs);
    r = [r ones(1,n - (2*ramp*fs)) fliplr(r)];
else
    n = round(fs*d);
    r = ones(1,n);
end

t = (1:n) / fs;
s = amp * sin(2 * pi * f * t + phase);
s = s .* r;