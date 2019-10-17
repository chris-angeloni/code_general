%
%function [Dp]=sdmrasterdprime(RASTER1,RASTER2,Fsd,tc)
%
%       FILE NAME       : Spike Distance Raster
%       DESCRIPTION     : Computes the spike distance metric between two
%                         rasters as described by Van Rossum, 1999. Returns
%                         a matrix containing the spike distance between
%                         all possible trial combinations
%
%       RASTER1         : RASTER containing spike even times for condition 1
%       RASTER2         : RASTER containing spike even times for condition 2
%       Fs              : Desired sampling rate (Hz)
%       tc              : Time constant (msec)
%
%RETURNED VARIABLES
%
%       Dp              : Spike distance normalized as D-prime
%
%       (C) Monty A. Escabi, March 2009 (Escabi Edit 7/13)
%
function [Dp]=sdmrasterdprime(RASTER1,RASTER2,Fsd,tc)

%Generating Dprime
%[D12]=sdmraster(RASTER1,RASTER2,Fsd,tc);
[D12]=sdmpsth(RASTER1,RASTER2,Fsd,tc);      %Distance between PSTH (mean)
[D11]=sdmraster(RASTER1,RASTER1,Fsd,tc);
[D22]=sdmraster(RASTER2,RASTER2,Fsd,tc);

%Computing Squared Norms and Dprime
%Need 1/2 for N11 and N12 because we are computing the SDM for
%different trials. Note that the response is of the form s1=s+n1
%and s2=s+n2. When we compute SDM between s1 and s2 we have
%SDM=norm(s2-s1)=norm(n2-n1)=2*var(n). So the estimate of variance
%needs to account for the factor of 2
%N12=mean(reshape(D12,1,numel(D12)));
N12=D12;
N11=1/2*sum(reshape(D11,1,numel(D11)))/(numel(D11)-size(D11,1));
N22=1/2*sum(reshape(D22,1,numel(D22)))/(numel(D22)-size(D22,1));
Dp=sqrt(2)*sqrt(N12)/sqrt(N11+N22);                             %Escabi Edit 7/13, change 2 -> sqrt(2)