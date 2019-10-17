function amps = makeAmps
% function amps = makeAmps;

global DEFAULT_AMP_STEP DEFAULT_AMP_MAX NAMPS

INCLUDE_DEFS;

amps = DEFAULT_AMP_MAX - ((NAMPS-1):-1:0)*DEFAULT_AMP_STEP;

return


