%function []=rmmod(infile,outfile,M)
%
%       FILE NAME       : RM MOD
%       DESCRIPTION     : Removes Amplitude modulations from infile. Performed
%			  via Analitic Signal
%
%       infile		: Input file name
%	outfile		: Output file name 
%	M		: Segment length
%
function []=rmmod(infile,outfile,M)

%Preliminaries
if nargin<3
	M=1024*128;
end

%Opening Files
fidin=fopen(infile,'r');
fidout=fopen(outfile,'a');

%Removing AM Modulations
while ~feof(fidin)

	%Removing Modulations and saving to File
	%Recall Analytic Signal : z(t) = x(t) + H[ x(t) ] = A(t) * e^( -i*p(t) )
	%                         A(t) = abs( z(t) )
	%Taking Out Modulations : x(t) = x(t) / A(t) = x(t) / abs( z(t) ) 
	% 
	X=fread(fidin,M,'float');
	N=min(M,length(X));
	fwrite(fidout, round( X./abs(hilbert(X))*32767 ) ,'float');

end

%Closing Files
fclose('all');
