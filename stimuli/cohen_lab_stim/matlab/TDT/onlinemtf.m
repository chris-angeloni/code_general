%
% function [] = onlinemtf(TankFileName,BlockNumber,ParamFile,TD,ChannelNumber,ServerName)
%
%	FILE NAME 	:   ONLINE MTF
%	DESCRIPTION :   Computes a modulation transfer function
%
%	TankFileName	: Data Tank File Name
%	BlockNumber     : Block Number
%   ParamFile       : Stimulus Parameter File
%   TD              : Total stimulus duration (sec)
%   ChannelNumber   : Channel Number (Default == 1)
%   ServerName      : Tank Server Name (Default=='Puente')
%
%   (C) Monty Escabi 2004
%
function [] = onlinemtf(TankFileName,BlockNumber,ParamFile,TD,ChannelNumber,ServerName)

%Default Tank Serve, Channel etc
if nargin<5
    ChannelNumber=1;
end
if nargin<6
    ServerName='Puente';
end

%Loading Param File
f=['load ' ParamFile];
eval(f);

%Reading Tank Data File
[Data] = readtank(TankFileName,BlockNumber,ChannelNumber,ServerName);

%Plotting Rate and VS MTF
clf
N=max(Data.SortCode)+1;
for k=0:N-1
    
    %Generating MTF
    [MTF] = mtfgenerate(Data,FM,TD,0,k);
   
    %Plotting MTF
    subplot(2,2,k+1)
    semilogx(MTF.FMAxis,MTF.Rate,'k')
    axis([1 100 0 max(MTF.Rate)*1.2])
    hold on
    semilogx(MTF.FMAxis,MTF.VS*max(MTF.Rate)*1.2,'k-.')
    xlabel('Modulation Rate (Hz)')
    ylabel('Rate / VS')
    
end