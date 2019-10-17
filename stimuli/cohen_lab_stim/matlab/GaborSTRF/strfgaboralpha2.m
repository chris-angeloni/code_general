%
%function [STRFm]=strfgaboralpha2(beta,input)
%
%   FILE NAME       : STRF GABOR ALPHA 2
%   DESCRIPTION     : Nonseparable STRF model. The spectral receptive field
%                     is modeled as a gabor function while the temporal
%                     receptive field is modeled as the product of an alpha
%                     fucntion and a cosine.
%
%   beta            : STRF parameter vector
%       PARAMETERS FOR FIRST STRF COMPONENTS
%                     beta(1): Response latency (msec)
%                     beta(2): Rise time constant (msec)
%                     beta(3): Decay time constant (msec)
%                     beta(4): Best temporal modulation frequency (Hz)
%                     beta(5): Temporal phase (0-2*pi)
%                     beta(6): Best octave frequency, xo
%                     beta(7): Gaussian spectral bandwidth (octaves)
%                     beta(8): Best spectral modulation frequency (octaves)
%                     beta(9): Spectral phase (0-2*pi)
%                     beta(10): Peak Amplitude
%       PARAMETERS FOR SECOND STRF COMPONENT ALSO INCLUDE
%                     beta(11): Response latency (msec)
%                     beta(12): Rise time constant (msec)
%                     beta(13): Decay time constant (msec)
%                     beta(14): Best temporal modulation frequency (Hz)
%                     beta(15): Temporal phase (0-2*pi)
%                     beta(16): Best octave frequency, xo
%                     beta(17): Gaussian spectral bandwidth (octaves)
%                     beta(18): Best spectral modulation frequency (octaves)
%                     beta(19): Spectral phase (0-2*pi)
%                     beta(20): Peak Amplitude
%   input.taxis     : Time axis (msec)
%   input.X         : Octave frequency axis (octaves)
%
%RETURNED VARIABLES
%
%   STRFm           : Speraable STRF model
%
% (C) Monty A. Escabi, October 2006
%
function [STRFm]=strfgaboralpha2(beta,input)

%Temporal and Spectral Parameters
betat1=[beta(1:5) 1];
betas1=[beta(6:10)];
betat2=[beta(11:15) 1];
betas2=[beta(16:20)];

%Temporal and Spectral Receptive Field
[TRF1]=trfalphamodel(betat1,input.taxis);
[SRF1]=srfgabormodel(betas1,input.X);
[TRF2]=trfalphamodel(betat2,input.taxis);
[SRF2]=srfgabormodel(betas2,input.X);

%Spectrotemporal Receptive Field
STRFm=SRF1'*TRF1+SRF2'*TRF2;