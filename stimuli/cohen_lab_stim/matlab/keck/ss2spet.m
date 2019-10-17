%
%function []=ss2spet(infile,Fs,B)
%
%       FILE NAME       : SS 2 SPET 
%       DESCRIPTION     : Converts 'spk' file from Mark Kvale Spike Sorter 
%			  to a sequence of spet wich is stord in a matlab file
%
%	infile		: filename 
%	Fs		: Sampling Rate
%	B		: File Block Size used in 'xtractch'
%			  Optional : Default = 10 Megs
%
function []=ss2spet(infile,Fs,B)

%Preliminaries 
more off

%Input Arguments
if nargin<3
	B=10;
end

%Extracting File name and renaming data
ii=find(infile=='.');
ext=infile(ii+1:length(infile));
filename=infile(1:ii-2);

%Finding Which File segments exist and loading
data1=[];
data2=[];
i=1;
file=[filename num2str(i) '.' ext];
while exist(file) 

	if fisempty(file)==0

		%Loading File
		disp(['Converting ' file])
		f=['load ' file];
		eval(f);
		f=['data=' filename num2str(i) ';'];
		eval(f);

		data1=[data1 data(:,1)'];
		data2=[data2 round(data(:,2)'/1000*Fs)+(i-1)*1024*1024*B];

	end

		%Incrementing File index
		i=i+1;
		file=[filename num2str(i) '.' ext];
end


%Converitng to SPET variables
numspikes=max(data1);
index=find(infile=='_');
outfile=[infile(1:index(length(index))-1) '.mat'];
savevar=['save ' outfile ' '];
for k=0:numspikes

	index=find(data1==k);
	f=['spet' num2str(k) '=data2(index);'];
	eval(f);

	savevar=[savevar 'spet' num2str(k) ' '];
end
if ~strcmp(version,'4.2c')
	savevar=[savevar ' Fs -v4'];
	eval(savevar);
else
	savevar=[savevar ' Fs'];
	eval(savevar);
end

%Closing Files
fclose('all');
