%
%function [RFmBW]=rastercircularcorrfmbw(RASTER,FMAxis,BWAxis,Ncyc,Fsd,T,Disp)
%
%   FILE NAME       : RASTER CIRCULAR CORR FM BW
%   DESCRIPTION     : Shuffled rastergram circular correlation function.
%                     Computes the envelope shuffled correlation as well as
%                     the fine structure shuffled correlation.
%
%                     Shuffles are performed in two ways:
%
%                     1) First we shuffled between consecutive periods in 
%                     time and perform the correlation between the k-th and
%                     l-th raster (corresoponding to the k-th and l-th 
%                     period). Note that for this procdure, consecutive
%                     cycles have identical envelopes but the fine
%                     structure is uncorrelated. Thus this procedure gives
%                     the envelope shuffled correlogram.
%
%                     2) Second, we shuffle across trail for each cycle
%                     raster. In this case, both the envelope and fine
%                     structure are fixed. This shuffled correlogram
%                     contains buth the fine structure and envelope
%                     correlations.
%
%                     The standard error is obtaine with a Jackknife on the
%                     original data samples.
%
%	RASTER          : Cycle Rastergram (compressed spet format). Generated
%                     using RASTER2CYCLERASTERORDERED. RASTER contains LxM
%                     elements where L corresponds to the number of trials
%                     and M corresponds to the number of cycles over time.
%   FMAxis          : Modulation Frequency Axis
%   BWAxis          : Bandwidth Axis
%   NCyc            : Number of cycles for circular shuffled correaltion
%   Fsd             : sampling rate of raster to compute raster-corr.
%   T               : Amount of time to remove at begninng of file to avoid
%                     adaptation effects
%   Disp            : Display output ('y' or 'n', Default=='n')
%
%RETURNED VALUES
%
%   RFmBW           : Data structure containing the orrelations as a
%                     function of bandwidht and modulation frequency
%
%                     .Renv         - Envelope correlogram
%                     .Renvfs       - Envelope & fine structure correlogram
%                     .Raa          - Autocorrelogram
%                     .RenvSEM      - SEM for Renv
%                     .RenvfsSEM    - SEM for Renvfs
%                     .RaaSEM       - SEM for Raa
%                     .RenvB        - Bootstrap samples for RenvB
%                     .RenvfsB      - Bootstrap samples for RenvfsB
%                     .RaaB         - Bootstrap samples for Raa
%                     .Tau          - Delay vector (msec)
%                     .sigma        - Jitter standard deviation (msec)
%                     .xhat         - Number of reliable spikes/cycle
%
%                     .MI1          - Modulation Index 1 - based on power
%                     .MI2          - Modulation Index 1 - based on rate.
%                                     The same as Zheng 2008
%                     .lambdaAC     - AC firing rate
%                     .lambdaDC     - DC firing rate
%                     .F            - Temporal coding fraction 
%                                     =lambdaAC^2/(lambdaAC^2+lambdaDC^2)
%                     .Rmodel       - Sum of gaussian model fit of envelope
%                                     correlation 
%                     .BW           - Bandwidth
%                     .Fm           - Modulation Frequency (Hz)
%                     .FMAxis       - Modulation Freq. Axis (Hz)
%                     .BWAxis       - Bandwidth Axis
%                     .lambdap      - 
%
% (C) Monty A. Escabi, Feb 2011
%
function [RFmBW]=rastercircularcorrfmbw(RASTER,FMAxis,BWAxis,Ncyc,Fsd,T,Disp)

%Input Args
if nargin<7
    Disp='n';
end

%Dimensions for number of bandwidht and modulation frequency conditions
Nbw=size(RASTER,2);
Nfm=size(RASTER,1);

%Generating shuffled envelope and fine structure correlograms
for k=1:Nfm
    for l=1:Nbw
        
        clc
        disp(['Computing Correlogram for FM=' num2str(FMAxis(k)) ' and BW=' num2str(BWAxis(l)) ' ('  num2str(100*(l+(k-1)*Nbw)/Nfm/Nbw,2) ' % Done)'])
        
        %Generating Shuffled Correlations
        [RASTER1c]=raster2cyclerasterordered(RASTER(k,l).RASTER,FMAxis(k),Ncyc,T,0);
        [R]=rastercircularshufcorrenvfine(RASTER1c,Fsd,FMAxis(k),'y');
        R.Fm=FMAxis(k);
        R.BW=BWAxis(l);
        R.FMAxis=FMAxis;
        R.BWAxis=BWAxis;
        
        %Finding Firing Rate
        R1c=reshape(RASTER1c,1,numel(RASTER1c));
        R1c=rasterexpand(R1c,Fsd,R1c(1).T);
        R.lambdap=mean(mean(R1c))
        
        %Assigning Results to structure
        RFmBW(k,l)=R;
        
    end
end

%Displaying output if desired
if strcmp(Disp,'y')
    
    %%%%%%%%%%%%%% ENVELOPE CORRELOGRAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure
    Max=-9999;
    for k=1:Nfm
        for l=1:Nbw
            Max=max([Max RFmBW(k,l).Renv]);
        end
    end
    for k=1:Nfm
        for l=1:Nbw
            subplot(Nfm,Nbw,l+(k-1)*Nbw)
            plot(RFmBW(k,l).Tau,RFmBW(k,l).Renv,'k')
            axis([max(RFmBW(k,l).Tau)*[-1 1]  0 Max*1.1])
        end
    end  
    
    %%%%%%%%%%%%%% ENVELOPE + FINE STRUCTTURE CORRELOGRAM %%%%%%%%%%%%%%%%%
    figure
    Max=-9999;
    for k=1:Nfm
        for l=1:Nbw
            Max=max([Max RFmBW(k,l).Renvfs]);
        end
    end
    for k=1:Nfm
        for l=1:Nbw
            subplot(Nfm,Nbw,l+(k-1)*Nbw)
            plot(RFmBW(k,l).Tau,RFmBW(k,l).Renvfs,'k')
            axis([max(RFmBW(k,l).Tau)*[-1 1] -Max*0.25 Max*1.1])
        end
    end  

    %%%%%%%%%%%%%% FINE STRUCTTURE CORRELOGRAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure
    Max=-9999;
    for k=1:Nfm
        for l=1:Nbw
            Max=max([Max RFmBW(k,l).Renvfs-RFmBW(k,l).Raa]);
        end
    end
    for k=1:Nfm
        for l=1:Nbw
            subplot(Nfm,Nbw,l+(k-1)*Nbw)
            plot(RFmBW(k,l).Tau,RFmBW(k,l).Renvfs-RFmBW(k,l).Raa,'r')
            axis([-5 5  -Max*0.25 Max*1.1])
        end
    end  

end