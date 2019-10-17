%
%function []=acq2spet(infile,M)
%
%       FILE NAME       : ACQ 2 SPET 
%       DESCRIPTION     : Converts ACQ file from Lee Millers Acquire Program 
%			  to a sequence of spet wich is stord in a matlab file
%
%	infile		: Input filename 
%	M 		: Buffer Size
%
function []=acq2spet(infile,M)

%Opening Input File
fid=fopen(infile);

%Output File name
index=find(infile=='.');
outfile=infile(1:index-1);

%Reading Data and Converting to SPET
chan=[];
isi=[];
while ~feof(fid)

	%Reading Data
	X=fread(fid,M,'uint16');

	%Finding Channel - Masking Out ISI
	Channel= bitset(X,1,0);
	Channel= bitset(Channel,2,0);
	Channel= bitset(Channel,3,0);
	Channel= bitset(Channel,4,0);
	Channel= bitset(Channel,5,0);
	Channel= bitset(Channel,6,0);
	Channel= bitset(Channel,7,0);
	Channel= bitset(Channel,8,0);
	Channel= bitset(Channel,9,0);
	Channel= bitset(Channel,10,0);
	Channel= bitshift(Channel,-10);

	%Finding ISI - Masking out Channel
	Isi= bitset(X,16,0);
	Isi= bitset(Isi,15,0);
	Isi= bitset(Isi,14,0);
	Isi= bitset(Isi,13,0);
	Isi= bitset(Isi,12,0);
	Isi= bitset(Isi,11,0);

	%Collecting all isi and channel data
	chan=[chan Channel'];
	isi=[isi Isi'];

end

%Finding SPET via. FFT Integrator
NChan=8;
N=2^nextpow2(length(isi));
TotSpet=intfft([isi zeros(1,N-length(isi))]);
TotSpet=round( TotSpet-min(TotSpet) );
TotSpet=TotSpet(2:length(isi)+1);

%Initializing and Finding SPET
for l=1:NChan
	f=['spet' int2str(l) '= [];'];
	eval(f)
end
for l=1:NChan
	index=find(chan==l);
	f=['spet' int2str(l) '= TotSpet(index);'];
	eval(f)
end

%Clearing and Saving to File
if strcmp(version,'4.2c')
	f=['save ' outfile ' spet1 spet2 spet3 spet4 spet5 spet6 spet7 spet8 '];
else
	f=['save ' outfile ' spet1 spet2 spet3 spet4 spet5 spet6 spet7 spet8 -v4'];
end
eval(f);

%Closing Files
fclose('all');
