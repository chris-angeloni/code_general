%
%function [Fs,p]=plierd(x,Fs,L,epsilon)
%	
%	FILE NAME 	: P LI ER D
%	DESCRIPTION 	: Comparison of ER method vs LI method as a function 
%			  of Fs.  Finds the correlation coeficient (p) vs Fs
%
%	x		: Input Glotal Speech Signal
%	Fs		: Sampling Frequency 
%	L		: Number of times to downsample by factor of 2
%	epsilon		: Optional for ER Method - default is 1E-11
%
function [Fs,p]=plierd(x,Fs,L,epsilon)

%Checking Arguments
if nargin==3
        epsilon=1E-11;
end

%Down sampling L times for ER Method
xer=x;
for k=1:L
	xer=decimate1d(xer);
end
Fser=Fs/2^(L);

%Finding To - ER Method
[Toer]=er(xer,Fser,epsilon);

%Finding To vs Fs for LI Method
Toli=[];
xli=x;
Fsli=Fs;
for k=1:L+1
	[To]=titze(xli,Fsli(k));
	N=size(Toli);
	N=min([length(To) N(1)]);
	if k~=1
		Toli=[Toli(1:N,:) To(1:N)'];
	else
		Toli=To';
	end
	xli=decimate1d(xli);
	Fsli(k+1)=Fs/2^(k);
end
Fs=Fsli(1:L+1);

%Finding Correlation Coefficient vs Fs
for k=1:L+1
	[Toerm,Tolim]=fomatch(Toer,Toli(:,k)');
	C=corrcoef(Toerm,Tolim);
	p(k)=C(1,2);
end



