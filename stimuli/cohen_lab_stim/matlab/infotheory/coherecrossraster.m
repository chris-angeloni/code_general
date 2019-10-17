%
%function [F,C12,C12S,df]=coherecrossraster(RASTER1,RASTER2,Fsd,df)
%
%       FILE NAME       : COHERE CROSS RASTER
%       DESCRIPTION     : Computes the cross coherence from two N trial 
%                         RASTERGRAM using coherence measurement between trials
%
%       RASTER1         : Rastergram 1 - ISI compressed format
%       RASTER2         : Rastergram 2 - ISI compressed format
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
function [F,C12,C12S,df]=coherecrossraster(RASTER1,RASTER2,Fsd,df)

%Initializing Coherence Array
Fs=RASTER1(1).Fs;
[F,C]=coherespike(RASTER1(1).spet,RASTER2(1).spet,Fs,Fsd,df,0.5,'n');
C12=zeros(size(C));
C12S=zeros(size(C));

%Computing Coherence
count=0;
for k=1:length(RASTER1)
	for l=1:length(RASTER2)

    %Percent Done
    clc
    disp(['Percent Done=' num2str(k*l/length(RASTER1)/length(RASTER2)*100) ' %'])

    %Defining ISI arrays
	spetA=RASTER1(k).spet;
	spetB=RASTER2(l).spet;

	%Computing Coherence for Original and Shifted Data
	[F,C]=coherespike(spetA,spetB,Fs,Fsd,df,0.5,'n');

	%Computing Spike Shuffled Coherence
	[F,CS]=coherespike(shiftspet(spetA,Fs,RASTER1(1).T/4),spetB,Fs,Fsd,df,0.5,'n');
   
	%Averaging the total coherence
	C12=C+C12;
	C12S=CS+C12S;

    %Number of Averages
    count=count+1;
    
	end
end
C12=C12/count;
C12S=C12S/count;