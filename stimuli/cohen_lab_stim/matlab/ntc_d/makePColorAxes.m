function [dispFreqs, dispAmps] = makePColorAxes(fMin, nOctaves, extAtten);

global NFREQS NAMPS

INCLUDE_DEFS;

% we also need to make appropriate axes for pcolor -- these frequencies are
%   NOT the real stimulus frequencies, but are one half-step off.

fmmax = fMin*(2^((nOctaves*(NFREQS-0.5))/(NFREQS-1)));
fmmin = fMin*(2^(nOctaves*(-0.5)/(NFREQS-1)));

dispFreqs = logspace(log10(fmmin), log10(fmmax),NFREQS+1);

tAmps = makeAmps;
dispAmps = [(tAmps - DEFAULT_AMP_STEP/2) ...
            (tAmps(end) + DEFAULT_AMP_STEP/2)]; 
if isfinite(extAtten),
  dispAmps = dispAmps + (30-extAtten);
  end
  
return

%%%---------------------
