%
%function [Fk]=criticalband(overlap)
%
%	FILE NAME 	: CRITICAL BAND
%	DESCRIPTION 	: Finds the critical band cutoff frequencies for a 
%			  1/3 octave critical band filter bank.
%			  See Picone, Proceedings IEEE, Vol. 79, No. 4, 1991, 
%			  pp. 1214
%
%	overlap		: Percent overlap factor for filters: [0,100%]
%			  Default = 0 %
%RETUERNED VARIABLES
%
%	Fk		: Cutoff frequency array
%
function [Fk]=criticalband(overlap)

%Input arguments
if nargin<1
	overlap=0;
end

%Initializing Zero-Cutoff 
k=1;
Fk(k,1)=0;
Fk(k,2)=100;
eps=1E-9;

%Using gradient algorithm to solve for cutoff frequencies
while Fk(k,1)<20000

	f1=Fk(k,1);
	f2=100;		%starting value for search

	Y1=f1-f2+25+75*(1+1.4*((f1+f2)/2000)^2)^0.69;

	while abs(Y1)>eps
		Y1=f1-f2+25+75*(1+1.4*((f1+f2)/2000)^2)^0.69;
		Y2=f1+eps-f2+25+75*(1+1.4*((f1+f2+eps)/2000)^2)^0.69;
		m=(Y1-Y2)/eps;
		f2=f2-Y1/m;
	end

	%Saving upper cutoff frequency onto array
	Fk(k,2)=f2;

	%Finding lower cutoff frequency based on percent overlap
	Fk(k+1,1)=f2-overlap/100*(f2-f1);
	
	%Incrementing counter
	k=k+1;
end

%Choosing Values < 20kHz
index=min(find(Fk(:,2)>=20000));
Fk=Fk(1:index-1,:);
