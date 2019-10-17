%function [] = mvinterp(mvdata,outfile,M)
%
%	FILE NAME 	: MV INTERP 
%	DESCRIPTION 	: Interpolates PSTH Data to generate movie
%
%	mvdata		: Movie Data
%	outfile		: Output File - including path
%	M		: Number of Frames
%
function [] = mvinterp(mvdata,outfile,M)

%Interpolating frames
data=mvdata(:,1:2);

for n=1:M
	data(:,3)=mvdata(:,n+2);
	[xaxis,yaxis,I]=intmapte(data,32,.5*pi,.5*pi,8,'n');

	f=['save ',outfile,'.',num2str(n),'.mat I'];
	eval(f)
	f=['Saving: ',outfile,'.',num2str(n),'.mat'];
	disp(f);
end



