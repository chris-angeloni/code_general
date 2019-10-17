function  [dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);
%function  [dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);

global NFREQS NAMPS

INCLUDE_DEFS;

dispFreqs = zeros(1,NFREQS);
for ii=0:(NFREQS-1),
  dispFreqs(ii+1)= fMin*(2^(nOctaves*ii/(NFREQS-1)));
  end

dispAmps = makeAmps;
if isfinite(extAtten),
  dispAmps = dispAmps + (30 - extAtten);
  end

return
