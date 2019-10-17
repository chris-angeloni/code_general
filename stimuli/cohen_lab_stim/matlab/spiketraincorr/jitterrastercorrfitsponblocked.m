%
%function [JitterData]=jitterrastercorrfitsponblocked(RASTER,Fsd,MaxTau,dT,Disp)
%
%   FILE NAME   : JITTER RASTER CORR FIT SPON BLOCKED
%   DESCRIPTION : Noise correlation model. Generates the shuffled, auto and
%                 noise correlograms estimated from a dot-raster. The data
%                 is broken up into non-overlapping time segments (dT) and
%                 the shuffled correlograms and statistics are estimated 
%                 for each temporal segment. This procedure is used to 
%                 estimate the spike timing jitter and firing reliability 
%                 and spontaneous noise.
%
%	RASTER          : Rastergram in compressed format
%   Fsd             : Desired sampling rate for correlation measurement
%   MaxTau          : Maximum Correlation Delay (msec)
%   dT              : Duration used to segment the dot-raster into
%                     non-overlapping temporal blocks (msec)
%   Disp            : Display Output (Optional; Default='n')
%
%Returned Variables
%
%   JitterData: Data Structure vector containing statistics for each
%               temporal segment 
%       .Tau         : Delay Axis (msec)
%       .Raa         : Autocorrelation
%       .RaaS        : ISI shuffled autocorrelation
%       .Rab         : Crosscorrelation
%       .RabS        : ISI shuffled crosscorrelation
%       .Rnoise      : Noise Correlation - contains jitter and reliability
%       .lambdap     : Estimated spike rate
%       .lambdas     : Estimated spontaneous spike rate
%       .lamdad      : Estimated driven spike rate
%       .Rmodel      : Model Fitted Jitter Distribution Correlation
%       .sigmag      : Spike timing jitter - Gaussian Estimate
%       .pg          : Trial reproducibility - Gaussian Estimate
%       .phog        : Reliability of driven spikes, normal model
%       .lambdag     : Hypothetical spike rate - Gaussian Estimate
%                      (Assumesno jitter or trial reprodicibility errors)
%       .sigma       : Spike Timing Jitter - Direct Estimate
%       .p           : Trial reproducibility - Direct Estimate
%       .pho         : Reliability of driven spikes, direct estimate 
%       .lambda      : Hypothetical Spike rate - Direct Estimate
%                      (Assumes no jitter or rial reprodicibility errors)
%       .E           : Optimization error curve (e = Rnoise - Rmodel)
%                      versus lamdas
%       .dl          : Resolution for lambdas used to generate E
%
% (C) Monty A. Escabi, Jan 2011
%
function [JitterData]=jitterrastercorrfitsponblocked(RASTER,Fsd,MaxTau,dT,Disp)

%Input Arguments
if nargin<5
	Disp='n';
end

%Converting Raster to Matrix
[RASTER,Fs]=rasterexpand(RASTER,Fsd,RASTER(1).T);

%Segmenting RASTER and computing jitter statistics for each segment
dN=round(dT/1000*Fsd);
L=floor(size(RASTER,2)/dN);
for k=1:L
    RAS=RASTER(:,(k-1)*dN+1:k*dN);
    [RAS]=rastercompress(RAS,Fs,dT/1000);
    [JitterData(k)]=jitterrastercorrfitspon(RAS,Fsd,MaxTau);
end