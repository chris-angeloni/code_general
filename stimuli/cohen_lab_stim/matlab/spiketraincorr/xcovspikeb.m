%
%function [R]=xcorrspikeb(spet1,spet2,Fs,Fsd,T,B,Disp)
%
%       FILE NAME       : XCOV SPIKE B
%       DESCRIPTION     : X-Covariance Function of Spike Train Performed
%			  By binning the Spike Train into Blocks and 
%			  Averaging individual X-Cov
%
%	spet1,spet2	: Input Spike Event Times
%       Fs		: Samping Rate of SPET
%	Fsd		: Sampling Rate for R(T)
%	T		: X-Correlation Temporal Lag (sec)
%	B		: Block Size (sec)
%	Disp		: Display : 'y' or 'n'
%			  Default : 'y' 
%
function [R]=xcorrpikeb(spet1,spet2,Fs,Fsd,T,B,Disp)

%Preliminaries
if nargin<7
	Disp='y';
end

%Block Size and Temporal Lag
NB=ceil(B*Fs);
MaxLag=ceil(T*Fsd);

%Checking to See if spet1==spet2 and Computing X-Corr
count=1;
Ts=1/Fsd;
if length(spet1)~=length(spet2)
	%Binning and Computing X-Correlation
	R=zeros(1,2*MaxLag+1);
	M=0;					%Number of X-Corr Samples
	N1=0;
	N2=0;
	while (count-1)*NB<min(max(spet1),max(spet2)) 
		index1=find(spet1<NB*count & spet1>NB*(count-1));
		index2=find(spet2<NB*count & spet2>NB*(count-1));
		X1=spet2impulse(spet1(index1)-NB*(count-1),Fs,Fsd);
		X2=spet2impulse(spet2(index2)-NB*(count-1),Fs,Fsd);
		if length(X1)<length(X2)
        	        X2=X2(1:length(X1));
		elseif length(X1)>length(X2)
			X1=X1(1:length(X2));
		end
		R=R+xcorr(X1-mean(X1),X2-mean(X2),MaxLag);
		M=M+length(X1);
		N1=N1+sum(X1*Ts);		%Number of Spikes in 1
		N2=N2+sum(X2*Ts);		%Number of Spikes in 2
		count=count+1;
	end
	VarPois1=N1/M/Ts^2;			%Variance for Poisson 
	VarPois2=N2/M/Ts^2;			%Variance for Poisson 
	R=R/M/sqrt(VarPois1*VarPois2);
else
	%Binning and Computing X-Correlation
	R=zeros(1,2*MaxLag+1);
	M=0;					%Number of X-Corr Samples
	while (count-1)*NB<max(spet1)
		index=find(spet1<NB*count & spet1>NB*(count-1));
		X=spet2impulse(spet1(index)-NB*(count-1),Fs,Fsd);
		R=R+xcorr(X-mean(X),X-mean(X),MaxLag);
		M=M+length(X);
		count=count+1;
	end
	N=length(spet1);			%Number of Spikes
	R=R/M;
	VarPois=N/M/Ts^2;			%Variance for Poisson 
	R(MaxLag+1)=R(MaxLag+1)-VarPois;
	R=R/Ts^2/VarPois*Ts^2;
end

%Plotting X-Correlation
if strcmp(Disp,'y')
	plot((-MaxLag:MaxLag)/Fsd,R)
	ylabel('R( T )');
	xlabel('Time Lag - T ( sec )')
end
