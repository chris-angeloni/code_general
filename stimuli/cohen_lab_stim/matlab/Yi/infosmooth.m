%
%functi[ZZ,OptDT,SmoothOptDT]=infosmooth(dt,Fm,Z,N,Disp)
%
%       FILE NAME       : INFO SMOOTH
%       DESCRIPTION     : Cleans up data for Yi's modulation experiments. 
%                         Smoothes the info matrix with a 3x3 gaussian
%                         filter. It then finds the optimal temporal
%                         resolution by find the max information (OptDT).
%                         This optimal resolution is then fitted with an
%                         N-th order polynomial (SmoothOptDT).
%
%       dt              : Temporal resolution Array
%       Fm              : Modulation Frequency Array
%       Z               : Information Matrix
%       N               : Polynomail order for fitting SmoothOptDT
%       Disp            : Display output (Default=='n')
%
%RETURNED VALUES
%       ZZ              : Smoothed information matrix
%       OptDT           : Optimal temporal resoltion. This is found by
%                         finding the peak values of ZZ
%       SmoothOptDT     : Smoothed Optimal Temporal Resolution. This is
%                         obtained by fitting an N-th order polynomial to 
%                         OptDT
%
%   (C) M. Escabi, Jan 2008 (Edit March 2009)
%
function [ZZ,OptDT,SmoothOptDT]=infosmooth(dt,Fm,Z,N,Disp)

if nargin<5
   Disp='n'; 
end

%Periodic Extension
i=find(isnan(Z));
Z(i)=zeros(size(i));
ZZ=[fliplr(Z) Z; flipud(fliplr(Z)) flipud(Z)];

%Filtering With a 3x3 Gaussian filter
W=[0.5 1 .5];
WW=W'*W;
ZZ=conv2(ZZ,WW);
ZZ=flipud(ZZ(14:25,20:37));

%Finding the Optimal Resolution
for k=1:size(ZZ,2)
    j(k)=find(max(ZZ(:,k))==ZZ(:,k));
end
OptDT=dt(j);
ZZ(i)=nan(size(i));

%Smoothing Optimal Resolution
[P,S]=polyfit(log10(Fm),log10(OptDT'),N);
SmoothOptDT=10.^polyval(P,log10(Fm));

%Plotting Data if desired
if strcmp(Disp,'y')
    pcolor(Fm,dt,ZZ)
    set(gca,'XScale','log')
    set(gca,'YScale','log')
    hold on
    plot(Fm,OptDT,'r')
    hold on
    plot(Fm,SmoothOptDT,'k')
end