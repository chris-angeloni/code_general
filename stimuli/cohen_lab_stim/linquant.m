%
%function [Y]=linquan(X,B,seed)
%
%       FILE NAME       : LIN QUANT
%       DESCRIPTION     : Quantizes a signal using a linear amplitude
%           	          spaced quantizer. Assumes int16 input signal
%                         with maximu 1024*32 and minimu -1024*32 amplitudes
%
%       X               : Input signal
%       B               : Number of Quantization Bits for lin quantizer
%       seed            : Random seed for adjusting the starting quantizer level
%                         (Optional, Default=='behavior not used')
%RETURNED VATIABLES
%
%       Y               : Output Signal
%
% (C) Monty A. Escabi, July 2005
%
function [Y]=linquant(X,B,seed)

%Input Arguments
if nargin<3
    offset=0;
else
    rand('state',seed);
    offset=2*(rand-0.5);
end

%Qunatization Resolution
delta=1024*32/2^(B-1);

%Quantizing Signal
Y=round(X/delta*(delta/2-1)/(delta/2)+offset)*delta*(delta/2)/(delta/2-1);