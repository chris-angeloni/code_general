%
%function [RAS] = rastertimetrial2spet(RASTER,Fsd,T)
%
%   FILE NAME   : RASTER CONVERT
%   DESCRIPTION : Converts a RASTER Time vs. Trial arrays data
%                 structure to a compressed spet RASTER data structure
%
%   RASTER      : RASTER Data Sructure
%                 .Time   - Spike time array (msec)
%                 .Trial  - Trial number array
%   Fsd         : Desired sampling rate for SPET (Hz)
%   T           : Total Trial Duration (sec)
%                 (if T is a vector assings the corresponding values for
%                 each trial separately)
%
% RETURNED DATA
%
%   RAS         : Raster data structure
%                 .spet: spike event time 
%                 .Fs: sampling rate
%                 .T: Trial duration in seconds
%
% (C) Monty A. Escabi, September 2006
%
function [RAS] = rastertimetrial2spet(RASTER,Fsd,Ntrial)

if isempty(RASTER.time)
    RAS = []
end

%Number of Trials
if nargin<3
Ntrial=max(RASTER.trial);
end

%Duration
% if length(T)==1
%     T=T*ones(1,N);
% end

%Generating RASTER
for k=1:Ntrial
    index=find(RASTER.trial==k);
    RAS(k).spet=round(RASTER.time(index)*Fsd);
    RAS(k).Fs=Fsd;
    % RAS(k).T=T(k);
end