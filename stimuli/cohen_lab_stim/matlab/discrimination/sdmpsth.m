%
%function [D]=sdmraster(RASTER1,RASTER2,Fsd,tc)
%
%       FILE NAME       : Spike Distance PSTH
%       DESCRIPTION     : Computes the spike distance between two PSTHs.
%                         This is required to compute the D-prime between
%                         two rasters. The procedure is similar to the Van
%                         Rossum SDM except that we are computing the
%                         distance of the PSTHs (i.e., the means)
%
%       RASTER1         : RASTER containing spike even times for condition 1
%       RASTER2         : RASTER containing spike even times for condition 2
%       Fs              : Desired sampling rate (Hz)
%       tc              : Time constant (msec)
%
%RETURNED VARIABLES
%
%       D               : Spike distance matrix
%
%       (C) Monty A. Escabi, March 2009
%
function [D]=sdmpsth(RASTER1,RASTER2,Fsd,tc)

%Generating PSTH
Fs=RASTER1(1).Fs;
[PSTH1]=raster2psth(RASTER1,Fsd,RASTER1(1).T);
[PSTH2]=raster2psth(RASTER2,Fsd,RASTER2(1).T);

%Generating Kernel
tc=tc/1000;
time=(0:tc*Fsd*5)/Fsd;
G=exp(-time/tc);

% plot(conv(G,PSTH1))
% hold on
% plot(conv(G,PSTH2),'r')
% ylim([0 8000])
% hold off
% pause
%

%Computing PSTH Difference and Smoothing with Kernel
X12=conv(PSTH2-PSTH1,G)/Fs;     %Linearity allows me to subtract first and then convolve

%Spike Distance
D=1/tc*sum((X12).^2)/Fs;