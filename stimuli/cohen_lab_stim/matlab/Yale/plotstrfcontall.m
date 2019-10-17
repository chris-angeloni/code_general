%
%function []=plotstrfcontall(STRFData,channel,Ncol,Nrow)
%
%   FILE NAME   : PLOT STRF CONT ALL
%   DESCRIPTION : Sequentially plots the STRFs stored in the STRF data structure
%   
%   STRFData    : Data Structure containing the following elements
%                 .taxis   - Time Axis
%                 .faxis   - Frequency Axis (Hz)
%                 .STRF1A  - STRF for channel 1 on trial A
%                 .STRF2A  - STRF for channel 2 on trial A
%                 .STRF1B  - STRF for channel 1 on trial B
%                 .STRF2B  - STRF for channel 2 on trial B
%                 .STRF1As - Phase Shuffled STRF for channel 1 on trial A
%                 .STRF2As - Phase Shuffled STRF for channel 2 on trial A
%                 .STRF1Bs - Phase Shuffled STRF for channel 1 on trial B
%                 .STRF2Bs - Phase Shuffled STRF for channel 2 on trial B
%                 .SPLN  - Sound Pressure Level per Frequency Band
%   Channel     : Desired STRF channel (1 or 2, typically 1=contra, 2=ipsi)
%   Ncol        : Number of subplot rows
%   Nrow        : Number of subplot columns
%
% (C) Monty A. Escabi, August 2010
%
function []=plotstrfcontall(STRFData,channel,Ncol,Nrow)

%Time and Frequency Axis
taxis=STRFData(1).taxis*1000;
faxis=STRFData(1).faxis;

%Plotting STRFs
for i=1:Nrow*Ncol:length(STRFData)
    for k=1:Ncol
        for l=1:Nrow

            n=i+l+Nrow*(k-1);
            if n<=length(STRFData)
                subplot(Ncol,Nrow,l+Nrow*(k-1))
                if channel==1 & isfield(STRFData,'STRF1B')
                    STRF=(mean(STRFData(n).STRF1A,3)+mean(STRFData(n).STRF1B,3))/2;
                elseif channel==1 & ~isfield(STRFData,'STRF1B')
                    STRF=mean(STRFData(n).STRF1A,3);
                elseif channel==2 & isfield(STRFData,'STRF2B')
                    STRF=(mean(STRFData(n).STRF2A,3)+mean(STRFData(n).STRF2B,3))/2;  
                elseif channel==2 & ~isfield(STRFData,'STRF2B')
                    STRF=mean(STRFData(n).STRF2A,3);
                end
                imagesc(taxis,log2(faxis/faxis(1)),STRF)
                set(gca,'YDir','normal')
                Max=max(max(abs(STRF)))
                caxis([-Max Max])
            end
        end
    end
    
    subplot(Ncol,Nrow,(Nrow-1)*(Ncol)+1)
    xlabel('Delay (msec)')
    ylabel('Freq. (oct)')
    
    pause
    clf
    
end