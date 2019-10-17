%
%function [] = readtankcont2raw(Filename,f1,f2)
%
%	FILE NAME 	: READ TANK CONT 2 RAW
%	DESCRIPTION : Reads a specific block from a data tank file and saves
%                 the data to a file
%
%   Filename    : Filename of file containing data from
%                 READTANKCONTSAVE
%   f1          : Bandpass filter lower cutoff (Hz)
%   f2          : Bandpass filter upper cutoff (Hz)
%
% RETURNED DATA
%
% (C) Monty A. Escabi, October 2016
%
function [] = readtankcont2raw(Filename,f1,f2)

%Loading Data
load(Filename);

%Opening File
i=strfind(Filename,'.mat');
Header=Filename(1:i-1);
fid=fopen([Header 'Temp.fl'],'wb');

%Saving Continuous Waveform to File
NB=1024*128;        %Block Size
L=floor(length(Data.ContWave)/NB);  %Number of saved blocks
for k=1:L
    fwrite(fid,Data.ContWave((k-1)*NB+1:k*NB),'float');
end
fwrite(fid,Data.ContWave(L*NB+1:end),'float');
fclose(fid);

%Filtering Data and Saving to File
TW=0.25*f1;
ATT=60;
Fs=Data.FsCont;
M=1024*128;
FiltGain=1;
ftype='float';
filtfile([Header 'Temp.fl'],[Header '.fl'],f1,f2,TW,ATT,Fs,M,FiltGain,ftype);

%Convert from Float to Int16
float2int([Header '.fl'],[Header '.raw'],M);

%Delete Temporary Files
if isunix
    eval(['!rm ' Header 'Temp.fl']);
    eval(['!rm ' Header '.fl']);
else 
    eval(['!del ' Header '.fl']);
    eval(['!del ' Header 'Temp.fl']);
end
fclose all;