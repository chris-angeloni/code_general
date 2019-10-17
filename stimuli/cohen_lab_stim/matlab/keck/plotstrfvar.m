%
%function [fighandle]=plotstrfvar(filename)
%
%       FILE NAME       : PLOT STRF VAR
%       DESCRIPTION     : Plots STRF variability data obtained from
%			  RTWSTRFdBVAR and RTWSTRFLinVAR
%			  These routines measure the variability in the
%			  sound paterns that elicited responses using the
%			  correlation coefficient between the sound patern 
%			  for the kth spike and the significant STRFs
%
%	filename	: VAR filename
%
function [fighandle]=plotstrfvar(filename)

%Loading RTF File
f=['load ' filename];
eval(f);

%Setting Print Area
fighandle=figure;
set(fighandle,'position',[700,400,560,560],'paperposition',[.25 1.5  8 8.5]);

%Fixing File Name for Display
index=findstr(filename,'_');
for k=1:length(index)
	filename(index(k))='-';
end

%Plotting Data
subplot(321)
paxis=-1.2:.1:1.2;
N=hist(p1,paxis);
hold on
Nr=hist(p1r,paxis);
plot(paxis,N/sum(N),'b')
plot(paxis,Nr/sum(Nr),'r-.')
axis([-1.2 1.2 0 max(max(N)/sum(N),max(Nr)/sum(Nr))*1.25])
set(gca,'box','on')
title('Channel 1')
ylabel('Full STRF')

subplot(322)
paxis=-1.2:.1:1.2;
N=hist(p2,paxis);
Nr=hist(p2r,paxis);
plot(paxis,N/sum(N),'b')
hold on
plot(paxis,Nr/sum(Nr),'r-.')
axis([-1.2 1.2 0 max(max(N)/sum(N),max(Nr)/sum(Nr))*1.25])
set(gca,'box','on')
title('Channel 2')

subplot(323)
paxis=-1.2:.1:1.2;
N=hist(p1e,paxis);
hold on
Nr=hist(p1er,paxis);
plot(paxis,N/sum(N),'b')
plot(paxis,Nr/sum(Nr),'r-.')
axis([-1.2 1.2 0 max(max(N)/sum(N),max(Nr)/sum(Nr))*1.25])
set(gca,'box','on')
ylabel('Excitatory STRF')

subplot(324)
paxis=-1.2:.1:1.2;
N=hist(p2e,paxis);
Nr=hist(p2er,paxis);
plot(paxis,N/sum(N),'b')
hold on
plot(paxis,Nr/sum(Nr),'r-.')
axis([-1.2 1.2 0 max(max(N)/sum(N),max(Nr)/sum(Nr))*1.25])
set(gca,'box','on')

subplot(325)
paxis=-1.2:.1:1.2;
N=hist(p1i,paxis);
hold on
Nr=hist(p1ir,paxis);
plot(paxis,N/sum(N),'b')
hold on
plot(paxis,Nr/sum(Nr),'r-.')
axis([-1.2 1.2 0 max(max(N)/sum(N),max(Nr)/sum(Nr))*1.25])
set(gca,'box','on')
ylabel('Inhibitory STRF')
xlabel('Correlation Coefficient')

subplot(326)
paxis=-1.2:.1:1.2;
N=hist(p2i,paxis);
Nr=hist(p2ir,paxis);
plot(paxis,N/sum(N),'b')
hold on
plot(paxis,Nr/sum(Nr),'r-.')
xlabel('Correlation Coefficient')
set(gca,'box','on')
axis([-1.2 1.2 0 max(max(N)/sum(N),max(Nr)/sum(Nr))*1.25])

