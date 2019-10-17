%
%function [RASm]=jittermodelcyclerasteroptim(RASTER,Fm,M,L)
%
%   FILE NAME   : JITTER MODEL CYCLE RASTER OPTIM
%   DESCRIPTION : Fits the periodic model spike train of Zheng & Escabi to
%                 a periodic dot raster and generates a model cycle dot
%                 rastergram. The routined first computes the shuffled
%                 autocorrelogram of the data and fits the model to find
%                 the model parameters. A cycle dot raster is then
%                 generated using a model spike train with the measured
%                 parameters. 
%
%   RASTER      : Dot raster (spet format)
%   Fm          : Modulation frequency (Hz)
%   M           : Number of trials for model cycle raster
%   T           : Amount of time to remove at begning of file to avoid
%                 adaptation effects (sec). Rounds off to assure that a
%                 intiger number of cycles are removed. (Optional,
%                 Default=0)
%   L           : Number of samples per cycle used to generate shuffled
%                 autocorrelogram (Optional, Default=50)
%
%Returned Variables
%
%	RASm    : Model Cycle Rastergram
%
% (C) Monty A. Escabi, Dec. 2012
%
function [RASm]=jittermodelcyclerasteroptim(RASTER,Fm,M,T,L)

%Input Args
if nargin<4
    T=0;
end
if nargin<5
    L=50;
end

%Estimating Spike Train Parameters to generate periodic spike train model
Fsd=Fm*L;
[RASTERc]=raster2cycleraster(RASTER,Fm,1,T);
[RData]=rastercircularshufcorrfast(RASTERc,Fsd,'y',1);
RData.Renv=RData.Rshuf;
RData.Fm=Fm;
[REnvParam]=circularshufcorrenvparam(RData);

%Generating Model Dot-Raster
Fs=RASTER(1).Fs;
spet=round(Fs*1/Fm*(1:4));  %4 Periods - 1, 3, and 4 are subsequently removed to avoid edge artifacts
[RASm]=jitterraster(spet,REnvParam.sigma,REnvParam.xhat,REnvParam.lambdaDC,Fs,Fs,M);
for k=1:length(RASm);
    index=find(RASm(k).spet/Fs>=3/2/Fm & RASm(k).spet/Fs<5/2/Fm);
    RASm(k).spet=round(RASm(k).spet(index)-3/2/Fm*Fs)+1;
    RASm(k).T=1/Fm;
end