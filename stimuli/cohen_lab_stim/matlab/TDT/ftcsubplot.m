%
% function [] = ftcsubplot(FTC,subplotv)
%
%	FILE NAME 	: FTC SUB PLOT
%	DESCRIPTION : Plots a frequency tunning curve on the TDT system
%
%	FTC	        : Tunning Curve Data Structure
%                   FTC.Freq                - Frequency Axis
%                   FTC.Level               - Sound Level Axis (dB)
%                   FTC.data                - Data matrix
%   subplotv    : Subplot vector - [m n k]
%
% (C) Monty A. Escabi, Edit Feb 2012
%
function [] = ftcsubplot(FTC,subplotv)

%Plotting FTC
subplot(subplotv(1),subplotv(2),subplotv(3))
%pcolor(FTC(1).Freq/1000,FTC(1).Level,FTC.data')
%pcolor(FTC(1).Freq/1000,FTC(1).Level,FTC.data'/FTC.NFTC/(FTC.T2-FTC.T1))
imagesc(log2(FTC(1).Freq/500),FTC(1).Level,FTC.data'/FTC.NFTC/(FTC.T2-FTC.T1)*1000)

%set(gca,'XScale','log')
colorbar
%set(gca,'xtick',[.5 1 2 4 8 16 32 64])
set(gca,'xtick',[0 1 2 3 4 5 6 7])
set(gca,'xticklabel',[.5 1 2 4 8 16 32 64])
set(gca,'YDir','normal')
    
%Labeling Axis on First Unit Only    
if subplotv(3)==1
    xlabel('Freq. (kHz)')
    ylabel('ATT (dB)')
end