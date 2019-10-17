%
%function [] = plotftc(faxis,spl,FTC,T1,T2)
%
%	FILE NAME 	: PLOT FTC
%	DESCRIPTION 	: Uses spikesorted SPET data and DTC file to find a 
%			  single unit frequency tunning curve
%
%	faxis		: Frequency Axis
%	spl		: Sound Pressure Level Array
%	FTC		: Frequency Tunning Curve Data Matrix
%	T1		: Minimum Delay for plotting FTC (msec)
%	T2		: Maximum Delay for plotting FTC (msec)
%	N		: Filter size to smooth FTC : NxN (Default N=1)
%	ftype		: Frequency Axis Type ('hz' or 'octave')
%
function [] = plotftc(faxis,spl,FTC,T1,T2,N,ftype)

%Input Arguments
if nargin<6
	N=1;
end
if nargin<7
	ftype='hz';
end

%Make Sure T1 and T2 are integer valued
T1=floor(T1);
T2=floor(T2);

%Finding FTC data
TC=zeros(15,45);
for k=T1:T2 
	TC=TC+FTC(:,:,k);
end

%Smooth FTC if desired with a kaiser window
N1=size(TC,1);
N2=size(TC,2);
H=kaiser(N,4);
H=H*H';
H=H/sum(sum(H));
TC=conv2(TC,H);
L=floor(N/2);
TC=TC(L+1:N1+L,L+1:N2+L);

%Plotting FTC DatP
if strcmp(ftype,'hz')
	imagesc(faxis,spl,TC/(T2-T1)*1000),set(gca,'YDir','normal')
	set(gca,'XScale','log')
else
	imagesc(log2(faxis/.5),spl,TC/(T2-T1)*1000),set(gca,'YDir','normal')
end
