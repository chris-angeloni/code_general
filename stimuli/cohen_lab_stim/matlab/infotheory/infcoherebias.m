%
%function [I,IS,Rate,dF,dFW]=infcoherebias(spetA,spetB,T,Fs,df,Fsd,D,NB)
%
%       FILE NAME   : INF COHERE BIAS
%       DESCRIPTION : Extrapolates based on data fraction and Fs to 
%                     remove bias from mutual information estimate 
%                     using coherence approach
%
%                     See the Routine: INFCOHERE
%
%       spetA		: Spike Event Times for trial A 
%       spetB		: Spike Event Times for trial B
%       T           : Recording Time (sec)
%       Fs          : Sampling Rate for 'spet'
%       df          : Minimum desired frequency resoultion array for
%                     for cross- and auto-spectrum measurements
%       Fsd         : Sampling rate array for generating Coherence
%       D           : Inverse Data fractions array (Default=1:5)
%       NB          : Number of bootstraps across data segments	
%                     Default==5
%
%RETURNED VARIABLES
%       I           : Mutual Information
%       IS          : Spike Shuffled Mutual Information
%       Rate		: Spike Rate
%       dF          : Array containing frequency resolutions used for
%                     sampling the coherence
%       dFW         : Array containing frequency resolution of window 
%                     function used for coherence analysis
%
%   (C) Monty A. Escabi, Aug. 2005
%
function [I,IS,Rate,dF,dFW]=infcoherebias(spetA,spetB,T,Fs,df,Fsd,D,NB)

%Input Arguments
if nargin<7
	D=1:5;
end
if nargin<8
	NB=5;
end

%Extrapolating Over Sampling Rate, Data Fraction, Spectral 
%Resolution, and Number of Bootstraps
for k=1:length(Fsd)
	for l=1:length(D)
		for m=1:length(df)
			for n=1:NB

			%Display Information
			clc
			disp(['Fsd = ' int2str(Fsd(k))]);
			disp(['D   = ' int2str(D(l))]);
			disp(['df  = ' int2str(df(m))]);
			disp(['NB  = ' int2str(n) ' of ' int2str(NB)]);
		
			%Computing Information
			offset=round((1-1/D(l))*.95*T*rand);
			ia=find(spetA/Fs<T*1/D(l)+offset & spetA/Fs>offset);
      			ib=find(spetB/Fs<T*1/D(l)+offset & spetB/Fs>offset);
			spetAD=round(spetA(ia)-offset*Fs)+1;
			spetBD=round(spetB(ib)-offset*Fs)+1;
			[I(k,l,m,n),IS(k,l,m,n),Rate(k,l,m,n),Faxis]=...
				infcohere(spetAD,spetBD,Fs,Fsd(k),df(m));

			%Spectral Resolution
			%Check for consistency with INFCOHERE
			NFFT=2.^nextpow2(Fsd(k)/df(m));
			W=kaiser(NFFT,4.5513)';   
			[d,d,d,dFW(m)]=finddtdfw(W,1000,1024*32);
			dF(m)=mean(diff(Faxis));

			end
		end
	end
end