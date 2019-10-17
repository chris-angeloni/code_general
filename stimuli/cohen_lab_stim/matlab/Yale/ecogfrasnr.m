% function [SNRData]=ecogfrasnr(FTC,Fs)
%	
%	FILE NAME 	: ECOG FRA SNR
%	DESCRIPTION : Computes the SNR for all ECOG electrode channels using
%                 FRA data structure. SNR is computed at the loudest SPL.
%
%	FTCn        : FRA Data structrue matrix containg the FRAs for each
%                 electrode channel
%   Fs          : Sampling rate for ECoG signals (Optional)
%
%RETURNED VARIABLES
%   SNRData     : Data structure matrix containing SNR measurements
%                 .SNR   - Signal to noise ratio in dB
%                 .Pss   - Signal power spectrum
%                 .Pnn   - Noise power spectrum
%                 .Faxis - Frequency axis for SNR, Pnn, Pss
%                 .Fs    - Sampling rate (Hz)
%
% (C) Monty A. Escabi, Jun 2013 (Edit May 2014)
%
function [SNRData]=ecogfrasnr(FTC,Fs)

%Computing SNR for all channels
for i=1:size(FTC,1)
    for j=1:size(FTC,2)

        %Displaying Progress
        clc
        disp(['Computing SNR Channel: ' num2str(j+(i-1)*size(FTC,1)) ' of ' num2str(numel(FTC)) ])
        
        %Selecting data for a given electrode channel
        Rtrial=FTC(i,j).Rtrial;
        Ravg=FTC(i,j).Ravg;
        
        %Computing Noise Spectrum
        Snoise=[];
        for k=1:size(Rtrial,1)
            for l=1:size(Rtrial,3)
                Snoise=[Snoise ;squeeze(Rtrial(k,1,l,:))'];
            end
        end
        Pnn=mean(abs(fft(Snoise,[],2)).^2,1);

        %Computing signal spectrum using shuffled CSD
        Pssk=[];
        for k=1:size(Rtrial,1)
            Pss=[];
            for l=1:size(Rtrial,3)
                for m=1:size(Rtrial,3)
                    if m~=l
                        N=size(Rtrial,2);           %Computes SNR at the loudest SPL
                        Sl=squeeze(Rtrial(k,N,l,:))';
                        Sm=squeeze(Rtrial(k,N,m,:))';
                        Pss=[Pss;abs(fft(Sl).*conj(fft(Sm)))];
                    end
                end
            end
            Pssk=[Pssk;mean(Pss,1)];
        end

        %Computing SNR,Pss, and Pnn
        SNRData(i,j).SNR=10*log10(mean(Pssk)./Pnn);
        SNRData(i,j).Pss=mean(Pssk);
        SNRData(i,j).Pnn=Pnn;

        if nargin==2
            SNRData(i,j).Faxis=(0:length(Pnn)-1)/length(Pnn)*Fs;
            SNRData(i,j).Fs=Fs;
        end
        
    end
end