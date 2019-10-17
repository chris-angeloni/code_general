%
%function [D]=sdmpsthg(RASTER1,RASTER2,Fsd,fc,BW,P)
%
%       FILE NAME       : SPIKE DISTANCE METRIC PSTH G
%       DESCRIPTION     : Computes the spike distance between two PSTHs.
%                         This is required to compute the D-prime between
%                         two rasters. The procedure is similar to the Van
%                         Rossum SDM except that we are computing the
%                         distance of the PSTHs (i.e., the means). Instead
%                         of filtering with a first order lowpass filter,
%                         a Gabor bandpass filter is used.
%
%       RASTER1         : RASTER containing spike even times for condition 1
%       RASTER2         : RASTER containing spike even times for condition 2
%       Fs              : Desired sampling rate (Hz)
%       fc              : Gabor fitler center frequency (Hz)
%       BW              : Gabor filter 3 dB bandwidth (Hz)
%       P               : Gabor filter phase (0-2*pi, Default==0)
%
%RETURNED VARIABLES
%
%       D               : Spike distance matrix
%
%       (C) Monty A. Escabi, March 2009
%
function [D]=sdmpsthg(RASTER1,RASTER2,Fsd,fc,BW,P)

%Input Args
if nargin<6
    P=0;
end

%Generating PSTH
Fs=RASTER1(1).Fs;
[PSTH1]=raster2psth(RASTER1,Fsd,RASTER1(1).T);
[PSTH2]=raster2psth(RASTER2,Fsd,RASTER2(1).T);

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

%Computing PSTH Difference and Smoothing with Kernel
X12=conv(PSTH2-PSTH1,G)/Fs;     %Linearity allows me to subtract first and then convolve

%Spike Distance
D=BW*sum((X12).^2)/Fs;          %Normalize by bandwidth