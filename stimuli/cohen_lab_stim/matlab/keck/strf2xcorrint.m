%
%function [T,R]=strf2xcorrint(taxis,faxis,STRF1,STRF2,PP)
%
%       FILE NAME       : STRF 2 XCORR INT
%       DESCRIPTION     : Interactive X-Correlation Function obtained from the STRF
%
%	taxis		: Time Axis for STRF
%	faxis		: Frequency Axis for STRF
%	STRF1		: STRF for unit 1
%	STRF2		: STRF for unit 2
%	PP		: Signal Power
%
function [T,R]=strf2xcorrint(taxis,faxis,STRF1,STRF2,PP)

%Ploting STRF
Max=max(max(abs(STRF1)))*sqrt(PP);
pcolor(taxis,log2(faxis/faxis(1)),STRF1*sqrt(PP)),shading flat,colormap jet,colorbar
[T,X]=ginput(2);

%Setting All Values Outside Range to Zero
NT=round(T/taxis(2));
NT=sort(NT);
NT(1)=max(NT(1),1);
NT(2)=min(NT(2),length(taxis));
NX=round(X/log2(faxis(2)/faxis(1)));
NX=sort(NX);
NX(1)=max(NX(1),1);
NX(2)=min(NX(2),length(faxis));
for k=1:length(taxis)
	for l=1:length(faxis)
		if ~( k>NT(1) & k<NT(2) & l>NX(1) & l<NX(2) )
			STRF1(l,k)=0;
			STRF2(l,k)=0;
		end
	end
end
STRF1=STRF1(NX(1):NX(2),:);
STRF2=STRF2(NX(1):NX(2),:);
faxis=faxis(NX(1):NX(2));


%Computing STRF 2 X-Corr
[T,R]=strf2xcorr(taxis,faxis,STRF1,STRF2,PP);
