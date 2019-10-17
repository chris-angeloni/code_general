%
%function [data]=strfsimulate2(sprfile,Y,MdB,ModType,SoundType,Nsig,SNR,Tau,Tref,Fs,Fsd,flag,In,detrendim,detrendin,L,MaxT);
% 
%Funcntion	Simulate and determine the relationship between intracellular
%		threshold, response spike rate, STRF energy, and FSI.
%
%		Uses a spectro-temporal integrate fire model neuron to estimate
%		output spike train, STRF, STRF Energy, FSI etc.
%
%		Removes the integrate-fire time constant from the intracellular
%		current prior to simulating. This preserves the time-constant
%		from the STRF and removes the bias that would result from the 
%		intracellular integration.
%Input
%	Y		: injected current
%	sprfile		: Spectrotemporal envelope input file
%	MdB		: Modulation depth
%	ModType		: linear or dB Modulation, 'Lin' or 'dB' 
%	SoundType	: 'MR' or 'RN'
%	Nsig		: Number of standard deviations of the
%			  intracellular voltage to set the spike threshold
%	SNR		: Signal to noise ratio (dB)
%	Tau		: Time constant (msec)
%	Tref		: Refractory period (msec)
%	Fs		: Sampling Rate for Y
%	Fsd		: Desired Sampling Rate for generating SPET
%	flag		: flag = 0: Voltage variance is constant (Default)
%			  sig_m = (Vtresh-Vrest)/Nsig
%			  SNR is determined by Current
%		       1: Total Voltage variance is constant
%			  sig_tot = (Vtresh-Vrest)/Nsig
%			  SNR is determined by Current
%		       2: Voltage Variance is Constant
%			  SNR is determined by the Voltage
%  		       3: Total Voltage Variance is constant
%			  sig_tot = (Vtresh-Vrest)/Nsig
%			  SNR is determined by the Voltage
%
%       In              : Noise current signal
%       detrendim       : Removes time constant from Im if desired ('y' or 'n')
%                         This detrending is usefull if you
%                         know the desired intracellular voltage Vm, but not
%                         the intracellular current.
%       detrendin       : Removes time constant from Im if desired ('y' or 'n')
%                         This detrending is usefull if you
%                         know the desired intracellular noise voltage but
%                         not the intracellular noise current.
%			  to reestimating STRF
%	L		: Number of blocks to analyze (Default==inf)
%	MaxT		: Maximum Delay for STRF (sec), Default = 0.05 sec
%
%Output
%	data: Data stored as a structured array with the following  fields
%			  
%	timeaxis	: Time Axis
%	freqaxis	: Frequency Axis (Hz)
%	STRF1 , STRF2	: Spectro-Temporal Receptive Field
%	PP		: Power Level
%	Wo1, Wo2	: Zeroth-Order Kernels ( Average Number of Spikes/Sec )
%	No1, No2	: Number of Spikes
%	SPLN		: Sound Pressure Level per Frequency Band
%	FSI		: Feature selectivity index - derived from CDF
%	FSIe		: Excitatory Feature selectivity index - derived from CDF
%	FSIi		: Inhibitory Feature selectivity index - derived from CDF
%	SI		: Scale of similarity index
%	SIHist		: statistics of similarity index of whole STRF
%			  and STRF at different time
%	SIHistr		: statistics of similarity index of whole STRF
%			  and STRF at different time for random spet
%	SIHiste		: statistics of similarity index of whole excitatory
%			  STRF and STRF at different time
%	SIHister	: statistics of similarity index of whole excitatory
%			  STRF and STRF at different time for random spet
%	SIHisti		: statistics of similarity index of whole inhibitory
%			  STRF and STRF at different time
%	SIHistir	: statistics of similarity index of whole inhibitory
%			  STRF and STRF at different time for random spet
%	p1		: Corrcoeff array for channel 1
%	p2		: Corrcoeff array for channel 1
%	p1e		: Excitatory Corrcoeff array for channel 1
%	p2e		: Excitatory Corrcoeff array for channel 1
%	p1i		: Inhibitory Corrcoeff array for channel 1
%	p2i		: Inhibitory Corrcoeff array for channel 1
%	p1r		: Random corrcoeff array for channel 1
%	p2r		: Random corrcoeff array for channel 1
%	p1er		: Random excitatory Corrcoeff array for channel 1
%	p2er		: Random excitatory Corrcoeff array for channel 1
%	p1ir		: Random inhibitory Corrcoeff array for channel 1
%	p2ir		: Random inhibitory Corrcoeff array for channel 1
%
% Copyright ANQI QIU
% 03/14/2002
% Edited Monty A. Escabi, 03/27/2003
% Edited Monty A. Escabi, 09/21/2003

