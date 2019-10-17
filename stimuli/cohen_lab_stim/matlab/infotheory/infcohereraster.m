%
%function [I,IS,Rate,F,Cab,CabS]=infcohereraster(RASTER,Fsd,df)
%
%
%       FILE NAME       : INF COHERE RASTER
%       DESCRIPTION     : Computes the mutual information from an N trial 
%                         RASTERGRAM using coherence measurement between trials
%
%       RASTER          : Rastergram - ISI compressed format
%       Fsd             : Sampling rate for generating Coherence
%       df              : Minimum desired frequency resoultion for coherence
%           	          measurement
%
%Returned Variables
%       I               : Mutual Information
%       IS              : Spike Shuffled Mutual Information - Bias Removal
%       Rate            : Spike Rate
%       F               : Frequency Array
%       Cab             : Spike Train Coherence
%       CabS            : Spike Shuffled Coherence - Bias Removal
%       df              : Actual Spectral Resolution (Hz)
%
%   (C) Monty A. Escabi, Aug. 2005
%
function [I,IS,Rate,F,Cab,CabS,df]=infcohereraster(RASTER,Fsd,df)

%Initializing Coherence Array
Fs=RASTER(1).Fs;
[F,C]=coherespike(RASTER(1).spet,RASTER(2).spet,Fs,Fsd,df,0.5,'n');
%[F,Cxy]=coherespike(spet1,spet2,Fs,Fsd,df,Overlap,Disp,W)
Cab=zeros(size(C));
CabS=zeros(size(C));

%Computing Coherence
count=0;
for k=1:length(RASTER)
	for l=1:k-1

    %Percent Done
    clc
    disp(['Percent Done=' num2str(k/length(RASTER)*100) ' %'])

    %Defining ISI arrays
	spetA=RASTER(k).spet;
	spetB=RASTER(l).spet;

	%Computing Coherence for Original and Shifted Data
	[F,C]=coherespike(spetA,spetB,Fs,Fsd,df,0.5,'n');

	%Computing Spike Shuffled Coherence
	[F,CS]=coherespike(shiftspet(spetA,Fs,RASTER(1).T/4),spetB,Fs,Fsd,df,0.5,'n');
   
	%Averaging the total coherence
	Cab=C+Cab;
	CabS=CS+CabS;

    %Number of Averages
    count=count+1;
    
	end
end
Cab=Cab/count;
CabS=CabS/count;

%Mutual Information Calculation for Original and Shifted Data
%Note that 1/2 is not needed because we are integrating from 0 to Fs/2 
df=mean(diff(F));
I=-sum(log2(1-Cab))*df;
IS=-sum(log2(1-CabS))*df;

%Firing Rate
Rate=0;
for k=1:length(RASTER)
    Rate=Rate+length(RASTER(k).spet)/RASTER(k).T/length(RASTER);
end