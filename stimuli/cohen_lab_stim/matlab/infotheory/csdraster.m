%
%function [F,Pxy,PxyS,df]=csdraster(RASTER,Fsd,df)
%
%       FILE NAME       : CSD RASTER
%       DESCRIPTION     : Computes the across trial cross spectral density
%                         from an N RASTERGRAM using CSD between trials
%
%       RASTER          : Rastergram - ISI compressed format
%       Fsd             : Sampling rate for generating Coherence
%       df              : Minimum desired frequency resoultion for coherence
%           	          measurement
%
%Returned Variables
%       F               : Frequency Array
%       Pxy             : Spike Train CSD
%       PxyS            : Spike Shuffled CSD - Bias Removal
%       df              : Actual Spectral Resolution (Hz)
%
%   (C) Monty A. Escabi, July 2006
%
function [F,Pxy,PxyS,df]=csdraster(RASTER,Fsd,df)

%Initializing CSD Array
Fs=RASTER(1).Fs;
[F,C]=csdspike(1,1,Fs,Fsd,df,RASTER(1).T,0.01,0.5,'n','n');
Pxy=zeros(size(C));
PxyS=zeros(size(C));

%Computing CSD
count=0;
for k=1:length(RASTER)
	for l=1:k-1

    %Percent Done
    clc
    disp(['Percent Done=' num2str(k/length(RASTER)*100) ' %'])

    %Defining ISI arrays
	spetA=RASTER(k).spet;
	spetB=RASTER(l).spet;

    if ~isempty(spetA) & ~isempty(spetB)
    
        %Computing CSD for Original and Shifted Data
    	[F,P]=csdspike(spetA,spetB,Fs,Fsd,df,RASTER(1).T,0.01,0.5,'n','n');

    	%Computing Spike Shuffled CSD
    	[F,PS]=csdspike(shiftspet(spetA,Fs,0,RASTER(1).T,RASTER(1).T),spetB,Fs,Fsd,df,RASTER(1).T,0.01,0.5,'n','n');

        %Averaging the total CSD
        Pxy=P+Pxy;
        PxyS=PS+PxyS;
    
    end
    
    %Number of Averages
    count=count+1;
    
	end
end
Pxy=Pxy/count;
PxyS=PxyS/count;