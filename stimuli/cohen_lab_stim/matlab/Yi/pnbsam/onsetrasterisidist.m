%
% function [ISI] = onsetrasterisidist(RASTER)
%
%	FILE NAME 	    : ONSET RASTER ISI DIST
%	DESCRIPTION     : Finds the inter spike intervals for differnt trials
%                     of onset response data
%
%	RASTER          : RASTER Data Sructure
%                     RASTER(k).spet    - Spike event times  
%                                         for each trial
%                     RASTER(k).Fs      - Sampling Rate
%                     RASTER(k).FM      - Modulation Frequency
%
% RETURNED DATA
%
%
%   (C) Monty A. Escabi, Jan 2007
%
function [ISI] = onsetrasterisidist(RASTER,FMAxis)

n = length(RASTER)/length(FMAxis)
for FMi = 1:length(FMAxis)
    for i=1:n
     RASTER((FMi-1)*n+i).FM = FMAxis(FMi);
    end 
end % end of FMi


FM=[RASTER.FM];
index=find(diff(FM)>0);
N=length(index)+1;
index=[0 index max(index)+index(1)];
NTrials=index(2);

for k=1:N

   count=1;
   for l=index(k)+1:index(k+1)
      
       if length(RASTER(l).spet)==0
           
           ISI(k).t1(count)=nan(1);
           ISI(k).t2(count)=nan(1);
           ISI(k).t3(count)=nan(1);
           ISI(k).t4(count)=nan(1);
           ISI(k).t5(count)=nan(1);
           
       elseif length(RASTER(l).spet)==1

           ISI(k).t1(count)=RASTER(l).spet(1);
           ISI(k).t2(count)=nan(1);
           ISI(k).t3(count)=nan(1);
           ISI(k).t4(count)=nan(1);
           ISI(k).t5(count)=nan(1);
           
       elseif length(RASTER(l).spet)==2
    
           ISI(k).t1(count)=RASTER(l).spet(1);
           ISI(k).t2(count)=RASTER(l).spet(2);
           ISI(k).t3(count)=nan(1);
           ISI(k).t4(count)=nan(1);
           ISI(k).t5(count)=nan(1);

       elseif length(RASTER(l).spet)==3

           ISI(k).t1(count)=RASTER(l).spet(1);
           ISI(k).t2(count)=RASTER(l).spet(2);
           ISI(k).t3(count)=RASTER(l).spet(3);
           ISI(k).t4(count)=nan(1);
           ISI(k).t5(count)=nan(1);

           
       elseif length(RASTER(l).spet)==4
       
           ISI(k).t1(count)=RASTER(l).spet(1);
           ISI(k).t2(count)=RASTER(l).spet(2);
           ISI(k).t3(count)=RASTER(l).spet(3);
           ISI(k).t4(count)=RASTER(l).spet(4);
           ISI(k).t5(count)=nan(1);
           
       elseif length(RASTER(l).spet)>=5  
           
           ISI(k).t1(count)=RASTER(l).spet(1);
           ISI(k).t2(count)=RASTER(l).spet(2);
           ISI(k).t3(count)=RASTER(l).spet(3);
           ISI(k).t4(count)=RASTER(l).spet(4);
           ISI(k).t5(count)=RASTER(l).spet(5);
           
       end
      
       count=count+1;
       
   end
    
   ISI(k).Fs=RASTER(1).Fs;
end