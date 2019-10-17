%
% [MTF,MTFJ,CYCH] = 
% mtfanalysis(Data,Flag,Fsd,MaxTau,OnsetC,numC,Unit,N,binspercyc)

%   FILE NAME   : MTF ANALYSIS
%   DESCRIPTION : Generates rMTF,normMTF,tMTF and pMTF, jitterMTF, and CYC from the
%   original data
%
%  Data         : from readtank.m
%  Fsd			: Sampling rate for correlation analysis (Hz)	
%  MaxTau       : Temporal lag to compute xcorrelation (msec)
%  OnsetC       : remove first few cycles
%  numC         : number of cycles for CYCH analysis
%  Unit         : number of units, (default 0)
%  N            : number of repetition
%  binspercyc   : bins per cycle for CYCH analysis

%
% RETURNED DATA
%  MTF          : rMTF, normMTF, and tMTF
%                .FMAxis
%                .Rate      - spike rate
%                .Spetnorm  - spike per event
%                .VS        - vector strenth
%  MTFJ         : Jitter MTF Data Structure
%                .FMAxis    - Modulation Frequency Axis
%                .p         - Trial-to-trial reliability
%                .sigma     - Jitter standard deviation (msec)
%                .lambda    - Firing rate (spikes/sec)
%                .pg        - Trial-to-trial reliability (Gaussian
%                                 Model estimate)
%                .sigmag    - Jitter standard deviation (msec)
%                                 (Gaussian Model estimate)
%                .lambdag   - Firing rate (spikes/sec) (Gaussian Model
%                                 estimate)
%                .Corr      - Correlation functions
%                     Corr.Raa
%                     Corr.Rab
%                     Corr.Rpp
%                     Corr.Rmodel
%                     Corr.Tau
%  CYCH        : CYC histgram
%                 
%  
function [MTF,MTFJ,CYCH] = mtfanalysis(Data,Flag,Fsd,MaxTau,stimmod,Onset,num,Unit,N,binspercyc)

if (Flag == 0 | Flag ==1)
    flag=0;   % clear flag before load param because param include 'flag' variable
    load('SAMandBurstNoiseLogFMFixedPeriods_param.mat')
else
    load('SAMOnsetNoise_param.mat')
end

if nargin<8
    N = length(FM)/length(Fm);   % usually, it is 10
end

if nargin<7
   indexU = 1:length(Data.SortCode);                       %Use all Units
else
   indexU = find(Unit==Data.SortCode);                     %Use specified Unit
end

if nargin<6
    OnsetC = 0;
end

% ********** RASTER *************
[RASspet, RAStt, FMAxis] = rastergen(Data,Flag,stimmod,Onset,num,Unit,N)

% ********** rate, normilized-per-event, temporal MTF ******
[MTF] = mtfrtgenerate(RASspet,FMAxis,Flag,stimmod,Onset,num,N)
figure(3)
subplot(311)
semilogx(FMAxis,MTF.Rate,'.-');
ylabel('spikes/s');
if Flag==0
    title('SAM noise');
elseif Flag==1
    title('PNB');
else
    title('Onset');
end
xlim([1 2000]);
    
subplot(312)
semilogx(FMAxis,MTF.Spetnorm,'.-')
ylabel('spikes/cycle');
xlim([1 2000]);

subplot(313)
semilogx(MTF.FMAxis,MTF.VS);
% semilogx(FMAxis(sigvs_index),MTF.VS(sigvs_index));
axis([1 1000 0 1])
% semilogx(MTF.FMAxis0,MTF.VS0);
xlabel('mod freq (Hz)');
ylabel('vector strength');
xlim([1 2000]);

% *********** CYCH ****************
CYCH = [];
[CYCH]= cychgen(RASspet,Flag,FMAxis,binspercyc,stimmod,Onset,num,N)
if Flag == 2
    numC = 1;
end
for k=1:length(FMAxis)
    figure(20+k);
    bar((0:binspercyc)/binspercyc/FMAxis(k),CYCH(k).hist);
%   axis([0 1/FMAxis(k) 0 max(CYCH(k))])
    %hist(CYCH(k).time,binspercyc);
    title(['CYCH for' num2str(FMAxis(k)) ' Hz']);
    xlabel('Time (s)');
    % axis([0 1/FMAxis(k) 0 max(CYCH(k).hist]);
    pause(1)
end

MTFJ = []
% % ************ Mean and SD MTF **********
% [SpetMean,SpetSD]=meansdgen(RASspet,FMAxis,Flag,CYCH)
% 
% % ************ Reliability MTF ********
% [Relia]=reliagen(RASspet,FMAxis,Fsd,MaxTau)
% figure
% semilogx(FMAxis,Relia,'.');
% axis([1 2000 0 1])
% title('Reliability MTF');
% 
% MTFJ.reli = Relia;
% MTFJ.mean = SpetMean;
% MTFJ.sd = SpetSD;

% % ********** Jitter MTF **********
% MTFJ = [];
% [MTFJ] = mtfjittergenerate(RASspet,Fsd,FMAxis,MaxTau)
% for k=1:length(FMAxis)
%     P(k) = MTFJ(k).p;
%     Sigma(k) = (MTFJ(k).sigma)^2;
%     Pg(k) = MTFJ(k).pg;
%     Sigmag(k) = MTFJ(k).sigmag;
% end
% 
% figure(11)
% % subplot(211)
% % semilogx(FMAxis,P)
% semilogx(FMAxis,P,'b',FMAxis,Pg,'r');
% title('Reliability MTF');
% figure(12)
% % subplot(212)
% % semilogx(FMAxis,Sigma)
% semilogx(FMAxis,Sigma,'b',FMAxis,Sigmag,'r');
% title('Jitter MTF');
% xlabel('Mod Freq (Hz)');
