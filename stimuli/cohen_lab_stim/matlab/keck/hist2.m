%
%function [Xaxis,Yaxis,N]=hist2(X,Y,Mx,My,Display)
%
%       FILE NAME       : HIST 2
%       DESCRIPTION     : Two Dimmensional Histogram 
%			  Joint Histogram of X and Y
%
%	X		: Input Parameter 1
%	Y 		: Input Parameter 2
%	Mx		: Number of Bins to Use for X
%			  If Mx is a Vector Uses bins Specified by Mx
%			  Default Mx == 20 Bins
%	My		: Number of Bins to Use for Y
%			  If My is a Vector Uses bins Specified by My
%			  Default My == 20 Bins
%	Display		: Display Histogram : 'y' or 'n'
%			  Default 'n'
%
%	Note: For RTFHist need to multiply by - sign
%	Example: [FM,RD,N]=hist2(-FM1,RD1,Mx,My)
%
function [Xaxis,Yaxis,N]=hist2(X,Y,Mx,My,Display)

%Checking Input
if nargin<5
	Display='n';
end

%Finding Bin Size (dX,dY), and Minx, Miny
if length(Mx)==1 & length(My)==1

	%Finding Histogram Bin Size, and Min
	dX=( max(X)-min(X) ) / Mx;
	MinX=min(X)+dX/2;
	dY=( max(Y)-min(Y) ) / My;
	MinY=min(Y)+dY/2;
	
elseif length(Mx) > 1 & length(My)==1

	%Finding Histogram Bin Size, and Min
	dX=abs(Mx(2)-Mx(1));
	MinX=min(Mx)-dX/2;
	Mx=length(Mx);
	dY=( max(Y)-min(Y) ) / My;
	MinY=min(Y);

elseif length(Mx)==1 & length(My)>1

	%Finding Histogram Bin Size, and Min
	dX=( max(X)-min(X) ) / Mx;
	MinX=min(X)+dX/2;
	dY=abs(My(2)-My(1));
	MinY=min(My)-dY/2;
	My=length(My);

else

	%Finding Histogram Bin Size, and Min
	dX=abs(Mx(2)-Mx(1));
	MinX=min(Mx)-dX/2;
	Mx=length(Mx);
	dY=abs(My(2)-My(1));
	MinY=min(My)-dY/2;
	My=length(My);

end 

%Finding Joint Histogram
N=zeros(My,Mx);
for k=1:My
	for j=1:Mx

		%Finding Number of Occurences in a Bin
		index=find(X>=MinX+(j-1)*dX & X<MinX+j*dX & Y>=MinY+(k-1)*dY & Y<MinY+k*dY);
		N(k,j)=length(index);

	end
end

%Setting X and Y axis
Xaxis=MinX+(.5:Mx-1+.5)*dX;
Yaxis=MinY+(.5:My-1+.5)*dY;

%Displaying 
if Display=='y'
	pcolor(Xaxis,Yaxis,N), colormap jet
end
