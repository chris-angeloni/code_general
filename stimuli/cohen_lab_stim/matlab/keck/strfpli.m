%
%function [PLI]=strfpli(STRF,Wo,PP,Sound)
%
%       FILE NAME       : STRF PLI
%       DESCRIPTION     : Computes the STRF phase locking index (PLI)
%                         according to Escabi & Schreiner 2002
%
%                         Note: Assumes that sounds and the STRF
%                         analysis was performed using same units (both in
%                         dB or Lin).
%
%       STRF            : Spectro-Temporal Receptive Field
%       Wo              : Zeroth Order Kernel ( Number of Spikes / Sec )
%       PP              : Power Level
%       Sound           : Sound Type 
%                         Moving Ripple : 'MR' ( Default )
%                         Ripple Noise  : 'RN'
%
%RETURNED VALUES
%
%       PLI             : Phase Locking Index
%
%   (C) M. Escabi, July 2006 (Edit Jan 2008)
%
function [PLI]=strfpli(STRF,Wo,PP,Sound)

%Normalized Peak to Peak Amplitude for DMR or RN
if Sound=='MR'
    delta=sqrt(8);
else
    delta=sqrt(12);
end

%Phase Locking Index
PLI=(max(max(STRF))-min(min(STRF)))*sqrt(PP)/Wo/delta;