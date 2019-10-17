%
%function [Ravg,Rstd,R05,R01,R]=rastercircularxcorr(RASTER,Fsd,Delay,NB)
%
%   FILE NAME       : RASTER CIRCULAR CORR
%   DESCRIPTION     : Across-trial circular correlation function. Computes 
%                     the standard error and p<0.01 and p<0.05 confidence
%                     intervals of Ravg with a Bootstrap procedure
%
%	RASTER          : Rastergram (compressed spet format)
%   Fsd             : sampling rate of raster to compute raster-corr.
%   Delay           : Rearanges the correlation output (R) so that the
%                     zeroth bin is centered about the center of the
%                     correaltion function (at the floor(N/2)+1 sample).
%                     Otherwize, the zeroth bin of the correaltion function
%                     is located at the first sample of R. (OPTIONAL,
%                     Default == 'n')
%	NB              : Number of Bootstraps for Cross Correlation Estimate
%                     Default = 500
%RETURNED VALUES
%	Ravg            : Average cross-trial correlation function
%	Rstd            : Across-trial correlation standard deviation array
%	R05         	: 2xlength(Ravg) matrix containg the possitive and 
%                     negative p<0.05 confidence intervals
%	R01             : 2xlength(Ravg) matrix containg the possitive and 
%                     negative p<0.01 confidence intervals
%   R               : Raw data for each trial (Not averaged)
%
% (C) Monty A. Escabi / Yi Zheng, July 2007
%
function [Ravg,Rstd,R05,R01,R]=rastercircularxcorr(RASTER,Fsd,Delay,NB)

%Expand rastergram into matrix format
T=RASTER(1).T;
[RAS,Fs]=rasterexpand(RASTER,Fsd,T);

%Rastergram Lenght
L=size(RAS,2);
M=size(RAS,1);

%Computing Shuffled Circular Correlation
Ravg=zeros(1,M);
R=[];
for k=2:M
	clc
	disp(['Computing cross-channel correlation for channel: ' num2str(k)])
	for l=1:k-1

            R=[R; xcorrcircular(RAS(k,:),RAS(l,:),'y')/Fsd/T]; 
    end        
end

%Finding Average Correlation and Confidence Intervals using Bootstrap
if size(R,1)>1
	Ravg=mean(R);
else
	Ravg=R;
end
if NB~=0
	[Rstd,R05,R01]=rastercorrbootstrap(R,NB);
else
	R05=-9999;
	R01=-9999;
end