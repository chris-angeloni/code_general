%
%function [STRFm]=strfgaboralpha1(beta,input)
%
%   FILE NAME       : STRF GABOR ALPHA 1
%   DESCRIPTION     : Separable STRF model. The spectral receptive field
%                     is modeled as a gabor function while the temporal
%                     receptive field is modeled as the product of an alpha
%                     fucntion and a cosine.
%
%   beta            : STRF parameter vector
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
%   input.taxis     : Time axis (msec)
%   input.X         : Octave frequency axis (octaves)
%
%RETURNED VARIABLES
%
%   STRFm           : Speraable STRF model
%
% (C) Monty A. Escabi, October 2006
%
function [STRFm]=strfgaboralpha1(beta,input)

%Temporal and Spectral Parameters
betat=[beta(1:5) 1];
betas=[beta(6:10)];

%Temporal and Spectral Receptive Field
[TRF]=trfalphamodel(betat,input.taxis);
[SRF]=srfgabormodel(betas,input.X);

%Spectrotemporal Receptive Field
STRFm=SRF'*TRF;
%STRFm=reshape(STRFm,1,size(STRFm,1)*size(STRFm,2));