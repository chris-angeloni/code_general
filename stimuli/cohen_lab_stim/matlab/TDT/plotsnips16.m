%
% function [] = plotsnips16(Data,N,UnitNumber,order,T1,T2)
%
%	FILE NAME 	: PLOT SNIPS 16
%	DESCRIPTION : Plots the snips for a 16 channel recording block
%
%	Data        	: Data Block
%	N               : Number of snips to plot
%   UnitNumber      : Unit Number
%   order           : Order for selecting N snips (Default='r')
%                     'r' = random order, randomly picks N
%                     's' = sequential order, chooses first N
%   T1              : Snip start time (msec, Optional=-1.3 msec)
%   T2              : Snip end time (msec, Optional=2 msec)
%
%RETURNED DATA
%
%   (C) Monty A. Escabi, Nov 2005
%
function [] = plotsnips16(Data,N,UnitNumber,order,T1,T2)

%Input Arguments
if nargin<4
    order='r';
end
if nargin<5
    T1=-1.3;
end
if nargin<6
    T2=2;
end

%Time Axis
M=16;   %Reference Sample for window discriminator
delay=((1:size(Data.Snips,1))-M)/Data.Fs*1000;

%Plotting Snips
for k=1:16
   
   %Selecting Desired Snips
   index=find(Data.ChannelNumber==k & Data.SortCode==UnitNumber);
   L=min(N,length(index));
   if order=='r'
       index=randsample(index,L);
   end
   Max=max(max(abs(Data.Snips(:,index(1:L)))));
   
   %Plotting
   subplot(4,4,k)
   plot(delay,Data.Snips(:,index(1:L)),'k')
   text(1,1,['ch' int2str(k)])
   axis([T1 T2 -Max*1.1 Max*1.1])
   set(gca,'visible','off')
   
end