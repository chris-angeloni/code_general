function ramp = make_ramp(ramp_length)

ramp = linspace(0,1,ramp_length);                  % linear ramp
scale = 1 ./ sqrt(ramp.^2 + (1-ramp).^2);   % account for change in variance as noise is added

ramp = ramp .* scale;


