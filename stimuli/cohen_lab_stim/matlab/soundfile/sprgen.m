%
%function [SpecProf]=sprgen(f1,f2,RD,RP,App,Fs,phase,fphase,K,NB,MaxRD,MaxFM,Axis,DF,component)
%	
%	FILE NAME 	: SPR GEN
%	DESCRIPTION 	: Spectral Profile Generator (regenerate)
%
%       f1              : Lower Ripple Frequency
%       f2              : Upper Ripple Frequency
%	RD		: Ripple Density Signal
%	RP		: Ripple Phase Signal
%       App             : Peak to Peak Riple Amplitude 
%	Fs		: Sampling Rate
%	phase		: Sinusoid Initial Phases
%	fphase		: Bandlimit Frequency of Phase Signal
%	K		: Itteration Number
%	NB		: Number of Blocks to divide parameter space into
%                         Note that number of ripple components is NBxNB
%	MaxRD		: Maximum Ripple Density
%	MaxFM		: Maximum Amplitude Modulation Frequency
%       Axis            : Carrier Freqeuncy Axis Type: 'log' or 'lin'
%	DF		: Temporal Dowsampling Factor For Spectral Profile
%
function [SpecProf]=sprgen(f1,f2,RD,RP,App,Fs,phase,fphase,K,NB,MaxRD,MaxFM,Axis,DF,component)

%Parameters
N=32;				%Noise Reconstruction Size  ->> Before changing check RIPNOISE!!!
LL=1000;			%Noise Upsampling Factor    ->> Before changing check RIPNOISE!!!
M=N*LL;				%Number of samples

%Log Frequency Axis
NS=length(phase);
if Axis=='log'
        XMax=log2(f2/f1);
        X=(0:NS-1)/(NS-1)*XMax;
        faxis=f1*2.^X;
else
        faxis=(0:NS-1)/(NS-1)*(f2-f1)+f1;
        X=log2(faxis/f1);
end

%Generating Spectral Profile to Save
%Downsample RP and RD by DF
SpecProf=zeros(length(X),length(RD(1:DF:M)));
if component=='n'
	for k=1:length(X)
		n=1;
		for i=1:NB
			for j=1:NB
				%Adding NB*NB Ripple Profiles
				SpecProf(k,:)=SpecProf(k,:) + sin( 2*pi*RD(n,1:DF:M)*X(k)+RP(i+(j-1)*NB,1:DF:M) ) ;
				n=n+1;
			end
		end
	end

	%Converting to Linear Scale and 
	%Compresing Dynamic Range to [-1 , 0]
	if NB>1
		SpecProf=SpecProf/sqrt(NB*NB/2);
		SpecProf=norm2unif(SpecProf,-1,0,'erf1',0,1);
	else
		SpecProf=1/2*(SpecProf-1);
	end

else

	for k=1:length(X)
		n=1;
		for i=1:NB
			for j=1:NB
				%Adding NB*NB Ripple Profiles
				SpecProf(k,:,n)=sin( 2*pi*RD(n,1:DF:M)*X(k)+RP(i+(j-1)*NB,1:DF:M) ) ;
				n=n+1;
			end
		end
	end

	%Compresing Dynamic Range to [-1 , 0]
	SpecProf=1/2*(SpecProf-1);
end