function [data]=strfsimulate2(sprfile,Y,MdB,ModType,SoundType,Nsig,SNR,Tau,Tref,Fs,Fsd,flag,In,detrendim,detrendin,L,MaxT);

%Initialize some parameters
if nargin<16
	L=inf;
end;
if nargin<17
	MaxT=0.1;   
end

if SoundType=='MR'
   k=1:1706;
else
   k=1:1500;
end;

%Integrate fire neuron - Removes time constant from intracellular current
%Tref=1;
Vtresh=-50;           %threshold for the action potential
Vrest=-65;            %the rest potential of the membrane
[X,Vm,R,C,sigma_m,sigma_i]=integratefire(Y,Tau,Tref,Vtresh,Vrest,Nsig,SNR,Fs,flag,In,detrendim,detrendin);

%Convert impulse to spike train with desired sample frequency 
[spet]=impulse2spet(X,Fs,Fsd);

%Generate Trigger Signal
Trig=round(((k-1)*728+1)/Fs*Fsd);

%Resimulate and reconstruct STRF
clear taxis faxis;
[timeaxis,freqaxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=rtwstrfdb(sprfile,0,MaxT,spet,Trig,Fsd,60,MdB,ModType,SoundType,50,'float');
%[timeaxis,freqaxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=rtwstrfdbint(sprfile,0,MaxT,spet,Trig,Fsd,60,MdB,ModType,SoundType,100,4,'float');

%Significant STRFs
[STRF1s,Tresh]=wstrfstat(STRF1,0.001,No1,Wo1,PP,MdB,ModType,SoundType,'dB');
[STRF2s,Tresh]=wstrfstat(STRF2,0.001,No2,Wo2,PP,MdB,ModType,SoundType,'dB');

%Generating a random spet (20 minutes)
spetr=poissongen(10*ones(1,1200),1,Fsd);

%SI and FSI index statistics
[p1,p2,p1e,p2e,p1i,p2i,spindex1,spindex2]=rtwstrfdbvar(STRF1s,STRF2s,sprfile,0,MaxT,spet,Trig,Fsd,60,MdB,SoundType,50,'float');
[p1r,p2r,p1er,p2er,p1ir,p2ir,spindex1r,spindex2r]=rtwstrfdbvar(STRF1,STRF2,sprfile,0,MaxT,spetr,Trig,Fsd,60,MdB,SoundType,50,'float');

%FSI on Full STRF
[FSI]=fsi(p1,p1r);
[SIHist,SI]=hist(p1,-3:.0626:1);
[SIHistr,SI]=hist(p1r,-3:.0626:1);

%FSI on Excitation
[FSIe]=fsi(p1e,p1er);
[SIHiste,SI]=hist(p1e,-3:.0626:1);
[SIHister,SI]=hist(p1er,-3:.0626:1);

%FSI on Inhibition
[FSIi]=fsi(p1i,p1ir);
[SIHisti,SI]=hist(p1i,-3:.0626:1);
[SIHistir,SI]=hist(p1ir,-3:.0626:1);

%Adding Data to Data Structure
data.timeaxis=timeaxis;
data.freqaxis=freqaxis;
data.STRF1=STRF1;
data.STRF2=STRF2;
data.STRF1s=STRF1s;
data.STRF2s=STRF2s;
data.PP=PP
data.Wo1=Wo1;
data.Wo2=Wo2;
data.No1=No1;
data.No2=No2;
data.SPLN=SPLN;
data.FSI=FSI;
data.FSIe=FSIe;
data.FSIi=FSIi;
data.SI=SI;
data.SIHist=SIHist;
data.SIHistr=SIHistr;
data.SIHiste=SIHiste;
data.SIHister=SIHister;
data.SIHisti=SIHisti;
data.SIHistir=SIHistir;
data.p1=p1;
data.p2=p2;
data.p1e=p1e;
data.p2e=p2e;
data.p1i=p1i;
data.p2i=p2i;
data.spindex1=spindex1;
data.spindex2=spindex2;
data.p1r=p1r;
data.p2r=p2r;
data.p1er=p1er;
data.p2er=p2er;
data.p1ir=p1ir;
data.p2ir=p2ir;
data.spindex1r=spindex1r;
data.spindex2r=spindex2r;
