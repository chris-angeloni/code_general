function maxPeakAccel = splToMaxPeakAccel(db_SPL, tOnset)
% function maxPeakAccel = splToMaxPeakAccel(db_SPL, tOnset)
% 
% computes maximum peak acceleration for sin^2 onset pure tones
%
% for example, for a sinusoid (pure tone):
% peak sound pressure (in Pascals) = sqrt(2)*(2E-5 Pa)*10^(db_SPL/20)

maxPeakAccel = (2*pi/(tOnset*2)).^2 * sqrt(2) * 2E-5 * 10 .^(db_SPL/20);

return
