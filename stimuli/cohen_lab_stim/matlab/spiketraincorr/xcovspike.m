%
%function [R]=xcovspike(spet1,spet2,Fs,Fsd,T,Disp)
%
%       FILE NAME       : XCOV SPIKE
%       DESCRIPTION     : X-Covariance Function of Spike Train
%
%	spet1,spet2	: Input Spike Event Times
%       Fs		: Samping Rate of SPET
%	Fsd		: Sampling Rate for R(T)
%	T		: X-Correlation Temporal Lag (sec)
%	Disp		: Display : 'y' or 'n'
%			  Default : 'y' 
%
function [R]=xcovspike(spet1,spet2,Fs,Fsd,T,Disp)

%Preliminaries
if nargin<6
	Disp='y';
end

%Converting SPET to a sampled diract impulse array
Ts=1/Fsd;
X1=spet2impulse(spet1,Fs,Fsd);
X2=spet2impulse(spet2,Fs,Fsd);

%Matching Length if X1~=X2
if length(spet1)~=length(spet2)
        if length(X1)<length(X2)
                X2=X2(1:length(X1));
        else
                X1=X1(1:length(X2));
        end
end
M=max(length(X1),length(X2));

%Computing X-Covariance
MaxLag=ceil(T*Fsd);
R=xcorr(X1-mean(X1),X2-mean(X2),MaxLag);
if length(spet1)==length(spet2)
	N=sum(X1*Ts);
	M=length(X1);
	R=R/M;
	VarPois=N/M/Ts^2;			%Variance for Poisson 
	R(MaxLag+1)=R(MaxLag+1)-VarPois;
	R=R/Ts^2/VarPois*Ts^2;
else
	M=max(length(X1),length(X2));
	N1=sum(X1*Ts);
	N2=sum(X2*Ts);
	VarPois1=N1/M/Ts^2;
	VarPois2=N2/M/Ts^2;
	R=R/M/sqrt(VarPois1*VarPois2);
end

%Plotting X-Covariance
if strcmp(Disp,'y')
	plot((-MaxLag:MaxLag)/Fsd,R)
	ylabel('R( T )');
	xlabel('Time Lag - T ( sec )')
end
