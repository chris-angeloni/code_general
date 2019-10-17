% [MTF,MTFJ,CYCH] =
% raster2mtfanalysis(RAStt,RASspet,FMAxis,Flag,Fsd,MaxTau,OnsetC,numC,binspercyc)

%   FILE NAME   : MTF ANALYSIS
%   DESCRIPTION : Generates rMTF,normMTF,tMTF and pMTF, jitterMTF from RASTER data
%
%  RASspet	    : compressed spet RASTER format
%                .spet         - spike event time 
%                .Fs:          - sampling rate
%  RAStt       : time vs trial RASTER format
%                .time         - spike time
%                .trial        -
%                .N            - repetition
%  Fsd			: Sampling rate for correlation analysis (Hz)	
%  MaxTau       : Temporal lag to compute xcorrelation (msec)
%
% RETURNED DATA
%
%   MTFJ        : Jitter MTF Data Structure
%
%                 MTF.FMAxis    - Modulation Frequency Axis
%                 MTF.p         - Trial-to-trial reliability
%                 MTF.sigma     - Jitter standard deviation (msec)
%                 MTF.lambda    - Firing rate (spikes/sec)
%                 MTF.pg        - Trial-to-trial reliability (Gaussian
%                                 Model estimate)
%                 MTF.sigmag    - Jitter standard deviation (msec)
%                                 (Gaussian Model estimate)
%                 MTF.lambdag   - Firing rate (spikes/sec) (Gaussian Model
%                                 estimate)
%                 MTF.Corr      - Correlation functions
%                     Corr.Raa
%                     Corr.Rab
%                     Corr.Rpp
%                     Corr.Rmodel
%                     Corr.Tau
%
% Yi Zheng, Nov 2006.

function [MTF,MTFJ,CYCH] = raster2mtfanalysis(RAStt,RASspet,FMAxis,Flag,Fsd,MaxTau,OnsetC,numC,binspercyc)

N = RAStt.N;
if Flag == 2
    numC = 1;
end
% *********** rate, normilized-per-event, temporal MTF ********************************
[MTF] = mtfrtgenerate(RASspet,RAStt,FMAxis,Flag,OnsetC,N)
figure(3)
subplot(311)
semilogx(FMAxis,MTF.Rate);
ylabel('spikes/s');
if Flag==0
    title('SAM noise');
elseif Flag==1
    title('PNB');
else
    title('Onset');
end
    
subplot(312)
semilogx(FMAxis,MTF.Spetnorm)
ylabel('spikes/cycle');

subplot(313)
semilogx(MTF.FMAxis,MTF.VS);
% semilogx(FMAxis(sigvs_index),MTF.VS(sigvs_index));
axis([1 1000 0 1])
% semilogx(MTF.FMAxis0,MTF.VS0);
xlabel('mod freq (Hz)');
ylabel('vector strength');

% *********** CYCH *******************************************************
[CYCH]= cychgen(RASspet,FMAxis,binspercyc,OnsetC,numC,N)

for k=1:length(FMAxis)
    figure(20+k);
    hist(CYCH(k).time,binspercyc);
    title(['CYCH for' num2str(FMAxis(k)) ' Hz']);
    xlabel('Time (s)');
%    axis([0 1/FMAxis(k) 0 max(CYCH(k).hist)*N*numC]);
end

% ********** Jitter MTF **********%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[MTFJ] = mtfjittergenerate(RASspet,Fsd,FMAxis,MaxTau)
for k=1:length(FMAxis)
    P(k) = MTFJ(k).p;
    Sigma(k) = (MTFJ(k).sigma)^2;
    Pg(k) = MTFJ(k).pg;
    Sigmag(k) = MTFJ(k).sigmag;
end

figure(11)
subplot(211)
% semilogx(FMAxis,P)
semilogx(FMAxis,P,'b',FMAxis,Pg,'r');
title('Reliability MTF');
subplot(212)
% semilogx(FMAxis,Sigma)
semilogx(FMAxis,Sigma,'b',FMAxis,Sigmag,'r');
title('Jitter MTF');
xlabel('Mod Freq (Hz)');
legend('True','Gaussian');
