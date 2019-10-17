%
%function [wc]=tcfhalfpowfreqoptim(beta)
%
%   FILE NAME   : TCF HALF POW FREQ OPTIM
%   DESCRIPTION : Finds the half power frequency based the using temporal
%                 coding fraction. The routine uses LSQCURVEFIT to find the
%                 solution for the criteria function F =
%                 abs(AC*(1-0.5*Max) - 0.5*Max*DC). The solution is based
%                 on a spiking model with jitter, reliability and
%                 sponteneous firing errros.  Half power is achieved
%                 when F = 0. 
%
%   beta        : Model Parameter Vector
%                 lambdas   = spontaneous firing rate       = beta(1) 
%                 x         = reliability (spikes/cycle)    = beta(2)
%                 sigma     = spike timing jitter SD (ms)   = beta(3) 
%
%RETURNED VARIABLES
%
%   wc          : Cutoff or 1/2 power frequency (rad/sec)
%
% (C) Monty A. Escabi, Aug 2014
%
function [wc]=tcfhalfpowfreqoptim(beta)

wc = lsqnonlin(@(wc) tcfhalfpowfreq(wc,beta),2*pi*500);