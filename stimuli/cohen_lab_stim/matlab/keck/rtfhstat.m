%
%function [RTFHs,T1,T2]=rtfhstat(RTFH,p)
%
%       FILE NAME       : RTFH STAT
%       DESCRIPTION     : Performs a significance test and determines
%			  The statistically significant portion of the RTFH
%
%	RTFH		: Ripple Transfer Function Histogram
%	p		: Significance Probability
%
%RETURNED VALUES
%
%	RTFHs		: Statistically siginificant RTFH
%	T1		: Lower Threshold
%	T2		: Upper Threhold
%
function [RTFHs,T1,T2]=rtfhstat(RTFH,p)

%Finding Number of Action Potentials
No=sum(sum(RTFH));

%Number of Bins in Histogram
L=size(RTFH,1)*size(RTFH,2);

%Mean,Var and Std, for the Number of Spikes Per Bin
M=No/L;
V=(No*L-1)/L^2;
S=sqrt(V);

%Finding Significant RTFH
RTFHs=RTFH;
Tresh=sqrt(2)*erfinv(1-2*p);
T1=M-Tresh*S;
T2=M+Tresh*S;
[i,j]=find(RTFH>T1 & RTFH<T2);
for k=1:length(i)
	RTFHs(i(k),j(k))=M;
end

