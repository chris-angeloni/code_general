%
%function [R]=jitterschreiber(spetA,spetB,T,sigma,Fs,Fsd)
%
%   FILE NAME   : JITTER SCHREIBER
%   DESCRIPTION : Finds the reliability of a rastergram using the
%                 correlation metric of Schreiber et al.
%
%   spetA,spetB : Spike event times array for trial A and B
%   T           : Recording Duration (sec)
%   sigma       : Vector of smooting resolutions (msec)
%   Fs          : Sampling rate (Hz)
%   Fsd         : Desired sampling rate for analysis (Hz)
%
%Returned Variables
%
%       R       : Reliability
%
% (C) Monty A. Escabi, Nov 2010
%
function [R]=jitterschreiber(spetA,spetB,T,sigma,Fs,Fsd)

%Converting Spets to RASTER format
RASTER(1).spet=spetA;
RASTER(1).Fs=Fs;
RASTER(1).T=T;
RASTER(2).spet=spetB;
RASTER(2).Fs=Fs;
RASTER(2).T=T;

%Computing Schreiber Reliability
[R]=jitterrasterschreiber(RASTER,sigma,Fsd);