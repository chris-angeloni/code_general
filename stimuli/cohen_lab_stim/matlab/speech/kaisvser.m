%function  [ATTER,ATTK] = kaisvser(ATTlow,ATTstep,ATThigh)
%
%	FILE NAME 	: Kaiser vs Escabi / Roark
%	DESCRIPTION 	: Compares ATT for kaiser and Escabi / Roark. 
%
function  [ATTER,ATTK] = KaisvsER(ATTlow,ATTstep,ATThigh)

wc=0.4*pi;
TW=.1*pi;

i=0;	
for ATT = ATTlow:ATTstep:ATThigh,

	[P,N,alpha,wc] = fdesignh(ATT,TW,wc);
	[Beta,NK,wck] = fdesignk(ATT,TW,wc);	
	i=i+1;
%	ATTER(i)=-20*log10(err(N,P,-1,wc,32));
%	hold on;
	ATTK(i)=-20*log10(errk(NK,Beta,wc,32));
%	clf;
end

