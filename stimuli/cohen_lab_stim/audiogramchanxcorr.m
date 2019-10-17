%
%function [XCorrData]=audiogramchanxcorr(AudData,MaxLag,GDelay)
%	
%	FILE NAME 	: AUDIOGRAM CHAN XCORR
%	DESCRIPTION : Computes the audiogram channel normalized crosscorrelation.
%
%	AudData : Output data structure from audiogram.m
%   MaxLag  : Maximum lag for xcorrelation (msec)
%   GDelay  : Remove group delay of filters prior to computing correlation 
%             (Optional, 'y' or 'n': Default=='n')
%
%RETURNED VARIABLES
%   XCorrData   : Data structure containing xcorrelation data
%     .XCorrMap : Crosscorreleation map
%     .faxis    : Frequency Axis
%     .delay    : Crosscorrelation delay in msec
%
% (C) Monty A. Escabi, July 2015
%
function [XCorrData]=audiogramchanxcorr(AudData,MaxLag,GDelay)

%Input Parameters
if nargin<3
    GDelay='n';
end

%Removing Group Delay if Desired
if strcmp(GDelay,'y')    %Corrected audiogram is stored in 'data'
    S=AudData.Sc;
else
    S=AudData.S;
end

%Converting MaxLag to sample numbers
Fs=1/(AudData.taxis(2)-AudData.taxis(1));
N=ceil(MaxLag/1000*Fs);

%Computing Across channel crosscorrelation
for k=1:size(S,1)
    for l=1:size(S,1)
        R=xcorr(S(k,:)-mean(S(k,:)),S(l,:)-mean(S(l,:)),N)/sqrt(var(S(k,:))*var(S(l,:)));
        XCorrMap(k,l,:)=R;
    end
end

%Adding to data structure
XCorrData.XCorrMap=XCorrMap;
XCorrData.faxis=AudData.faxis;
XCorrData.delay=(-N:N)/Fs*1000;