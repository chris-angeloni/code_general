%
%function []=batchsynapticraddy(header,lambda,T1,T2,N,Nfixed,r,rfixed,Fs,M1,M2,L1,L2)
%
%       FILE NAME       : BATCH SYNAPTIC RADDY
%       DESCRIPTION     : Synaptic Noise Current Signal Generator used by 
%			  Raddy Ramos to test the input-output properties of 
%			  a collection of neurons from a large enseble. 
%			
%			  Adds presynaptic EPSC and IPSC afferent inputs that
%			  have Poisson distributed inter-event times.
%
%			  Input firing rates are constant
%
%			  Amplitude of EPSCs and IPSCs are fixed (1 microAmp)! 
%
%	lambda		: Presynaptic firing rates
%	T1		: EPSC/IPSC Onset Time (msec)
%	T2		: EPSC/IPSC Offset Time (msec)
%	N		: Total number of presynaptic inputs (N>2)
%	Nfixed		: Array containing the number of fixed presynaptic 
%			  afferents that will be tested 
%	r		: Array containing the Ratio of Excitation to 
%			  Inhibition (Expressed as a r=NE/NI) for variable 
%			  inputs
%	rfixed		: Array containing the Ratio of Excitation to 
%			  Inhibition (Expressed as  r=NE/NI) for fixed inputs
%	Fs		: Sampling Rate
%	M1		: Number of samples used for the first Nfixed
%	M2		: Number of samples used for the last Nfixed
%	L1		: Number of Experiment Trials for the first Nfixed
%	L2		: Number of Experiment Trials for the last Nfixed
%
%RETURNED VARIABLLES
%
function []=batchsynapticraddy(header,lambda,T1,T2,N,Nfixed,r,rfixed,Fs,M1,M2,L1,L2)

%Determining the Data size constnat
alphaM=(M2/M1)^(1/(length(Nfixed)-1));;
alphaL=(L2/L1)^(1/(length(Nfixed)-1));;

%Generating and Saving Synaptic Input Signals
for k=1:length(Nfixed)
	M=round(M1*alphaM.^(k-1))
	L=round(L1*alphaL.^(k-1))
	for l=1:L

		%Generating Input Signals
		clc
		disp(['Trial Number: ' int2str(l)  ' of ' int2str(L)])
		disp(setstr(10))
		[SynapticNoiseX,Inputs]=synapticnoiseraddy(lambda...
		,T1,T2,N,Nfixed(k),r(k),rfixed(k),Fs,M);

		%Saving Signal
		NE=int2strconvert(Inputs.NE,3);
		NI=int2strconvert(Inputs.NI,3);
		NEf=int2strconvert(Inputs.NEfixed,3);
		NIf=int2strconvert(Inputs.NIfixed,3);
		Trial=int2strconvert(l,4);
		filename=[header '_NEv' NE '_NIv',...
			NI '_NEf' NEf '_NIf' NIf '_Trial' Trial];
		f=['save ' filename ' Inputs SynapticNoiseX'];
		eval(f) 
	end
end
