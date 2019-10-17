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
% (C) Monty A. Escabi, Last Edit - Spetember 2006
%
function [] = ftcplot(FTC)

%Number of Tunning Curves
N=length(FTC);

%Plotting All
for k=1:N

    %Selecting Plot Arrangement
    if N<2
        subplot(111)
    elseif N<5
        subplot(2,2,k)    
    elseif N<7
        subplot(2,3,k)    
    else
        subplot(3,3,k)
    end
    
    %Plotting FTC
    RegN=4;
    RegM=3;
    p=0.05;
    [FTCStats] = ftccentroid(FTC,p,RegN,RegM);
    imagesc(log2(FTC.Freq/500),FTC.Level,FTC.data'/(FTC.T2-FTC.T1)*1000/FTC.NFTC);
    set(gca,'YDir','normal')
    hold on
    try, plot(log2(FTCStats.Mean/500).*FTCStats.Mask,FTC.Level,'ko');, end
    F1=(log2((FTCStats.Mean)/500)-FTCStats.Std).*FTCStats.Mask;
    F2=(log2((FTCStats.Mean)/500)+FTCStats.Std).*FTCStats.Mask;
    try, plot([F1'; F2'],[FTC.Level; FTC.Level],'k-');, end
    set(gca,'YDir','normal')
    set(gca,'Xtick',[-1 0 1 2 3 4 5 6 7])
    set(gca,'XtickLabel',[.25 .5 1 2 4 8 16 32 64])
    colorbar
    
    %Reporting Statistics
    index=find(~isnan(FTCStats.Mask) & ~isnan(FTCStats.Mean));
    BF=mean(FTCStats.Mean(index))/1000;
    Threshold=FTCStats.Threshold;
    try, title(['CF=' num2str(FTCStats.Mean(index(1))/1000,3) ' (kHz) , BF = ' num2str(BF,3) ' kHz  , Attenuation Threshold = ' num2str(Threshold,3) ' dB, SPL Threshold = ' num2str(Threshold+90,3)]);, end
    
    %Labeling Axis on First Unit Only
    if k==1
        xlabel('Freq. (kHz)')
        ylabel('ATT (dB)')
    end

end