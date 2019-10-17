%function function function [data]=normmap(data)
%
%	FILE NAME 	: NORM MAP
%	DESCRIPTION 	: Normalizes the coordinate space of a map
%			  so that it fits in the unit interval 
%			  [0,1]x[0,1] 
%			  
%	data		: Map Data
%			  Arranged so that Col 1 is the X-coordinate,
%			  Col 2 is the Y-coordinate and Col 3 is the 
%			  amplitude of the desired parameter.
%
function [data]=normmap(data)

%Normalizing Coordinates (making them >0 and <1)
data(:,1)=data(:,1)-min(data(:,1));
data(:,2)=data(:,2)-min(data(:,2));
MaxX=max(data(:,1));
MaxY=max(data(:,2));
Max=max([MaxX MaxY]);
data(:,1)=data(:,1)/Max;
data(:,2)=data(:,2)/Max;
