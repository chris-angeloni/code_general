%
%function [SRF,SRFe,SRFi]=srfdogmodel(beta,X)
%
%   FILE NAME       : SRF DOG MODEL
%   DESCRIPTION     : Spectral receptive field difference of Gaussian model
%
%   beta            : DOG parameter vector
%                     beta(1): Excitatory Peak Best Frequency (octaves)
%                     beta(2): Inhibitory Peak Best Frequency (octaves)
%                     beta(3): Excitatory Gaussian Bandwidth (octaves)
%                     beta(4): Inhibitory Gaussian Bandwidth (octaves)
%                     beta(5): Excitatory Gaussian Peak Amplitude
%                     beta(6): Inhibitory Gaussian Peak amplitude
%   X               : Frequency Axis (octaves)
%
%RETURNED VARIABLES
%
%   SRF             : Model spectral receptive field (SRF)
%   SRFe            : Model excitatory spectral receptive field (SRF)
%   SRFi            : Model inhibitory spectral receptive field (SRF)
%
% (C) Monty A. Escabi, August 2009
%
function [SRF,SRFe,SRFi]=srfdogmodel(beta,X);

SRFe=beta(5)*exp(-(2*(X-beta(1))/(beta(3))).^2);
SRFi=-beta(6)*exp(-(2*(X-beta(2))/(beta(4))).^2);
SRF=SRFe+SRFi;