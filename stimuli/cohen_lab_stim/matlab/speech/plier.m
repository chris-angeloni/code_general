%
%function [Fs,p]=plier(x,Fs,L,epsilon,ATT)
%	
%	FILE NAME 	: P LI ER
%	DESCRIPTION 	: Comparison of ER method vs LI method as a function 
%			  of Fs.  Finds the correlation coeficient (p) vs Fs
%
%	x		: Input Glotal Speech Signal
%	Fs		: Sampling Frequency 
%	L		: Maximum Downsampling Factor
%
%Optional
%	epsilon		: Zero-Crossing precision - default is 1E-11
%	ATT		: Filter Attenuation - default is 120dB
%
function [Fs,p]=plier2(x,Fs,L,epsilon,ATT)

%Checking Arguments
if nargin<4
        epsilon=1E-11;
	ATT=120;
elseif nargin<5
	epsilon=1E-11;
end

%Downsampling by factor L for ER Method
xer=x(1:L:length(x));
Fser=Fs/L;

%Finding To - ER Method
[Toer]=er(xer,Fser,epsilon,ATT);

%Finding To vs Fs for LI Method
Toli=[];
xli=x;
Fsli=Fs;
for k=1:L
	[To]=titze(xli,Fsli(k));
	N=size(Toli);
	N=min([length(To) N(1)]);
	if k~=1
		Toli=[Toli(1:N,:) To(1:N)'];
	else
		Toli=To';
	end
	xli=x(1:k+1:length(x));
	Fsli(k+1)=Fs/(k+1);
end
Fs=Fsli(1:L);

%Finding Correlation Coefficient vs Fs
for k=1:L
	[Toerm,Tolim]=fomatch(Toer,Toli(:,k)');
	C=corrcoef(Toerm,Tolim);
	p(k)=C(1,2);
end
