%
%function [TRF]=trfalphamodel(beta,time)
%
%   FILE NAME       : TRF GABOR MODEL
%   DESCRIPTION     : Temporal receptive field gabor model
%
%   beta            : Gabor parameter vector
%                     beta(1): Response latency (msec)
%                     beta(2): Rise time constant (msec)
%                     beta(3): Decay time constant (msec)
%                     beta(4): Peak Amplitude
%                     beta(5): Best temporal modulation frequency (Hz)
%                     beta(6): Temporal phase (0-2*pi)
%   time            : Time axis (msec)
%
%RETURNED VARIABLES
%
%   SRF             : Model temporal receptive field (TRF)
%
% (C) Monty A. Escabi, October 2006
%
function [TRF]=trfalphamodel(beta,time);

E=time.^(N-1).*exp(-2*pi*b*t).*cos(2*pi*fc*time+P);
TRF=E.*cos(2*pi*beta(5)*(time/1000-beta(2)/1000)+beta(6));