%
%function [R]=jitterrasterschreiber(RASTER,sigma,Fsd)
%
%   FILE NAME   : JITTER RASTER SCHREIBER
%   DESCRIPTION : Finds the reliability of a rastergram using the
%                 correlation metric of Schreiber et al.
%
%   RASTER      : Rastergram in compressed format.
%   sigma       : Vector of smooting resolutions (msec)
%   Fsd         : Desired sampling rate (Hz)
%
%Returned Variables
%
%       R       : Reliability
%
% (C) Monty A. Escabi, June 2010
%
function [R]=jitterrasterschreiber(RASTER,sigma,Fsd)

%Expanding Raster
[RAS,Fs]=rasterexpand(RASTER,Fsd);
N=length(RASTER);

%Computing Reliability Metric
sigma=sigma/1000;
R=zeros(size(sigma));
for i=1:length(sigma)
    
    %Generating Gaussian Filter
    L=sigma(i)*5*Fsd;
    time=(-L:L)/Fsd;
    G=exp(-time.^2/2/sigma(i)^2);

    %Convolving Gaussian Filter
    S=[];
    for k=1:N
        S(k,:)=conv(RAS(k,:),G);
    end

    %Computing reliability at a fixed sigma
    for k=1:N
        for l=k+1:N
            R(i)=R(i)+sum(S(k,:).*S(l,:))./sqrt(sum(S(k,:).^2))/sqrt(sum(S(l,:).^2));
        end
    end
    
end
R=R*2/N/(N-1);