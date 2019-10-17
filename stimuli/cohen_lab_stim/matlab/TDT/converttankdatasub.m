%
%function []=converttankdatasub(Data)
%
%       FILE NAME   : CONVERT TANK DATA SUB
%       DESCRIPTION : Subroutine for CONVERTTANKDATA. The routing
%                     essentially reads data from a tank using an external matlab
%                     sessions and saves data to a file. A separate session
%                     is opened and close for execution in order to avoid
%                     memory allocation problems
%
%       Data        : Data structure containing recording information. All
%                     information is present except the variables obtained
%                     from READTANK. Variables from READTANK will be
%                     appended to data structure.
%
%RETURNED VALUE
%       
% (C) Monty A. Escabi, December 2010
%
function []=converttankdatasub(Data)

%Reading Data
DataTemp=Data;
[Data] = readtankcontv66(DataTemp.TankFileName,DataTemp.BlockNumber,DataTemp.ChannelNumber,'Local');

%Contatinating Data From READTANKCONT
Data.AnimalNumber=DataTemp.AnimalNumber;
Data.TankFileName=DataTemp.TankFileName;
Data.Date=DataTemp.Date;
Data.Time=DataTemp.Time;
Data.Tank=DataTemp.Tank;
Data.BlockNumber=DataTemp.BlockNumber;
Data.ChannelNumber=DataTemp.ChannelNumber;
Data.SiteNumber=DataTemp.SiteNumber;
Data.Sound=DataTemp.Sound;
Data.Status=DataTemp.Status;
Data.ATT=DataTemp.ATT;
Data.Sort=DataTemp.Sort;
Data.CF=DataTemp.CF;
Data.Notes=DataTemp.Notes;
Data.Depth=DataTemp.Depth;
Data.AP=DataTemp.AP;
Data.ML=DataTemp.ML;

%Displaying 
clc
disp('Reading Data')
disp(setstr(10))
disp(['Tank: ' Data.TankFileName])
disp(['Block: ' num2str(Data.BlockNumber)])
disp(['Channel: ' num2str(Data.ChannelNumber)])

%Save Data to File
Month=datestr(Data.Date,'mmm');
OutFile=['Data' Data.AnimalNumber 'Site' int2strconvert(Data.SiteNumber,4) Month 'Tank' num2str(Data.Tank) 'Block' num2str(Data.BlockNumber)];
save(OutFile,'Data');