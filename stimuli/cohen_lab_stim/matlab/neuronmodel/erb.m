%
%function [B]=erb(fc)
%
%   FILE NAME       : Equivalent Rectangular Bandwidth
%   DESCRIPTION     : Equivalent rectangular bandwidth for auditory fitlers
%                     
%	fc              : Filter characteristic frequency (Hz)
%
%RETURNED VARIABLES
%
%	B               : Equivalent Rectangular Bandwidth (Hz)
%
% (C) Monty A. Escabi, October 2006
%
function [B]=erb(fc)

B=1.019*24.7*(1+4.37*fc/1000);  %Moore & Glassberg Enq. - 1996