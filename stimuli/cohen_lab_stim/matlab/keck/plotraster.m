%
%function [fighandle]=plotraster(filename,PlotType,color,sig,dn)
%
%       FILE NAME       : PLOT RASTER
%       DESCRIPTION     : Plots the RASTER and Histogram Data from Filename
%
%	filaneme	: PRE File Name
%	PlotType	: 'Ras'   - Plots the RASTER Plot Only ( No Layout )
%			  'Psth'  - Plots the PSTH Only ( No Layout )
%			  'both'  - Plots the RASTER and PSTH 
%			  Default - 'both' - Layout for Color and subplots
%	color		: Color for Raster and PSTH
%	sig		: Uses Significant Raster for Plot : 'y' or 'n'
%			  Default: 'n'
%	dn		: Smoothing window width - in nuber of PSTH samples
%			  Default - 1 - no smoothing
%			  Temporal window size is dt=dn/Fs were Fs is the 
%			  sampling period / resolution of PSTH
%
function [fighandle]=plotraster(filename,PlotType,color,sig,dn)

%Preliminaries
more off

%Checking Input Arguments
if nargin<2
	PlotType='both';
end
if nargin<3
	color='b';
end
if nargin<4
	sig='n';
end
if nargin<5
	dn=1;
end

%Loading File
f=['load ' filename];
eval(f);
RASTER=full(RASTER);
PSTH=mean(RASTER);

%Smoothing PSTH  and RASTER if desired 
if dn>1
	W=ones(1,dn)/dn;
	PSTH=conv(PSTH,W);
	PSTH=PSTH(length(W)/2:length(PSTH)-length(W)/2);
	for k=1:size(RASTER,1)
		RASTERt=conv(RASTER(k,:),W);
		RASTER(k,:)=RASTERt(length(W)/2:size(RASTERt,2)-length(W)/2);
	end
end

%Setting Print Area
if strcmp('both',PlotType)
	fighandle=figure;
	set(fighandle,'position',[400,400,560,560],'paperposition',[.25 1.5  8 8.5]);
end

%Plotting Raster and PSTH File Data
if strcmp(PlotType,'Psth')

	if strcmp(sig,'y')
		plot(taxis,PSTH,color)
		axis([0 max(taxis) 0 max(PSTH)])
	else
		plot(taxis,PSTH,color)
		axis([0 max(taxis) 0 max(PSTH)])
	end

elseif strcmp(PlotType,'Ras')

	if strcmp(sig,'y')
		k=1;
		index=find(RASTERs(k,:));
		plot(taxis(index),ones(size(index))*k,[color '.'])
		hold on
		for k=2:size(RASTERs,1)	
			index=find(RASTERs(k,:));
			plot(taxis(index),ones(size(index))*k,[color '.'])
		end
		axis([0 max(taxis) 0 size(RASTERs,1)])
		hold off
	else
		k=1;
		index=find(RASTER(k,:)~=0);
		plot(taxis(index),ones(size(index))*k,[color '.'])
		hold on
		for k=2:size(RASTER,1)	
			index=find(RASTER(k,:)~=0);
			plot(taxis(index),ones(size(index))*k,[color '.'])
		end
		axis([0 max(taxis) 0 size(RASTER,1)])
		hold off
	end

elseif strcmp(PlotType,'both')

	if strcmp(sig,'y')
		subplot(211)
		k=1;
		index=find(RASTERs(k,:)~=0);
		plot(taxis(index),ones(size(index))*k,[color '.'])
		hold on
		for k=2:size(RASTERs,1)
			index=find(RASTERs(k,:)~=0);
			plot(taxis(index),ones(size(index))*k,[color '.'])
		end
		axis([0 max(taxis) 0 size(RASTERs,1)])
		hold off
	
		subplot(212)
		plot(taxis,PSTHs,color)
		axis([0 max(taxis) 0 max(PSTHs)])
		hold off
	else
		subplot(211)
		k=1;
		index=find(RASTER(k,:)~=0);
		plot(taxis(index),ones(size(index))*k,[color '.'])
		hold on
		for k=2:size(RASTER,1)
			index=find(RASTER(k,:)~=0);
			plot(taxis(index),ones(size(index))*k,[color '.'])
		end
		axis([0 max(taxis) 0 size(RASTER,1)])
		hold off
	
		subplot(212)
		plot(taxis,PSTH,color)
		axis([0 max(taxis) 0 max(PSTH)])
		hold off
	end
end
