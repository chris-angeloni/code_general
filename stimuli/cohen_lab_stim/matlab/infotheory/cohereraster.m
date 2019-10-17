%
%function [F,Cab,CabS,df]=cohereraster(RASTER,Fsd,df)
%
%       FILE NAME       : COHERE RASTER
%       DESCRIPTION     : Computes the across trial coherence from an N trial 
%                         RASTERGRAM using coherence measurement between trials
%
%       RASTER          : Rastergram - ISI compressed format
%       Fsd             : Sampling rate for generating Coherence
%       df              : Minimum desired frequency resoultion for coherence
%           	          measurement
%
%Returned Variables
%       F               : Frequency Array
%       Cab             : Spike Train Coherence
%       CabS            : Spike Shuffled Coherence - Bias Removal
%       df              : Actual Spectral Resolution (Hz)
%
%   (C) Monty A. Escabi, Jan 2006
%
function [F,Cab,CabS,df]=cohereraster(RASTER,Fsd,df)

%Initializing Coherence Array
Fs=RASTER(1).Fs;
[F,C]=coherespike(RASTER(1).spet,RASTER(2).spet,Fs,Fsd,df,0.5,'n');
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
	[F,CS]=coherespike(shiftspet(spetA,Fs,0,RASTER(1).T,RASTER(1).T),spetB,Fs,Fsd,df,0.5,'n');
   
	%Averaging the total coherence
	Cab=C+Cab;
	CabS=CS+CabS;

    %Number of Averages
    count=count+1;
    
	end
end
Cab=Cab/count;
CabS=CabS/count;