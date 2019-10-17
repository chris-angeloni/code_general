%
%function  [Area]=coherearea(C,f1,f2)
%
%DESCRIPTION: Computes the significant area in the coherence between f1 and f2
%
%   C		: Coherence Data Structure
%   f1		: Lower frequency for area estimate
%   f2		: Upper frequency for area estimate
%
%RETURNED VARIABLES
%
%    Area	: Area Data Structure
%		  dF : Frequency Range
%
%Monty A. Escabi, Aug. 24, 2004, (helen aug 15,2005)
%
function  [Area]=coherearea(C,f1,f2)

%Computing Area
df=C(1,1).Faxis(2)-C(1,1).Faxis(1);
for k=1:size(C,1)
	for l=1:size(C,2)

		index01=find(C(k,l).Faxis>=f1 & C(k,l).Faxis<=f2);
		Area(k,l).A01=C(k,l).Cxy(index01)
       

		index=find(C(k,l).Faxis>=f1 & C(k,l).Faxis<=f2 );
		Area(k,l).dF=length(index)*df;

	end
end


