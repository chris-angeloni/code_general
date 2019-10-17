%
% function [MTFSpline] = mtfsplinediscriminategeneratefast(RASSpline,Fsd,tc,TD,OnsetT)
%
%	FILE NAME 	: MTF SPLINE DISCRIMINATE GENERATE FAST
%	DESCRIPTION : Generates a discrimination MTF for B-splines. The 
%                 algorithm compares the spike trains between all AM 
%                 conditions (modulation frequencies) the Van Rossum spike 
%                 distance metric (SDM). A discrimination matrix is then 
%                 generated. The SDM is normalized as a discrimination 
%                 index (D-prime).
%
%   RASSpline   : Spline dot-raster data structure. 
%                 Data is formated as follows:
%
%                   MTFRAS.spet             - spike event times
%                   MTFRAS.Fs               - Sampling Rate
%                   MTFRAS.T                - Stimulus duration
%
%   Fsd         : Desired sampling rate for analysis (Hz)
%   tc          : Time constant for computing spike distance (msec). If
%                 tc is a vector, the program performs the analysis at all
%                 tc values
%   TD          : Total stimulus duration (sec)
%   OnsetT      : Time to remove at onset (sec)
%
% RETURNED DATA
%
%	MTFSpline   : MTF Discrimnation Data Structure. If tc is a vector,
%                 MTFSpline is a vector of data structures. 
%
%                 MTFSpline.Dp          - D-prime discrimination matrix
%                 MTFSpline.FMAxis      - Modulation frequency axis
%
%   (C) Monty A. Escabi, Jan 2010
%
 function [MTFSpline] = mtfsplinediscriminategeneratefast(RASSpline,Fsd,tc,TD,OnsetT)

L1=size(RASSpline,1);
L2=size(RASSpline,2);
for m=1:length(tc)
    for k1=1:L1
        for l1=k1:L2
            for k=1:L1
                for l=k:L2
l
                    %Selecting rasters for desired modulation conditions
                    RASk=RASSpline(k1,l1).RASTER;
                    RASl=RASSpline(k,l).RASTER;
                    %RASk=MTFRAS((k-1)*N+1:k*N);
                    %RASl=MTFRAS((l-1)*N+1:l*N);

                    %Computing SDM
                    [Dkl]=sdmpsth(RASk,RASl,Fsd,tc(m));      %Distance between PSTH (mean)
                    [Dkk]=sdmraster(RASk,RASk,Fsd,tc(m));    
                    [Dll]=sdmraster(RASl,RASl,Fsd,tc(m)); 

                    %Computing Squared Norms and Dprime
                    %Need 1/2 for Nkk and Nll because we are computing the SDM for
                    %different trials. Note that the response is of the form s1=s+n1
                    %and s2=s+n2. When we compute SDM between s1 and s2 we have
                    %SDM=norm(s2-s1)=norm(n2-n1)=2*var(n). So the estimate of variance
                    %needs to account for the factor of 2
                    Nkl=Dkl;
                    Nkk=1/2*sum(reshape(Dkk,1,numel(Dkk)))/(numel(Dkk)-size(Dkk,1));
                    Nll=1/2*sum(reshape(Dll,1,numel(Dll)))/(numel(Dll)-size(Dll,1));

                    %Computing and saving Dp results into discrimination matrix
                    MTFSpline(k1,l1,m).Dp(k,l)=2*sqrt(Nkl)/sqrt(Nkk+Nll);
                    MTFSpline(k1,l1,m).Dp(l,k)=MTFSpline(k1,l1,m).Dp(k,l);
                    MTFSpline(k1,l1,m).tc=tc(m);
                    MTFSpline(k1,l1,m).FC=RASSpline(k1,l1).FC;
                    MTFSpline(k1,l1,m).FM=RASSpline(k1,l1).FM;
                    
                end
            end
        end
    end
    MTFSpline(k1,l1,m).FMAxis=RASSpline(k1,l1).FMAxis;
    MTFSpline(k1,l1,m).FCAxis=RASSpline(k1,l1).FCAxis;
    clc
    disp(['Percent Done: ' num2str(m/length(tc)*100,3) ' % done'])
end