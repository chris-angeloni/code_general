%
%function [XStat,P]=bootstrap(X,N,stat,L)
%
%
%       FILE NAME       : BOOT STRAP
%       DESCRIPTION     : Bootstrap algorithm used to compute significance
%			  of a statistical measure performed on the array X
%
%       X		: Data Array
%	N		: Number of itterations for bootstrap
%	stat		: Statistical measure for which to bootstrap.
%			  'mean' or 'var' or 'std'
%	L		: Number of bins used for XStat
%	Res		: Subtract mean value of XStat and obtain residuals
%			  'y' or 'n', Default=='y'
%
%Returned Variables
%	XStat		: Array of values for corresponding statistic
%			  performed on X
%	P		: Probability distribution for Std
%
function [XStat,P]=bootstrap(X,N,stat,L,Res)

%Input Arguments
if nargin<5
	Res='y';
end

%Bootstraping for N itterations
if strcmp(stat,'mean')
	if strcmp(Res,'y')
		Mean=mean(X);
	else
		Mean=0;
	end
	for k=1:N
		%Displaying Output
		if k/100==round(k/100)
		clc
		disp(['Bootstrap Iteration: ' int2str(k) ' of ' int2str(N)])
		end

		%Bootstraping Mean
		index=round((length(X)-1)*rand(size(X)))+1;
		Y(k)=mean(X(index))-Mean;
	end
elseif strcmp(stat,'var')
	if strcmp(Res,'y')
		Var=var(X);
	else
		Var=0;
	end
	for k=1:N
		%Displaying Output
		if k/100==round(k/100)
		clc
		disp(['Bootstrap Iteration: ' int2str(k) ' of ' int2str(N)])
		end

		%Bootstraping Variance
		index=round((length(X)-1)*rand(size(X)))+1;
		Y(k)=var(X(index))-Var;
	end
elseif strcmp(stat,'std')
	if strcmp(Res,'y')
		Std=std(X);
	else
		Std=0;
	end
	for k=1:N
		%Displaying Output
		if k/100==round(k/100)
		clc
		disp(['Bootstrap Iteration: ' int2str(k) ' of ' int2str(N)])
		end

		%Bootstraping Standard Deviation
		index=round((length(X)-1)*rand(size(X)))+1;
		Y(k)=std(X(index))-Std;
	end
end

%Generating Probability Distribution
[P,XStat]=hist(Y,L);

