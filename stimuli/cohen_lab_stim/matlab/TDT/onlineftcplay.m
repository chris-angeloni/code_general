%
% function [FTC] = onlineftcplay(TankFileName,BlockNumber,T1,T2,ChannelNumber,ServerName)
%
%	FILE NAME 	: ONLINE FTC PLAY
%	DESCRIPTION : Computes Tunning Curve Online and Plots Results
%
%	TankFileName	: Data Tank File Name
%	BlockNumber     : Block Number
%   T1              : FTC window start time
%   T2              : FTC window end time
%   ChannelNumber   : Channel Number (Default == 1)
%   ServerName      : Tank Server Name (Default=='Puente')
%
%RETURNED DATA
%   FTC             : Frequency Tunning Curve Data Structure for 
%                     all units
%
function [FTC] = onlineftcplay(TankFileName,BlockNumber,T1,T2,ChannelNumber,ServerName)

tic;
PauseTime=3;
while toc<120
 
    figure(1)
    onlineftc(TankFileName,BlockNumber,T1,T2,ChannelNumber,ServerName);
    pause(PauseTime)
    clc
 
end