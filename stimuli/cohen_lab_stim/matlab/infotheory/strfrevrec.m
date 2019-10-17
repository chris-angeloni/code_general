%
%function [WSTRF1,WSTRF2]=strfrevrec(STRF1,STRF2,spet,Fs,Fss)
%
%       FILE NAME       : STRF REV REC
%       DESCRIPTION     : Reverse Reconstruction STRF Filter
%			  Obtained by computing the optimal wiener filter 
%			  STRF (See Hayes).  Takes as input the STRF obtained
%			  using 'rtwstrfdb' or 'rtwstrflin' and the output 
%			  spike train
%
%	STRF1,STRF2	: Contra and Ipsi Lateral STRFs 
%	spet		: Array of spike event times in sample number
%	Fs		: Sampling rate for spet
%	Fss		: Sampling Rate for computing autocorrelation of 
%			  spike train.  This must be the same as the
%			  sampling rate used for STRF
%	
%	RETURNED VALUES 
%	WSTRF1, WSTRF2	: Contra and Ipsi Wiener Inverse Reconstruction STRFs
%
function [WSTRF1,WSTRF2]=strfrevrec(STRF1,STRF2,spet,Fs,Fss)

%Computing Spike Train Auto-Correlation Function
Rxx=xcorrspikeb(spet,spet,Fs,Fss,size(STRF1,2)/Fss*1.1,30,'n','n');

%Generating Toeplitz Cross-Correlation Matrix
N=(length(Rxx)-1)/2;
RRxx=toeplitz(Rxx(N+1:N+size(STRF1,2)));
RRxxinv=inv(RRxx);

%Computing Reverse Reconstruction STRF. Obtained by solving 
%Wiener-Hopf Equation: For a given input x(t) and output y(t) 
%
%	RRxx * W = Rxy  --> W=inv(RRxx) * Rxy
%
%where RRxx is the Toeplitz autocerrelation matrix of x(t) 
%and Rxy is the cross correlation between x(t) and y(t).  
%As desired W is the optimal Wiener Filter for Reconstructing 
%y(t) from x(t)
%
for k=1:size(STRF1,1)
	Rxy1=STRF1(k,:)';	%Reverse Correlation
	Rxy2=STRF2(k,:)';	%Reverse Correlation
	W1=RRxxinv*Rxy1;	%Wiener Filter
	W2=RRxxinv*Rxy2;	%Wiener Filter
	WSTRF1(k,:)=W1';		
	WSTRF2(k,:)=W2';		
end
