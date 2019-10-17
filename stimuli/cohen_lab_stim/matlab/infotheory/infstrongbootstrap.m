%
%function [Istrong,IstrongB]=infstrongbootstrap(B,HSpike,HSpiket,L,NB)
%
%
%   FILE NAME   : INF STRONG BOOT STRAP
%   DESCRIPTION : Bootstraps the mutual information estimate using
%                 the extrapolation procedure of Strong et. al.
%                 (see the Routines INFEXTRAPOLATE and INFEXTRAPOLATEB) 
%
%	B           : Length of Word, number of bits array
%	HSpiket		: Conditional Enthropy per Spike
%	HSpike		: Enthropy per Spike
%	L           : Number of bootstrap itterations
%	NB          : The lowest NB bits to use for the analysis
%                 Uses: B(1:NB)
%RETURNED VARIABLE
%	Istrong		: Information Array - [Mean STD]
%	IstrongB	: Information Bootstrap Values
%
function [Istrong,IstrongB]=infstrongbootstrap(B,HSpike,HSpiket,L,NB)

%Performing L bootstrap itterations
for l=1:L

%	N1=size(HSpike,1);
	N1=NB;
	N2=size(HSpike,2);
	i1=round(rand(1,N1)*(N2-1)+1);
	for k=1:N1
		H(k)=HSpike(k,i1(k));
		Ht(k)=HSpiket(k,i1(k));
	end

	%Extrapolating to infinite word length
	[P,S]=polyfit(1./B(1:NB),H-Ht,1);
	Istrong(l)=polyval(P,0);

end

%Finding mean and std 
IstrongB=Istrong;
Istrong=[mean(Istrong) std(Istrong)];

