%
%function [] = readtankcont2raw(Filename)
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

%Saving Continuous Waveform to File
i=strfind(Filename,'.mat');
Header=Filename(1:i-1);
fid=fopen([Header 'Temp.raw']);
SF=1024*16/0.025;                   %0.025 is the maximum voltage (25 mV) and 1024*16 is the maximum value for signed int (int16)
fwrite(fid,Data.ContWave*SF,'int16');
fclose(fid);

%Filtering Data and Saving to File
TW=0.25*f1;
ATT=60;
Fs=Data.FsCont;
M=1024*128;
FiltGain=1;
ftype='int16';
filtfile([Header 'Temp.raw'],[Header 'raw'],f1,f2,TW,ATT,Fs,M,FiltGain,ftype);

%Delete Temporary Files
eval(['!rm ' Header 'Temp.raw']);
fclose all
