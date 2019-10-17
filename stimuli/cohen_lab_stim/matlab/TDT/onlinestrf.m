%
% function [] = onlinestrf(TankFileName,BlockNumber,SprFile,Servername)
%
%	FILE NAME 	: ONLINE STRF
%	DESCRIPTION : Computes STRF and Plots Results
%
%	TankFileName	: Data Tank File Name
%	BlockNumber     : Block Number
%   SPRFile         : SPR Sond File
%
function [] = onlinestrf(TankFileName,BlockNumber,Sprfile,Servername)

%Reading Tank Data
[Data] = readtank(TankFileName,BlockNumber,Servername);

%Converting Spikes to Samples
%N=max(Data.SortCode)+1;
spet=round(Data.SnipTimeStamp*Data.Fs);

%Converting Trigs to Samples and Fixing
NTrig=1799  %???????
Fs=Data.Fs;

TrigTimes=round(Data.Trig*Data.Fs);
%[TrigA,TrigB]=trigfixstrf2(TrigTimes,400,NTrig)
[Trig]=trigfixstrf(TrigTimes,400,NTrig);

rtwstrfdb('movingrippleratctx.spr',.1,.1,spet,Trig,Fs,80,45,'dB','MR',50,'float')




