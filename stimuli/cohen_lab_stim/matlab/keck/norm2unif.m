%
%function [Y]=norm2unif(X,a,b,flag,meanX,stdX)
%
%	
%	FILE NAME 	: NORM 2 UNIF
%	DESCRIPTION 	: Transforms a normally distributed random variable to 
%			  a uniformily distributed random variable
%
%	X		: Input normally distributed RV
%	a, b		: Min and Max range for uniform distribution
%			  (Default: a=0,b=1)
%	flag		: Erf function used to transform Norm to Unif
%			  'erf1' == erf(x*0.7)  (Default)
%			  'erf2' == erf(x)
%			  'erf3' == sign(x) [ .5 - 1./(1 + 10.^(-x/1.4)) ];
%	stdX		: Standard deviation of X ( Optional )
%	meanX		: Mean of X	( Optional )
%	Y		: Ouput uniformly distributed RV
%
function [Y]=norm2unif(X,a,b,flag,meanX,stdX)

%Finding Normal Parameters if not given
if nargin < 2
	a=0;
	b=1;
end
if nargin < 4
	flag='erf1';
end
if nargin < 5
	meanX=mean(X);
end
if nargin < 6
	stdX=std(X);
end

%Normalyzing X so that it follows N(0,1) Distribution
if ~( stdX==1 & meanX==0 )
	X=( X-mean(X) ) / stdX;
end

if strcmp(flag,'erf1')
	Y=erf(X*0.7);
elseif strcmp(flag,'erf2')
	Y=erf(X);
elseif strcmp(flag,'erf3')
	%Applying Non-Linear Transformation to convert Normal -> Uniform
	%This is a similar trasnformation to the ERF function but it 
	%distorts the tails of the distribution so that the resulting
	%distribution is completely flat unlike the ERF transformation
	%which gives a distribution that is skewed at the extremeities
	%To test this try : hist(erf(randn(1,1024*64)),20)
	Y=zeros(size(X));
	indexp=find(X>0);
	indexn=find(X<0);
	Y(indexp)=  .5 - 1./( 1 + 10.^( X(indexp)/1.4 ) ) ;
	Y(indexn)= -.5 + 1./( 1 + 10.^( -X(indexn)/1.4 ) ) ;
end

%Normalizing Between [a , b]
Y= Y*(b-a)/2 + (b-a)/2 + a;
