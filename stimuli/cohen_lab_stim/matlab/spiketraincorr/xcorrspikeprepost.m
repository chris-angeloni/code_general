%
%function [CorrData]=xcorrspikeprepost(spet1A,spet1B,spet2A,spet2B,Fs,Fsd,T,Tblock,dT,NSE,MaxTau,NB,Disp)
%
%   FILE NAME   : XCORR SPIKE PRE POST
%   DESCRIPTION : Cross correlogram between a pre and post synaptic spike
%                 train pair
%
%   spet1A      : Spike train ISI array for unit 1 (presynaptic)  - trial A
%   spet1B      : Spike train ISI array for unit 1 (presynaptic)  - trail B
%   spet2A      : Spike train ISI array for unit 2 (postsynaptic) - trial A
%   spet2B      : Spike train ISI array for unit 2 (postsynaptic) - trail B
%   Fs          : Sampling rate for spets
%   Fsd         : Sampling rate for correlation measurement
%   T           : Recording time interval in seconds
%   Tblock      : Block size for bootstrap analysis (sec)
%   dT          : Search window to the left and right of peak correlation 
%                 for computing efficacy and contribution (msec)
%   NSE         : Number of standard deviations required for a significant
%                 correlation in order to compute the efficacy and
%                 contribution
%   MaxTau      : Maximum Correlation Delay (msec)
%   NB          : Number of boostraps (Default==1000)
%   Disp        : Display Output (Optional; Default='n')
%
%Returned Variables
%
%   CorrData    : Correlation data structure
%                 .R12          - Crosscorrelogram between unit 1 and 2
%                 .R12AB        - Trial shuffled crosscorrelogram between unit 1 and 2
%                 .R12s         - Spike shuffled crosscorrelogram betweeen unit 1
%                                 and 2
%                 .R12b         - Bootstrap samples for crosscorrelogram between unit 1 and 2
%                 .R12ABb       - Bootstrap samples for trial shuffled crosscorrelogram between unit 1 and 2
%                 .R12sb        - Bootstrap samples for spike shuffled crosscorrelogram betweeen unit 1
%                                 and 2
%                 .R12se        - Standard error for crosscorrelogram between unit 1 and 2
%                 .R12Ase       - Standard error samples for trial shuffled crosscorrelogram between unit 1 and 2
%                 .R12sse       - Standard error for spike shuffled correlogram
%                 .Tau          - Delay axis (msec)
%                 .lambda1      - Firing rate of unit 1 (presynaptic)
%                 .lambda2      - Firing rate of unit 2 (postsynaptic)
%                 .Efficacy     - Fraction of presynaptic spikes that
%                                 produce a postsynaptic spike
%                 .Contribution - Fraction of postsynaptic spikes that have
%                                 a correlated presynaptic spike
%                 .dT           - Search window to the left and right of peak correlation 
%                                 for computing efficacy and contribution (msec)
%                 .NSE          - Number of standard deviations required for a significant
%                                 correlation in order to compute the efficacy and
%                                 contribution
%                 .NB           - Number of boostraps (Default==1000)
%
% (C) Monty A. Escabi, June 2009
%
function [CorrData]=xcorrspikeprepost(spet1A,spet1B,spet2A,spet2B,Fs,Fsd,T,Tblock,dT,NSE,MaxTau,NB,Disp)

%Input Arguments
if nargin<12
    NB=1000;
end
if nargin<13
	Disp='n';
end

%Estimating auto and cross correlations
[R12A,R12Ab]=xcorrspikesparseb(spet2A,spet1A,Fs,Fsd,Tblock,MaxTau,T,'n','n','n');
[R12B,R12Bb]=xcorrspikesparseb(spet2B,spet1B,Fs,Fsd,Tblock,MaxTau,T,'n','n','n');
[R12AB,R12ABb]=xcorrspikesparseb(spet2A,spet1B,Fs,Fsd,Tblock,MaxTau,T,'n','n','n');
[R12BA,R12BAb]=xcorrspikesparseb(spet2B,spet1A,Fs,Fsd,Tblock,MaxTau,T,'n','n','n');
[R12As,R12Asb]=xcorrspikesparseb(shufflespet(spet2A),shufflespet(spet1A),Fs,Fsd,Tblock,MaxTau,T,'n','n','n');
[R12Bs,R12Bsb]=xcorrspikesparseb(shufflespet(spet2B),shufflespet(spet1B),Fs,Fsd,Tblock,MaxTau,T,'n','n','n');
[R11AB,R11ABb]=xcorrspikesparseb(spet1A,spet1B,Fs,Fsd,Tblock,MaxTau,T,'n','n','n');
[R22AB,R22ABb]=xcorrspikesparseb2(spet2A,spet2B,Fs,Fsd,Tblock,MaxTau,T,'n','n','n');
% [R12A,R12Ab]=xcorrspikeb2(spet2A,spet1A,Fs,Fsd,MaxTau,Tblock,T,'n','n','n');
% [R12B,R12Bb]=xcorrspikeb2(spet2B,spet1B,Fs,Fsd,MaxTau,Tblock,T,'n','n','n');
% [R12AB,R12ABb]=xcorrspikeb2(spet2A,spet1B,Fs,Fsd,MaxTau,Tblock,T,'n','n','n');
% [R12BA,R12BAb]=xcorrspikeb2(spet2B,spet1A,Fs,Fsd,MaxTau,Tblock,T,'n','n','n');
% [R12As,R12Asb]=xcorrspikeb2(shufflespet(spet2A),shufflespet(spet1A),Fs,Fsd,MaxTau,Tblock,T,'n','n','n');
% [R12Bs,R12Bsb]=xcorrspikeb2(shufflespet(spet2B),shufflespet(spet1B),Fs,Fsd,MaxTau,Tblock,T,'n','n','n');
% [R11AB,R11ABb]=xcorrspikeb2(spet1A,spet1B,Fs,Fsd,MaxTau,Tblock,T,'n','n','n');
% [R22AB,R22ABb]=xcorrspikeb2(spet2A,spet2B,Fs,Fsd,MaxTau,Tblock,T,'n','n','n');
R12=(R12A+R12B)/2;
R12AB=(R12AB+R12BA)/2;
R12s=(R12As+R12Bs)/2;

