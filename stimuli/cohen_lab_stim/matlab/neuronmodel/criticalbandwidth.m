%
%function [CB]=criticalbandwidth(fc)
%
%   FILE NAME       : CRITICAL BANDWIDTH
%   DESCRIPTION     : Critical Bandwidth for auditory fitlers
%                     
%	fc              : Filter characteristic frequency (Hz)
%
%RETURNED VARIABLES
%
%	CB               : Critical Bandwidth (Hz)
%
% (C) Monty A. Escabi, December 2007
%
function [CB]=criticalbandwitdh(fc)

CB=94+71.*(fc/1000).^(3/2);

%Alternate form which gives nearly identical result: CB = 25 + 75 * [1 + 1.4 *(fc/1000).^2].^0.69 - Zwicker & Terhardt 1980