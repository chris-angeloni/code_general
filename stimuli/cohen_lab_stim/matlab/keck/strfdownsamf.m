%
%function []=strfdownsamf(infile,outfile,LT,LF)
%
%       FILE NAME       : STRF DOWN SAM F
%       DESCRIPTION     : Down samples an STRF File
%	
%	infile		: Input STRF File
%	outfile		: Output STRF File
%	LT		: Temporal down sampling factor 
%			  1 means no down sampling
%	LF		: Spectral down sampling factor
%			  1 means no down sampling
%
function []=strfdownsamf(infile,outfile,LT,LF)

%Loading input file
f=['load ' infile];
eval(f);

%Reasigning Time and Frequency variables
t=taxis;
f=faxis;

%Down Sampling all STRFs
[taxis,faxis,STRF1]=strfdownsam(t,f,STRF1,LT,LF);
[taxis,faxis,STRF1s]=strfdownsam(t,f,STRF1s,LT,LF);
[taxis,faxis,STRF2]=strfdownsam(t,f,STRF2,LT,LF);
[taxis,faxis,STRF2s]=strfdownsam(t,f,STRF2s,LT,LF);

%Saving to file
f=['save ' outfile ' MdB ModType No1 No2 PP SModType SPLN STRF1 STRF2 STRF1s STRF2s Sound Wo1 Wo2 faxis taxis p  '];
if ~strcmp('4.2c',version)
	f=[f '  -v4'];
end
eval(f);

