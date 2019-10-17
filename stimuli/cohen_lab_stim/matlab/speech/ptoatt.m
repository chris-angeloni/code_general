%function  [ATT] = PtoATT(P)
%
%	FILE NAME 	: PtoATT
%	DESCRIPTION 	: Conversion between P parameter and ATT
%			  for for Escabi / Roark filter.
%	p		: Filter Parameter
%	ATT		: Attenuation
%	Example		: [ATT] = PtoATT(6)
%
function  [ATT] = PtoATT(P)

if P >= 6.9836
	ATT=15.80759931643204*P + 40.60623213379506;
end

if P < 6.9836 & P > 5.4678
	ATT= 16.12914111162589*P + 30.80881683630636;
end
if P <= 5.4678 & P > 0

	K=0.0478;
	A=.00306342;
	ATT=( exp(K*P)-1 ) / A +21; 

end
if P <=0 
	ATT=21;
end
