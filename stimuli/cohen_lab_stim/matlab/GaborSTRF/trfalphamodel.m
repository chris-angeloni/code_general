%
%function [TRF,E]=trfalphamodel(beta,taxis)
%
%   FILE NAME       : TRF ALPHA MODEL
%   DESCRIPTION     : Temporal receptive field alpha function model
%
%   beta            : Gabor parameter vector
%                     beta(1): Response latency (msec)
%                     beta(2): Rise time constant (msec)
%                     beta(3): Decay time constant (msec)
%                     beta(4): Best temporal modulation frequency (Hz)
%                     beta(5): Temporal phase (0-2*pi)
%                     beta(6): Peak Amplitude
%   taxis            : Time axis (msec)
%
%RETURNED VARIABLES
%
%   TRF             : Model temporal receptive field (TRF)
%   E               : Envelope
%
% (C) Monty A. Escabi, October 2006
%
function [TRF,E]=trfalphamodel(beta,taxis);

E=alphafxnmodel([beta(1) beta(2) beta(3) beta(6) 0],taxis);
TRF=E.*cos(2*pi*beta(4)*(taxis-beta(1)-beta(2))/1000+beta(5));