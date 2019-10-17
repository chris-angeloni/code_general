%
%function [F,Pxx,PxxS,df]=psdraster(RASTER,Fsd,df)
%
%       FILE NAME       : PSD RASTER
%       DESCRIPTION     : Computes the across trial cross spectral density
%                         from an N RASTERGRAM using PSD between trials
%
%       RASTER          : Rastergram - ISI compressed format
%       Fsd             : Sampling rate for generating Coherence
%       df              : Minimum desired frequency resoultion for coherence
%           	          measurement
%
%Returned Variables
%       F               : Frequency Array
%       Pxx             : Spike Train PSD
%       PxxS            : Spike Shuffled PSD - Bias Removal
%       df              : Actual Spectral Resolution (Hz)
%
%   (C) Monty A. Escabi, July 2006
%
function [F,Pxx,PxxS,df]=psdraster(RASTER,Fsd,df)

%Initializing PSD Array
Fs=RASTER(1).Fs;
[F,C]=psdspike(1,Fs,Fsd,df,RASTER(1).T,0.01,0.5,'n');
Pxx=zeros(size(C));
PxxS=zeros(size(C));

%Computing PSD
count=0;
for k=1:length(RASTER)

    %Percent Done
    clc
    disp(['Percent Done=' num2str(k/length(RASTER)*100) ' %'])

    %Defining ISI arrays
	spet=RASTER(k).spet;

    if ~isempty(spet)
        
        %Computing PSD for Original and Shifted Data
        [F,P]=psdspike(spet,Fs,Fsd,df,RASTER(1).T,0.01,0.5,'n');

        %Computing Spike Shuffled PSD
        [F,PS]=psdspike(shiftspet(spet,Fs,0,RASTER(1).T,RASTER(1).T),Fs,Fsd,df,RASTER(1).T,0.01,0.5,'n');
   
        %Averaging the total PSD
        Pxx=P+Pxx;
        PxxS=PS+PxxS;
        
    end
    
    %Number of Averages
    count=count+1;
    
end
Pxx=Pxx/count;
PxxS=PxxS/count;