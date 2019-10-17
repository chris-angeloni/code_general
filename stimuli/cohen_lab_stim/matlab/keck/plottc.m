%function [] = plottc(filename,original,N)
%
%	FILE NAME 	: PLOT TC
%	DESCRIPTION 	: Plots a Tuning Curve
%
%	infile		: Input File
%
%Optional
%	original	: Draw original for comparison: 'y' or 'n'
%			  Default = 'y'
%	N		: Kaiser Window Order ( Length==2N )
%			  Default = 8
%
function [] = plottc(filename,original,N)

%Prelimninaries
if nargin<2
	N=8;
	original='y';
elseif nargin<3
	N=8;
end

%Reading File
f=['load ' filename];
eval(f);

%Smoothing Tuning Curve and Normalizing
M1=min([size(displayMat)]);
M2=max([size(displayMat)]);
W=kaiser(N+1,10);
W=W/sqrt(sum(W));
for k=1:M1
	TC1(:,k)=conv(W,displayMat(:,k));
end
for k=1:M2+N
	TC2(k,:)=conv(W,TC1(k,:));
end
TC2=inorm(TC2(N/2:N/2+M2-1,N/2:N/2+M1-1))/255*max(max(displayMat));

%Drawing TC
ver=version;
ver=ver(1);
if ver=='5'
	if original=='y'
		subplot(211)
		hold off
		pcolor(dispFreqs,dispAmps,TC2')
		hold on
		contour(dispFreqs,dispAmps,TC2','k')
		set(gca,'XScale','log')
		colormap jet
		shading interp
		colorbar

		subplot(212)
		pcolor(dispFreqs,dispAmps,displayMat')
		set(gca,'XScale','log')
		colormap jet
		colorbar
	else
		hold off
		pcolor(dispFreqs,dispAmps,TC2')
		hold on
		contour(dispFreqs,dispAmps,TC2','k')
	
		set(gca,'XScale','log')
		colormap jet
		shading interp
		colorbar
		xlabel('Frequency ( KHz )')
		ylabel('Intensity ( dB )')
		set(gca,'XTick',[5 10 15 20])
	end
else
	if original=='y'
		subplot(211)
		hold off
		contourf(dispFreqs,dispAmps,TC2')
		hold on
		set(gca,'XScale','log')
		colormap jet(16)
		colorbar

		subplot(212)
		pcolor(dispFreqs,dispAmps,displayMat')
		set(gca,'XScale','log')
		colormap jet
		colorbar
	else
		hold off
		contourf(dispFreqs,dispAmps,TC2')
	
		set(gca,'XScale','log')
		colormap jet(16)
		colorbar
		xlabel('Frequency ( KHz )')
		ylabel('Intensity ( dB )')
	end
end
