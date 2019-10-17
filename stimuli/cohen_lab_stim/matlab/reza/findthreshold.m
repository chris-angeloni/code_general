%
%function []=findthreshold(Vmc,Vmm,Vtm,Fsc,Fsm)
%
%   FILE NAME       : FIND THRESHOLD
%   DESCRIPTION     : Finds the spike threshold for real data from a cell
%                     recording and for the model prediction from
%                     INTEGRATEFIREADAPT
%
%   Vmc             : Cell membrane potential signal (mV)
%   Vmm             : Model membrane potential signal (mV)
%   Vtm             : Model spike threshold signal (mV)
%   Fsc             : Cell data sampling rate
%   Fsm             : Model data sampling rate
%   delay           : Time before cell threshold to select model threshold
%                     (OPTIONAL, Default=1)
%   N               : Number of standard deviations awaay from diff-noise
%                     required to find a spike threshold (OPTIONAL,
%                     Default=2)
%
%OUTPUT SIGNAL
%
%   Vtc             : Cell threshold at time of spike
%   Vtmc            : Model threshold at time of cell thresholds
%             
%
% (C) Monty A. Escabi, March 2007
%
function [Vtc,Vtmc]=findthreshold(Vmc,Vtm,Fsc,Fsm,delay,N)

%Input Args
if nargin<5
    delay=1;
end
if nargin<6
    N=2; 
end

%Finding STD of sub threshold membrane derivative
iD=find(Vmc<-70);
DVmc=diff(Vmc)*Fsc/1000;
stdDVmc=std(DVmc);

%Finding times of spike threshold
i=find(diff(Vmc)*Fsc/1000>N*stdDVmc);
ii=find(diff(i)>1);
index=floor(i(ii+1)/Fsc*Fsm);

%Finding threshold values in model and cell
Vtc=Vmc(i(ii+1));
Vtmc=Vtm(index-delay);

%Plotting Data
subplot(221)
plot(Vmc(1:end-1),diff(Vmc)*Fsc/1000,'k')
hold on
plot([-200 200],[N N]*stdDVmc,'r-.')
xlabel('Membrane Potential (mV)')
ylabel('Membrane Derivative (mV/ms)')

subplot(222)
plot(Vtc,Vtmc,'ro')
r=corrcoef(Vtc,Vtmc);
title(['r = ' num2str(r(1,2),3)])
xlabel('Cell Threshold (mV)')
ylabel('Model Threshold (mV)')

subplot(223)
[N,X]=hist(DVmc(iD(1:end-1)),10);
bar(X,N/sum(N))
ylabel('Probability')
xlabel('Membrane Derivative (mV/ms)')
title('Distribution for Sub Threshold Derrivative')