%Estimating Mean Spike Rate
lambda1=(length(spet1A)+length(spet1B))/2/T;
lambda2=(length(spet2A)+length(spet2B))/2/T;
N=(length(R12)-1)/2;
Tau=(-N:N)/Fsd*1000;

%Adding to data structure
CorrData.R12=R12;
CorrData.R12AB=R12AB;
CorrData.R12s=R12s;
CorrData.R11AB=R11AB;
CorrData.R22AB=R22AB;
CorrData.Tau=Tau;
CorrData.lambda1=lambda1;
CorrData.lambda2=lambda2;

%Combining Bootstgrap Data Between Trials
CorrData.R12b=[R12Ab;R12Bb];
CorrData.R12ABb=[R12ABb;R12BAb];
CorrData.R12sb=[R12Asb;R12Bsb];
CorrData.R11ABb=[R11ABb];
CorrData.R22ABb=[R22ABb];

%Bootstrapping Results and Obtaining Significance Thresholds
L=size(CorrData.R12b,1);
R12boot=[];
R12ABboot=[];
R12sboot=[];
for k=1:NB
    i=randsample(L,L,1);
    R12boot=[R12boot;mean(CorrData.R12b(i,:))];
    R12ABboot=[R12ABboot;mean(CorrData.R12ABb(i,:))];
    R12sboot=[R12sboot;mean(CorrData.R12sb(i,:))];
end

%Appending Significance Threholds to data structure
CorrData.R12se=std(R12boot);
CorrData.R12ABse=std(R12ABboot);
CorrData.R12sse=std(R12sboot);

%Computing Efficacy and Contribution
i=find([CorrData.R12]==max(CorrData.R12));
L=round(dT/1000*Fsd);
n=i-L:i+L;
R12=CorrData.R12(n);
R12AB=CorrData.R12AB(n);
R12ABse=CorrData.R12ABse(n);
i=find(R12>R12AB+R12ABse*NSE);
CorrData.Efficacy=sum(R12(i)-R12AB(i))/Fsd/CorrData.lambda1;
CorrData.Contribution=sum(R12(i)-R12AB(i))/Fsd/CorrData.lambda2;

%Adding to Data Structure
CorrData.NB=NB;
CorrData.NSE=NSE;
CorrData.dT=dT;

%Plotting Results
if strcmp(Disp,'y')
	subplot(311)
    plot(CorrData.Tau,CorrData.R11AB,'k','linewidth',2)
	hold on
	ylabel('Correlation (spies^2/sec^2')
	hold off
	title('Presynaptic - R11(T)')
	hold off
    
	subplot(312)
    plot(CorrData.Tau,CorrData.R22AB,'k','linewidth',2)
	hold on
	ylabel('Correlation (spies^2/sec^2')
	hold off
	title('Postsynaptic - R22(T)')
	hold off
    
    subplot(313)
	plot(CorrData.Tau,CorrData.R12,'k','linewidth',2)
	hold on
    plot(CorrData.Tau,CorrData.R12AB+CorrData.R12ABse*NSE,'r')
    %plot(CorrData.Tau,CorrData.R12s+CorrData.R12sse*3,'color',[.4 .4 .4])
	ylabel('Correlation (spies^2/sec^2')
	title(['Unit 1 vs 2 (blue), Trial Shuffled + ' num2str(NSE,2) ' SE (red)'])
    plot(CorrData.Tau,CorrData.R12AB,'g')
    plot(CorrData.Tau,CorrData.R12s,'color',[1 1 1]*.5)
    plot(CorrData.Tau,CorrData.R12sse,'color',[1 1 1]*.5)
	hold off
end