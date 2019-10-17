%
%function []=psthprefile(filename,Fss,p)
%
%       FILE NAME   : PSTH PRE FILE
%       DESCRIPTION : Generates a Post Stimulus Time Histogram File for 
%                     Prediction Ripple Sounds 
%	
%       filename    : Input File Name (Ex, 'icg315t1_f11_ch1')
%       Fss         : Sampling rate for PSTH
%       p           : Significance probability
%                     (Optional, if not provided does not compute
%                     significant PSTH)
%
% (C) Monty A. Escabi, August 2006 (Last Edit)
%
function []=psthprefile(filename,Fss,p)

%Input Arguments
if nargin==2
    p=inf;
end

%Adding MAT Suffix
if isempty(findstr('.mat',filename))
	filename=[filename '.mat'];
end

%Loading SPET and TRIG File
f=['load ' filename];
eval(f);
index=findstr('ch',filename);
f=['load ' filename(1:index-1) 'Trig.mat'];
eval(f);

%Finding All Non-Outlier spet
count=-1;
while exist(['spet' int2str(count+1)])
	count=count+1;
end
Nspet=(count+1)/2;

if ~exist('Trig')
    %Finding Triggers
    Trig=trigpsth(TrigTimes,Fs,.4);
end

%Computing PSTH
index=findstr('.mat',filename);
for k=0:Nspet-1

	%Computing PSTH Histogram
	f=['[taxis,PSTH,RASTER]=psth(Trig,spet' int2str(k) ',Fs,Fss);'];
	eval(f);

    if ~isinf(p)
    	%Finding Statistically Significant PSTH and RASTER
        [taxis,PSTHs,RASTERs]=psthclean(PSTH,RASTER,Fss,p);
    
        %Saving Pre File
        Command=['save ' filename(1:index-1) '_u' int2str(k) '_Pre',...
            num2str(Fss) 'Hz taxis RASTER RASTERs p ']; 
        eval(Command);
    else
        %Saving Pre File
        Command=['save ' filename(1:index-1) '_u' int2str(k) '_Pre',...
            num2str(Fss) 'Hz taxis RASTER']; 
        eval(Command);
    end
        
	%Clearing RASTER and PSTH Variables
	f=['clear PSTH RASTER spet' int2str(k)];
	eval(f)

end