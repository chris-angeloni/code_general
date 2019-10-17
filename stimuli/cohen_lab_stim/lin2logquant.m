%function [Y]=lin2logquant(X,B,seed)
%
%       FILE NAME       : LIN 2 LOG QUANT
%       DESCRIPTION     : Requantizes a signal using a logarithmically 
%			              spaced quantizer. Assumes int16 input signal
%			              with maximu 1024*32 and minimu -1024*32 amplitudes
%
%       X		: Input signal
%       B		: Number of Quantization Bits for log quantizer
%       seed    : Random seed for adjusting the starting quantizer level
%                 (Optional, Default=='behavior not used')
%
%RETURNED VARIABLES
%	Y		: Output Signal
%
% (C) Monty A. Escabi, July 2005
%
function [Y]=lin2logquant(X,B,seed)

%Qunatization Resolution
delta=2^(B-1)-2;                %Quantization range in integer values
MaxdB=20*log10(1024*32/1);      %Dynamic Range for + or - half of waveform
if nargin<3
    offset=0;
else
    rand('state',seed);
    offset=rand;
end

%Quantizing With Log Scale
index=find(X>0);
if length(index)>1
    Y(index)=10.^( (round(20*log10(X(index))/MaxdB*delta+offset)-offset)/delta*MaxdB/20 );
end
index=find(X<0);
if length(index)>1
    Y(index)=-10.^( (round(20*log10(abs(X(index)))/MaxdB*delta-offset)+offset)/delta*MaxdB/20 );
end
index=find(X==0);
if length(index)>1
	Y(index)=0;
end