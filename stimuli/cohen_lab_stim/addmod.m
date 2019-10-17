%
%function []=addmod(infile,modfile,outfile,M,typein,typemod,typeout)
%
%       FILE NAME       : ADD MOD
%       DESCRIPTION     : Adds modulations to infile and stores to 
%			  outfile
%
%       infile		: Input file name
%	modfile		: Envelope Modulation file 
%	outfile		: Output file name
%
%Optional
%	M		: Segment length ( Default=1024*128 )
%	typein		: Infile  type : 'float' or 'int16' ( Default='float' )
%	typemod		: Modfile type : 'float' or 'int16' ( Default='float' )
%	typeout		: Outfile type : 'float' or 'int16' ( Default='float' )
%
function []=addmod(infile,modfile,outfile,M,typein,typemod,typeout)

%Preliminaries
if nargin<4
	M=1024*128;
end
if nargin<5
	typein='float';
end
if nargin<6
	typemod='float';
end
if nargin<7
	typeout='float';
end

%Opening Files
fidin=fopen(infile,'r');
fidmod=fopen(modfile,'r');
fidout=fopen(outfile,'a');

%Adding AM Modulations
while ~feof(fidin)

	%Reading Input and Writting Output
	X=fread(fidin,M,typein);
	Env=fread(fidmod,M,typemod);
	fwrite(fidout,round(X.*Env),typeout);

end

%Closing Files
fclose(fidin);
fclose(fidmod);
fclose(fidout);

