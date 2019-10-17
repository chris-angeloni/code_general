%
% function [MTF] = mtfdiscriminategeneratefastg(MTFRAS,N,Fsd,fc,BW,P,FM,TD,OnsetT)
%
%	FILE NAME 	: MTF DISCRIMINATE GENERATE FAST G
%	DESCRIPTION : Generates a discrimination MTF using Gabor SDM. The algorithm compares 
%                 the spike trains between all AM conditions (modulation 
%                 frequencies) the Van Rossum spike distance metric (SDM).
%                 A discrimination matrix is then generated. The SDM is 
%                 normalized as a discrimination index (D-prime).
%
%   MTFRAS      : MTF dot-raster data structure. 
%                 Data is formated as follows:
%
%                   MTFRAS.spet             - spike event times
%                   MTFRAS.Fs               - Sampling Rate
%                   MTFRAS.T                - Stimulus duration
%
%   N           : Number of repeats per AM condition
%   Fsd         : Desired sampling rate for analysis (Hz)
%   fc          : Gabor filter center frequency array (Hz)
%   BW          : Gabor filter 3 dB bandwidht array array (Hz; length=length(fc))
%   P           : Gabor filter phase array (length=length(fc))
%   FM          : Modulation rate array
%   TD          : Total stimulus duration (sec)
%   OnsetT      : Time to remove at onset (sec)
%
% RETURNED DATA
%
%	MTFDis      : MTF Discrimnation Data Structure. If fc is a vector,
%                 MTFDis is a vector of data structures. 
%
%                 MTFDis.Dp          - D-prime discrimination matrix
%                 MTFDis.FMAxis      - Modulation frequency axis
%
%   (C) Monty A. Escabi, May 2009 (Escabi Edit 7/13)
%
function [MTFDis] = mtfdiscriminategeneratefastg(MTFRAS,N,Fsd,fc,BW,P,FM,TD,OnsetT)

L=length(FM);
for m=1:length(fc)
    for k=1:L
        for l=1:k-1

            %Selecting rasters for desired modulation conditions
            RASk=MTFRAS((k-1)*N+1:k*N);
            RASl=MTFRAS((l-1)*N+1:l*N);

            %Computing SDM
            [Dkl]=sdmpsthg(RASk,RASl,Fsd,fc(m),BW(m),P(m));         %Distance between PSTH (mean)
            [Dkk]=sdmrasterg(RASk,RASk,Fsd,fc(m),BW(m),P(m));    
            [Dll]=sdmrasterg(RASl,RASl,Fsd,fc(m),BW(m),P(m)); 

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
            MTFDis(m).Dp(k,l)=sqrt(2)*sqrt(Nkl)/sqrt(Nkk+Nll);          %Escabi Edit 7/13, change 2 -> sqrt(2)

        end
    end
    MTFDis(m).FMAxis=FM;
    clc
    disp(['Percent Done: ' num2str(m/length(fc)*100,3) ' % done'])
end