%
%function [F,Pxy,PxyS,df]=psdrasterboot(RASTER,Fsd,df)
%
%       FILE NAME       : PSD RASTER
%       DESCRIPTION     : Computes the across trial cross spectral density
%                         from an N RASTERGRAM using PSD between trials.
%                         Bootstrap resamples the data in order to estimate
%                         the varaince of the estimate
%
%       RASTER          : Rastergram - ISI compressed format
%       Fsd             : Sampling rate for generating Coherence
%       df              : Minimum desired frequency resoultion for coherence
%           	          measurement
%       dc              : Remove DC (mean) component prior to estimating PSD
%                         'y' or 'n' (Default=='n')
%
%Returned Variables
%       F               : Frequency Array
%       Pxx             : Spike Train PSD Bootstrap Resampled Data
%       PxxS            : Spike Shuffled PSD - Bias Removal
%       df              : Actual Spectral Resolution (Hz)
%
%   (C) Monty A. Escabi, July 2006
%
function [F,Pxx,PxxS,df]=psdrasterboot(RASTER,Fsd,df,dc)

%Initializing PSD Array
Fs=RASTER(1).Fs;
[F,C]=psdspike(RASTER(1).spet,Fs,Fsd,df,0.01,0.5,'n');
Pxx=zeros(size(C'));
PxxS=zeros(size(C'));

%Computing PSD
count=0;
for k=1:length(RASTER)

    %Percent Done
    clc
    disp(['Percent Done=' num2str(k/length(RASTER)*100) ' %'])

    %Defining ISI arrays
	spet=RASTER(k).spet;

	%Computing PSD for Original and Shifted Data
	[F,P]=psdspike(spet,Fs,Fsd,df,0.01,0.5,'n','n');

	%Computing Spike Shuffled PSD
	[F,PS]=psdspike(shiftspet(spet,Fs,RASTER(1).T/4),Fs,Fsd,df,0.01,0.5,'n','n');
  
    %Generating the PSD for each across trial measurement
	Pxx=[Pxx;P'];
	PxxS=[PxxS;PS'];

end