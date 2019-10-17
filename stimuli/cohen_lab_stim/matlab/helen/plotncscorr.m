%
%function  []=plotncscorr(R)
%
%DESCRIPTION: Correlates multi channel data from NCS file
%
%   R		: Correlation data structure containg multi channel correlation
%
%RETURNED VARIABLES
%
%Monty A. Escabi, Feb. 2004
%
function  []=plotncscorr(R)

%Correlation Matrix Size
N1=size(R,1);
N2=size(R,2);

%Finding Scaling Factors
Max=-1E6;
Min=1E6;
for k=1:size(R,1)
	for l=1:size(R,2)
		Max=max([Max R(k,l).Corr]);
		Min=min([Min R(k,l).Corr]);
	end
end

%Plotting Correlations
for k=1:size(R,1)
	for l=1:size(R,2)
		subplot(N1,N2,l+(k-1)*N2)
		plot([min(R(k,l).Tau) max(R(k,l).Tau)],[0 0],'k-.')
		hold on
		plot(R(k,l).Tau,R(k,l).Corr,'b')
		axis([min(R(k,l).Tau) max(R(k,l).Tau) 1.1*Min 1.1*Max])
		title([int2str(R(k,l).channels(1)) ' vs. ' int2str(R(k,l).channels(2))])
	end
end
