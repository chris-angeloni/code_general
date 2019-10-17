%
%function []=plotcfdata(Filename)
%	
%	FILE NAME 	: FIND CF
%	DESCRIPTION 	: Plots data obtained using FINDCFTOOL
%
%	Filename	: Input STRF filename
%
function []=plotcfdata(Filename)

%Loading Input File
f=['load ' Filename];
eval(f);

%Plotting Xc vs. Delay
subplot(221)
index=find( CFData(:,3)~=1 & CFData(:,6)~=1 );
XcC=CFData(index,7);
XcI=CFData(index,9);
plot(XcC,XcI,'r+')

index1=find(  CFData(:,3)==0 & CFData(:,6)==1  );
index2=find(  CFData(:,3)==1 & CFData(:,6)==0  );
XcC1(index1)=CFData(index1,7);
XcI1(index1)=zeros(length(index1),1);
XcC2(index2)=zeros(length(index2),1);
XcI2(index2)=CFData(index2,9);
hold on
plot(XcC1,XcI1,'go')
plot(XcC2,XcI2,'go')
hold off
