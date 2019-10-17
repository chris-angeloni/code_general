%
%function []=ifxcorroptimize()
%
%       FILE NAME       : IF XCORR OPTIMIZE
%       DESCRIPTION     : Integrate-Fire model neuron prediction optimization
%			  using a correlation based approach. The model tries
%			  to optimize the intracellular parameters for 
%			  predicting a neurons response for a given
%			  intracellular injected current. 
%
%	Im		: Injected intracellular current
%	In		: Intracellular noise (length must be >= 2xlength(Im)
%	Fs		: Sampling rate for Im
%	spet1		: Real neuronal response spike train for trial 1
%	spet2		: Real neuronal response spike train for trial 2
%	Fs12		: Sampling rate for spet1 and spet2
%
%RETURNED VARIABLE
%
function []=ifxcorroptimize(Im,In,Fs,spet1,spet2,FsSpet,T,FsCorr)

%Initializing Parameters
Tau=5;
Tref=2;
Nsig=1;
SNR=5;
beta0=[Tau;Nsig;SNR];

%Computing Real Across Trial Correlation
Rreal=xcorrspikeb(spet1,spet2,FsSpet,FsCorr,T,30);

%Generating Input Data Strucuture
X.Im=Im;
X.In=In;
X.Fs=Fs;
X.FsCorr=FsCorr;
X.FsSpet=FsSpet;
X.T=T;
X.Rreal=Rreal;

betaL=[3;.2; 0];
betaU=[20;5;10];

%Optimizing Integrate Fire Model
options=optimset('fminsearch');
%options=optimset(options,'DiffMaxChange',2,'DiffMinChange',1);
options=optimset(options,'DiffMinChange',2);
%beta=fminsearch('ifxcorrmse',beta0,options,X);
beta=fminbnd('ifxcorrmse',betaL,betaU,options,X);

%[beta,R,J]=nlinfit(X,Rreal,'ifxcorrmse',beta);
%nlintool(X,Rreal,'ifxcorr',beta,.05);

