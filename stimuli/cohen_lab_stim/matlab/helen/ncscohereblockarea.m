%
%function  [Area]=ncscohereblockarea(C,Cs,f1,f2)
%
%DESCRIPTION: Computes the significant area in the coherence between f1 and f2
%             for Blocked data (not concatenated) format. Data is generated
%             with NCSCOHEREBLOCK or NCSMTCOHEREBLOCK.
%
%   C       : Coherence Data Structure - Blocked Format
%   Cs      : Significant Coherence Threshold - Blocked Format
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
%Monty A. Escabi, Jan 2007
%
function  [Area]=ncscohereblockarea(C,Cs,f1,f2)

%Computing Area
df=C(1,1).Faxis(2)-C(1,1).Faxis(1);
for k=1:size(C,1)
	for l=1:size(C,2)
        for m=1:length(C(1,1).Block)

		index01=find(C(k,l).Faxis>=f1 & C(k,l).Faxis<=f2 & C(k,l).Block(m).Cxy>Cs(k,l).Block(m).C01);
		index05=find(C(k,l).Faxis>=f1 & C(k,l).Faxis<=f2 & C(k,l).Block(m).Cxy>Cs(k,l).Block(m).C05);
        index=find(C(k,l).Faxis>=f1 & C(k,l).Faxis<=f2);
		Area(k,l,m).A01=sum( C(k,l).Block(m).Cxy(index01) -  Cs(k,l).Block(m).C01(index01) ) * df;
		Area(k,l,m).A05=sum( C(k,l).Block(m).Cxy(index05) -  Cs(k,l).Block(m).C05(index05) ) * df;
        Area(k,l,m).A=sum( C(k,l).Block(m).Cxy(index) ) * df;
   		Area(k,l,m).dF=length(index)*df;
        Area(k,l,m).NormA01= Area(k,l,m).A01 ./ ( sum( 1 -  Cs(k,l).Block(m).C01(index01) ) * df );
		Area(k,l,m).NormA05= Area(k,l,m).A05 ./ ( sum( 1 -  Cs(k,l).Block(m).C05(index05) ) * df );

        end
    end
end