%
%function [p1,p2]=poisratestat(lambda1,lambda2,T,p)
%
%       FILE NAME       : POIS RATE STAT
%       DESCRIPTION     : Performs a significance test to determine if the
%			  measured spike rates lambda1 and lambda2 are
%			  statistically different
%
%			  The measured spike rate should be estimated by
%			  lambda=N(T)/T where N(T) is the measured poisson
%			  count variable and T is the measurement time.
%			  Using this estimator the distribution of lambda
%			  assumes the general form:
%
%			  P(l)=exp(-lambda*T)*(lambda*T).^(l*T)/fact(l*T)
%
%			  where l=m/T and m is the number of spikes for N(T)
%
%	lambda1		: Rate for spike sequence 1
%	lambda2		: Rate for spike sequence 2
%	T		: Measurement time
%	p		: Significance Probability
%
%RETURNED VALUES
%
%	p1		: Tail probabilities for lambda1 distribution
%	p2		: Tail probabilities for lambda2 distribution
%
function [p1,p2]=poisratestat(lambda1,lambda2,T,p)

%Spike Count Array - Note that lambda=m/T
Maxm=max(lambda1*T*3,lambda2*T*3);
m=(0:Maxm);
lambda=m/T;

%Checking For Zero Rate
if lambda1==0
	lambda1=1E-6;
end
if lambda2==0
	lambda2=1E-6;
end

%Finding Distributions for lambda1 and lambda2
P1=poisspdf(m,lambda1*T);
P2=poisspdf(m,lambda2*T);

%Finding Tail Probabilities for lambda1 and lambda2
if lambda1<lambda2

	%Finding Intersection for Both Distributions
	for k=2:length(m)
		if P1(k)<P2(k) & P1(k-1)>P2(k-1)
		index=k;
		end
	end

	%Tail Probabilities
	p1=sum(P1(index:length(P1)));
	p2=sum(P2(1:index));

else

	%Finding Intersection for Both Distributions
	for k=2:length(m)
		if P1(k)>P2(k) & P1(k-1)<P2(k-1)
		index=k;
		end
	end

	%Tail Probabilities
	p1=sum(P1(1:index));
	p2=sum(P2(index:length(P1)));

end

%plot(m,P1,'r')
%hold on
%plot(m,P2,'b')
%hold off
