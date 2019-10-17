%
% function [FTC] = ftcgenerateecog(Data,T1,T2,ch,DFECoG,f1,f2,SPLoffset,shuffle)
%
%	FILE NAME 	: FTC GENERATE ECOG
%	DESCRIPTION : Generates a frequency tunning curve on the TDT system
%                 using ECoG Data
%
%	Data        : Data structure obtained using "READTANKSTIM"
%                 Data is formated as follows:
%
%                   Data.Snips              - Snipet Waveforms
%                   Data.Fs                 - Sampling Rate
%                   Data.SnipsTimeStamp     - Snipet Time Stamps
%                   Data.SortCode           - Sort Code for the Snipets
%                   Data.ChannelNumber      - Channel Number for the Snipets
%                   Data.Trig               - Trigger Event Times
%                   Data.Attenuation        - Event Attenuation Level
%                   Data.Frequency          - Event Frequency 
%                   Data.StimOff            - Stimulus Offset Time
%                   Data.StimOn             - Stimulus Onset Time
%                   Data.EventTimeStanp     - Event Time Stamp
%                   
%   T1          : FTC window start time (msec)
%   T2          : FTC window end time (msec)
%   ch          : ECoG Channel number
%   DFECoG      : Downsampling factor for ECoG
%   f1, f2      : Upper and lower cutoff frequencies for data (Hz)
%                 (Optional, Default == 1-250 Hz)
%                 If f1==0 & f2==inf then no filtering is performed
%   SPLoffset   : SPL offset to convert ATT to true SPL (dB). Default == 0.
%   shuffle     : Shuffles/randomizing the phase spectrum - used for
%                 significance testing
%
% RETURNED DATA
%
%	FTC	        : Tunning Curve Data Structure
%
%                   FTC.Freq                - Frequency Axis (M elements)
%                   FTC.Level               - Sound Level Axis (dB, N elements)
%                   FTC.Ravg                - Matrix containgin average
%                                             responses (M x N x L). L is
%                                             the number of time samples.
%                   FTC.Rtrial              - Multidimensional matrix
%                                             containing the trial
%                                             responses (MxN X L X NFTC)
%                   FTC.Rpp                 - Response peak-to-peak
%                   FTC.pc1                 - First principle component
%                   FTC.pc2                 - Second principle component
%                   FTC.pc1v                - First principle component
%                                             vecotrs 
%                   FTC.pc2v                - Second principle component
%                                             vectors
%                   FTC.NFTC                - Number of FTC repeats
%                   FTC.T1                  - FTC Window start time
%                   FTC.T2                  - FTC Window end time
%
%   (C) Monty A. Escabi, Jan 2012
%
function [FTC] = ftcgenerateecog(Data,T1,T2,ch,DFECoG,f1,f2,SPLoffset,shuffle)

%Input Args
if nargin<6
    f1=1;
end
if nargin<7
    f2=250;
end
if nargin<8
    SPLoffset=0;
end
if nargin<9
    shuffle='n';
end

%Removing Junk Data
index=find(Data.Attenuation>-500);
Data.Attenuation=Data.Attenuation(index);
Data.Frequency=Data.Frequency(index);
Data.EventTimeStamp=Data.EventTimeStamp(index);

%Some Definitions
EventTS=[Data.EventTimeStamp max(Data.EventTimeStamp)+mean(diff(Data.EventTimeStamp))];
FsECoG=Data.Fs/DFECoG;

%Filtering ECoG
X=Data.ECoGContWave(ch).X;
if f1~=0 | ~isinf(f2)
    H=bandpass(f1,f2,2,FsECoG,60,'n');
    N=(length(H)-1)/2;
    X=conv(X,H);
    X=X(N+1:length(X)-N);
    X(1:N)=fliplr(X(N+1:2*N));                    %Removing Edge Artifact
    X(end-(0:N-1))=fliplr(X(end-(N:2*N-1)));      %Removing Edge Artifact
end
if strcmp(shuffle,'y')                        %Shuffling Phase Spectrum, used for significance analysis
	X=randphasespec(X);
end
%X=abs(hilbert(X));                            %Extracting the response envelope within [f1 f2]

%Generate Frequency Axis
Freq=sort(Data.Frequency);
index=[1 1+find(diff(Freq)>0)];
FTC.Freq=Freq(index);    
clear Freq

%Generate SPL Axis
Level=sort(Data.Attenuation);
index=[1 1+find(diff(Level)>0)];
FTC.Level=Level(index);
NFTC=round(length(Level)/length(FTC.Level)/length(FTC.Freq));   %Number of Tunning Curve Repeats
clear Level

%Generating Tuning Curve Matrix
for k=1:length(FTC.Freq)
    for l=1:length(FTC.Level)
            
            index=find(Data.Frequency==FTC.Freq(k) & Data.Attenuation==FTC.Level(l));
            for m=1:length(index)
                %Finding Response Interval
                N1=round((Data.EventTimeStamp(index(m))+T1/1000)*FsECoG);
                N2=round((Data.EventTimeStamp(index(m))+T2/1000)*FsECoG);
                
                %Extracting Data
                if ~isfield(FTC,'Rtrial')
                    FTC.Rtrial=zeros(length(FTC.Freq),length(FTC.Level),NFTC,length(N1:N2));
                end
                FTC.Rtrial(k,l,m,:)=X(N1+1:N1+size(FTC.Rtrial,4));
            end
            FTC.Ravg(k,l,:)=squeeze(mean(FTC.Rtrial(k,l,:,:),3));
            

            %Extracting Data
            [pc,pcv]=pca(squeeze(FTC.Rtrial(k,l,:,:)),2);
            FTC.Rmax(k,l)=max(FTC.Ravg(k,l,:));
            FTC.Rpp(k,l)=max(FTC.Ravg(k,l,:)) - min(FTC.Ravg(k,l,:));
            FTC.pc1(k,l)=pc(1);
            FTC.pc2(k,l)=pc(2);
            FTC.pcv1(k,l,:)=pcv(:,1)';
            FTC.pcv2(k,l,:)=pcv(:,2)';            
            FTC.taxis=(0:size(FTC.Ravg,3)-1)/FsECoG;
            FTC.FsECoG=FsECoG;
    end
end