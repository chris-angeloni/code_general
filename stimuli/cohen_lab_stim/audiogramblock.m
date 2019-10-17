%
% function []=audiogramblock(OutFileHeader,data,Fs,dX,f1,fN,Fm,OF,TB,Norm,dis,ATT)
%	
%	FILE NAME 	: AUDIOGRAM BLOCK
%	DESCRIPTION : Takes sound specified by SoundFileName
%                 and computes the audiogram in blocks of TB seconds. Saves
%                 the output to a file.
%
%   OutFileHeader   : Output File Header
%	data            : Input data
%	Fs              : Sampling Rate
%	dX              : Spectral separation betwen adjacent filters in octaves
%                     Usually a fraction of an octave ~ 1/8 would allow 
%                     for a spectral envelope resolution of up to 4 
%                     cycles per octave
%                     Note that X=log2(f/f1) as defined for the ripple 
%                     representation 
%	f1              : Lower frequency to compute spectral decomposition
%	fN              : Upper freqeuncy to compute spectral decomposition
%	Fm              : Maximum Modulation frequency allowed for temporal
%                     envelope at each band. If Fm==inf full range of Fm is used.
%	OF              : Oversampling Factor for temporal envelope
%                     Since the maximum frequency of the envelope is 
%                     Fm, the Nyquist Frequency is 2*Fm
%                     The Frequency used to sample the envelope is 
%                     2*Fm*OF
%  TB               : Analysis Block Size (sec)
%  Norm             : Amplitude normalization (Optional)
%                     En:  Equal Energy (Default)
%                     Amp: Equal Amplitude
%	dis             : display (optional): 'log' or 'lin' or 'n'
%                     Default == 'n'
%	ATT             : Attenution / Sidelobe error in dB (Optional)
%                     Default == 60 dB

% (C) Monty A. Escabi, September 2015 
%
function []=audiogramblock(OutFileHeader,data,Fs,dX,f1,fN,Fm,OF,TB,Norm,dis,ATT)

%Input Parameters
if nargin<10
    Norm='En';
end
if nargin<11
	dis='n';
end
if nargin<12
	ATT=60;
end

NB=Fs*TB;    %Block size in samples
count=1;
while count*NB<size(data,1)
    %Computing Audiogram for each Block
    [AudData]=audiogram(data((count-1)*NB+1:count*NB,:),Fs,dX,f1,fN,Fm,OF,Norm,dis,ATT);
    eval(['AudData' int2str(count) '=AudData;'])
    
    %Saving Data 
    if count==1
        save ([OutFileHeader '_AGram'],['AudData' int2str(count)]);
    else
        save ([OutFileHeader '_AGram'],['AudData' int2str(count)],'-append');
    end
    count=count+1;
end
LB=count-1; %LB is the number of blocks
save([OutFileHeader '_AGram'],'LB','-append');

