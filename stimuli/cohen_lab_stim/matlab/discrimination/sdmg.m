%
%function [D]=sdmg(spet1,spet2,Fs,Fsd,T,fc,BW,P)
%
%       FILE NAME       : SPIKE DISTANCE METRIC G
%       DESCRIPTION     : Computes the spike distance metric between two
%                         spike trains. Similartto Van Rossum, 1999. Instead
%                         of filtering with a first order lowpass filter,
%                         a Gabor bandpass filter is used.
%
%       spet1           : Spike even times for spike train 1
%       spet2           : Spike even times for spike train 2
%       Fs              : Sampling rate (Hz)
%       Fsd             : Desired sampling rate (Hz)
%       T               : Spike train duration (sec)
%       fc              : Gabor fitler center frequency (Hz)
%       BW              : Gabor filter 3dB bandwidth (Hz)
%       P               : Gabor filter phase (0-2*pi, Default==0)
%
%RETURNED VARIABLES
%
%       D               : Spike distance metric
%
% (C) Monty A. Escabi, July 2010
%
function [D]=sdmg(spet1,spet2,Fs,Fsd,T,fc,BW,P)

%Input Args
if nargin<8
    P=0;
end

%Generating Gabor Kernel
%
% For a gaussian function of the form 
%
%           h(t)=1/sqrt(2*pi*sigma^2)*exp(-t.^2/2/sigma^2)
%
% it can be shown that the F.T. is
%
%           H(w)=1/sqrt(2*pi)*exp(-sigma^2*w.^2/2)
%
% It can also be shown that the 3 dB bandwidht in (rad/sec) is
%
%           BW=2*sqrt(2*log(2))/sigma
%
Q=fc/BW;                                            %3 dB quality factor
sigma=sqrt(2*log(2))/BW/pi;                         %Standard deviation, note that I divide by 2*pi the above equation
time=(-ceil(sigma*Fsd*4):ceil(sigma*Fsd*4))/Fsd;    %Time Axis
G=exp(-time.^2/2/sigma^2).*cos(2*pi*fc*time+P);
%G=G/sqrt(sum(G.^2));                                %Unit L2 Norm
%G=sqrt(2*pi)/sqrt(2*pi*sigma^2)*exp(-time.^2/2/sigma^2).*cos(2*pi*fc*time+P);
%G=1/sqrt(2*pi*sigma^2)*exp(-t.^2/2/sigma^2)

%Converting SPET to impulse array
[X1]=spet2impulse(spet1,Fs,Fsd,T);
[X2]=spet2impulse(spet2,Fs,Fsd,T);

%Smoothing with kernel at resolution tc
X12=conv(X1-X2,G)/Fs;       %Linearity allows me to subtract first and then convolve

%Spike Distance
D=BW*sum((X12).^2)/Fs;      %Normalize by bandwidth