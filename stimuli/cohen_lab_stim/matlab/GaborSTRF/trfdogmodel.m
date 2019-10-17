%
%function [TRF,TRFe,TRFi]=trfdogmodel(beta,taxis)
%
%   FILE NAME       : TRF DOG MODEL
%   DESCRIPTION     : Temporal receptive field difference of Gaussian model
%
%   beta            : DOG parameter vector
%                     beta(1): Excitatory Peak delay (msec)
%                     beta(2): Inhibitory Peak delay (msec)
%                     beta(3): Excitatory Gaussian temporal duration (msec)
%                     beta(4): Inhibitory Gaussian temporal duration (msec)
%                     beta(5): Excitatory Peak amplitude
%                     beta(6): Inhibitory Peak amplitude
%   taxis           : Time axis (msec)
%
%RETURNED VARIABLES
%
%   TRF             : Model temporal receptive field (TRF)
%   TRFe            : Model excitatory temporal receptive field 
%   TRFi            : Model inhibitory temporal receptive field
%
% (C) Monty A. Escabi, August 2009
%
function [TRF,TRFe,TRFi]=trfdogmodel(beta,taxis);

taxis=taxis/1000;
TRFe=beta(5)*exp(-(2*(taxis-beta(1)/1000)/(beta(3)/1000)).^2);
TRFi=-beta(6)*exp(-(2*(taxis-beta(2)/1000)/(beta(4)/1000)).^2);
TRF=TRFe+TRFi;