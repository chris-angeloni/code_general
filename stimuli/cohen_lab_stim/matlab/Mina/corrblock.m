%
% function []=corrblock(SoundFileName,Fs,dX,f1,fN,Fm,OF,dT,Overlap,Norm)
%	
%	FILE NAME 	: CORR BLOCK
%	DESCRIPTION : Loads audiogram blocks of the sound specifiedn
%                 by SoundFileName and computes the Correlation coefficients 
%                 of each block. Saves Correlatin Blocks to a file.
%
%	SoundFileName : Input sound
%   Fs		: Sampling Rate
%	dX		: Spectral separation betwen adjacent filters in octaves
%			  Usually a fraction of an octave ~ 1/8 would allow 
%			  for a spectral envelope resolution of up to 4 
%			  cycles per octave
%			  Note that X=log2(f/f1) as defined for the ripple 
%			  representation 
%	f1		: Lower frequency to compute spectral decomposition
%	fN		: Upper freqeuncy to compute spectral decomposition
%	Fm		: Maximum Modulation frequency allowed for temporal
%			  envelope at each band. If Fm==inf full range of Fm is used.
%	OF		: Oversampling Factor for temporal envelope
%			  Since the maximum frequency of the envelope is 
%			  Fm, the Nyquist Frequency is 2*Fm
%			  The Frequency used to sample the envelope is 
%			  2*Fm*OF
%   dT      : Temporal Window (sec)
%   Overlap : Percent overlap between consecutive windows. Overlap = 0 to 1. 0 indicates no
%             overlap. 0.9 would indicate 90 % overlap. 
%   Norm    : Amplitude normalization (Optional)
%             En:  Equal Energy (Default)
%             Amp: Equal Amplitude
%
% (C) Monty A. Escabi, September 2015 
%
function []=corrblock(SoundFileName,Fs,dX,f1,fN,Fm,OF,dT,Overlap,Norm)

%Load Number of Blocka
load ([SoundFileName '_AGram'],'LB')

for count=1:LB  %LB=Number of Blocks - itterate over all blocks

    %Loading Audiogram for each Block
    load ([SoundFileName '_AGram'],['AudData' int2str(count)]);

    %Computing Correlation coefficients for each Block
    f=['AudData' int2str(count)];
    [CorrData]=audiogramdynchancorr(eval(f),Fs,dX,f1,fN,Fm,OF,dT,Overlap,Norm);
    eval(['CorrData' int2str(count) '=CorrData;']);
    
    %Saving Data
    if count==1
        save ([SoundFileName '_Corr'],['CorrData' int2str(count)]);
    else
        save ([SoundFileName '_Corr'],['CorrData' int2str(count)],'-append');
    end

end
save([SoundFileName '_Corr'],'LB','-append'); %LB is the number of blocks