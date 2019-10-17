%
%function  [Area]=ncscoherearea(C,Cs,f1,f2)
%
%DESCRIPTION: Computes the significant area in the coherence between f1 and f2
%
%   C       : Coherence Data Structure
%   Cs      : Significant Coherence Threshold
%   f1      : Lower frequency for area estimate
%   f2      : Upper frequency for area estimate
%
%RETURNED VARIABLES
%
%   Area    : Area Data Structure
%             .A        : Are no sifnificant threhold subtracted
%             .A01      : Area for 0.01 Significance
%             .A05      : Area for 0.01 Significance
%             .dF       : Frequency Range
%             .NormA01  : Normalized area at 0.01 confidence
%             .NormA02  : Normalized area at 0.05 confidence
%
%Monty A. Escabi, Aug. 24, 2004 (Edit Jan 2007)
%
function  [Area]=ncscoherearea(C,Cs,f1,f2)

%Computing Area
df=C(1,1).Faxis(2)-C(1,1).Faxis(1);
for k=1:size(C,1)
	for l=1:size(C,2)

		index01=find(C(k,l).Faxis>=f1 & C(k,l).Faxis<=f2 & C(k,l).Cxy>Cs(k,l).C01);
		index05=find(C(k,l).Faxis>=f1 & C(k,l).Faxis<=f2 & C(k,l).Cxy>Cs(k,l).C05);
        index=find(C(k,l).Faxis>=f1 & C(k,l).Faxis<=f2);
		Area(k,l).A01=sum( C(k,l).Cxy(index01) -  Cs(k,l).C01(index01) ) * df;
		Area(k,l).A05=sum( C(k,l).Cxy(index05) -  Cs(k,l).C05(index05) ) * df;
        Area(k,l).A=sum( C(k,l).Cxy(index) ) * df;
   		Area(k,l).dF=length(index)*df;
        Area(k,l).NormA01=Area(k,l).A01 ./ (sum( 1 -  Cs(k,l).C01(index01) ) * df );
		Area(k,l).NormA05=Area(k,l).A05 ./ (sum( 1 -  Cs(k,l).C05(index05) ) * df );
        
	end
end


