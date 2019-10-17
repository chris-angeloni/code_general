%
% function [] = ftcplot(FTC)
%
%	FILE NAME 	: FTC PLOT
%	DESCRIPTION : Plots a frequency tunning curve on the TDT system
%
%	FTC	        : Tunning Curve Data Structure
%
%                   FTC.Freq                - Frequency Axis
%                   FTC.Level               - Sound Level Axis (dB)
%                   FTC.data                - Data matrix
% 
function [] = ftcplot1(FTC)

%Number of Tunning Curves
N=length(FTC);

%Plotting All
for k=1:N

    %Selecting Plot Arrangement
    
    
    %Plotting FTC
    pcolor(FTC(1).Freq/1000,FTC(1).Level,FTC(1).data')
    set(gca,'XScale','log')
    colorbar
    set(gca,'xtick',[1 2 4 8 16 32 64])
    set(gca,'xticklabel',[1 2 4 8 16 32 64])
    set(gca,'YDir','normal')
    
    %Labeling Axis on First Unit Only
    if k==1
        xlabel('Freq. (kHz)')
        ylabel('ATT (dB)')
    end

end
