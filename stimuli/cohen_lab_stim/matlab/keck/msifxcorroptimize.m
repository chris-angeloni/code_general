%
%function [Rmodel,Rreal,Tau,Tref,tdelay,Nsig,SNR]=msifxcorroptimize(spetpre,spetpost,Fs)
%
%       FILE NAME       : MS IF XCORR OPTIMIZE
%       DESCRIPTION     : Mono-Synaptic Integrate and fire model neuron 
%			  Xcorrelation Optimization Routine. The MS IF
%			  Neuron is Simulated using the Pre Synaptic
%			  Spike Train as Input. The Optimal Parameters of
%			  the Post Synaptic Neuron are derived by minimizing
%			  the mean-square-error between the data xcorrelation
%			  and the model xcorrelation.
%
%			  Model Cross Correlations are performed between 
%			  the real Pre Synaptic Neuron and the Model
%			  Post Synaptic Neuron. These are compared with the 
%			  Real Pre-Post Synaptic Neuron Cross Correlation.
%
%	spetpre		: Pre-Synaptic Spike Event Times Array
%	spetpost	: Post-Synaptic Spike Event Times Array
%	Fs		: Sampling Rate for spetpre and spetpost
%
%OUTPUT SIGNAL
%	Rmodel		: XCorrealtion Function Between the Real Presynaptic
%			  and the Modeled Post Synaptic Neurons
%	Rreal		: XCorrelation Function Between the Real Pre and Post 
%			  Synaptic Neurons
%	Tau		: Optimal Membrane Time Constant
%	Tref		: Optimal Refractory Period
%	tdelay		: Optimal Delay
%	Nsig		: Optimal Normalized Threshold
%	SNR		: Optimal Intracellular Signal-to-Noise Ratio
%
function [Rmodel,Rreal,Tau,Tref,tdelay,Nsig,SNR]=msifxcorroptimize(spetpre,spetpost,Fs)

%Initializing Parameters
Tau=5;
Tref=1;
tdelay=2;
Nsig=3;
SNR=3;
beta=[Tau  Nsig SNR];
FsCorr=1000;

%Computing Real XCorrelation
Rreal=xcorrspikeb(spetpre,spetpost,Fs,FsCorr,.5,30)';
figure,pause(0)

%Optimizing MS Integrate Fire Model
%[beta,R,J]=nlinfit([Fs spetpre],Rreal,'msifxcorr',beta);
LBbeta=[1 .5 -5];
UBbeta=[10 5 5];
%options=optimset('lsqcurvefit');
%options=optimset('lsqnonlin');
options=optimset('fminsearch');

%options=optimset(options,'DiffMaxChange',2,'DiffMinChange',.1,'Diagnostics','on','TolX',1,'TolFun',.1,'Display','iter')
%options=optimset(options,'LargeScale','off','DiffMaxChange',2,'DiffMinChange',.1,'Diagnostics','on','TolX',.1,'TolFun',.05,'Display','iter','TypicalX',[10 2 1 2 10])

%beta=lsqcurvefit('msifxcorr',beta,[Fs spetpre],Rreal,LBbeta,UBbeta,options);
%beta=lsqnonlin('msifxcorrabserr',beta,LBbeta,UBbeta,options,[Fs spetpre],Rreal);
beta=fminsearch('msifxcorrabserr',beta,options,[Fs spetpre],Rreal);
%beta=fminbnd('msifxcorrabserr',LBbeta,UBbeta,options,[Fs spetpre],Rreal);



%Extracting Optimal Integrate Fire Parameters
Tau=beta(1);
%Tref=beta(2);
%tdelay=beta(3);
Nsig=beta(2);
SNR=beta(3);

%Finding Optimal Model Correlation
Rmodel=msifxcorr(beta,spetpre);

