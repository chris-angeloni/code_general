%function [DataArtifact] = electricalstimartifactremoval(Data,filename,Na,f1,f2,TW)
%
%	FILE NAME 	: Read Tank Stim
%	DESCRIPTION : Reads a specific block from a data tank file for
%                 electrical stimulation
%
%	Data            : Data Structure containing all relevant data. See READTANKSTIM
%                     for details
%   filename        : File name header containing the directory and
%                     filename header ending in string 'Block'. The block
%                     numbers are added automatically by the program.
%   f1              : Lower cutoff frequency (in Hz)
%   f2              : Upper cutoff frequency (in Hz)
%   TW              : Transition width (in Hz)
%   ECoGChanNumber  : ECoG Channel Vector (Default == 0, i.e. 
%                     "AllChannels", assumes 32 channels )
%   ServerName      : Tank Server (Default=='Puente')
%
% RETURNED DATA
%
%
% (C) Monty A. Escabi, Edit Dec 2011
%
function [DataArtifact] = electricalstimartifactremoval(Data,filename,Na,f1,f2,TW)

%Extracting data
X=reshape(Data.ContWave,1,numel(Data.ContWave));

%Bandpass filter output
[Hband] = bandpass(f1,f2,TW,Data.Fs,40,'y');
X=conv(X,Hband);
Nb=(length(Hband)-1)/2;
X=X(Nb+1:end-Nb);

%Selecting data during electrical stimulation
N1=round(Data.ElectricalStimTrig(1)*Data.Fs);
N2=round(Data.ElectricalStimTrig(end)*Data.Fs);
X=X(N1:N2-1);

%Loading electrical input
load([filename '000' int2str(1) '.mat'])
M=ParamList.NB/4;   %1/4 of a block, each channel receives input for this duration
Fs = Data.Fs;

%Reorganizing electrical input data and removing pulse waveform
Mask=[-1 -1 1 1]/4; %used to find pulses and replace with delta
for k=1:8
    load([filename '000' int2str(k) '.mat'])
    for l=1:2
       chan=l+(k-1)*2;
       
       N1=(l-1)*M+1;
       N2=(l)*M;
       i=find(conv(Mask,full(S(chan,N1:N2)))==1)-3; %Find time of pulses
       Sa(chan,:)=spet2impulse(i,Fs,Fs,M/Fs)/Fs;    %Replace with delta
    end
end

%Detect edge effects
edge = zeros(16,1);
for k = 1:16
    pulses = find(Sa(k,131050:end));
    if isempty(pulses)
        edge(k,:) = 0;
    else
        edge(k,:) = 1;
    end     
end
Sa=full(Sa);

%Reshape neural respons so that it matches electrical input format
N1=round(Data.ElectricalStimTrig(1)*Data.Fs);
N2=round(Data.ElectricalStimTrig(end)*Data.Fs);
Xa=reshape(X,(N2-N1)/16,16)';

%Finding Artifact Prediction Filters
dt=1/Data.Fs;
for k=1:16
    [H] = wienerfft(Sa(k,:),Xa(k,:),5,Na);
    Ha(k,:)=H;
end

%Predicting the artifact
delay = round(Na/2);
Ynext = zeros(1,delay);
Ya = zeros(size(Xa));
for k=1:16
     Y=conv(Ha(k,:),Sa(k,:));
     Ya(k,:)=Y(1:length(Xa(k,:)));
     Ya(k,1:delay) = Ya(k,1:delay)+Ynext; %add edge effect from previous channel
     Ynext = Y(length(Xa(k)):delay);
     if edge(k) == 1
         Ynext = Ynext+Y(length(Xa)+1:length(Xa)+delay);
     end
end

%Subtracting the artifacts
for k=1:16
    Xclean(k,:)=Xa(k,:)-Ya(k,:);
end

%Organizing Results Into Data Structure
DataArtifact.X=X;
DataArtifact.Xa=Xa;
DataArtifact.Ya=Ya;
DataArtifact.Xclean=Xclean;
DataArtifact.Sa=Sa;
DataArtifact.Fs=Data.Fs;