
% function [CYCH]= cychgen(RASspet,Flag,FMAxis,bins,stimmod,Onset,num,N,Ncyc)

%  DESCRIPTION      : Generate normalized cycle histgram

%   RAStt           : raster of time vs trial format
%   FMAxis          :
%   bins            : the number of bins per cycle
%   N               : number of trials per stimulus
%   Ncyc            : number of cycles displayed in PSTH

function [CYCH,BINW]= cychgen(RASspet,Flag,FMAxis,bins,stimmod,Onset,num,N,Ncyc)

if nargin<9
    Ncyc = 1;
end

for k = 1:length(FMAxis)
   spet = [];
   binspercyc = min(bins,round(RASspet(1).Fs/FMAxis(k)));
   binW = 1/FMAxis(k)/binspercyc;  % width of bin in sec
   BINW(k)=binW;
   for n=1:N
     spet = [spet RASspet((k-1)*N+n).spet];
   end
   Tspet = spet./RASspet(k).Fs;  % spet time
   
   if (Flag == 0 | Flag ==1)
     if strcmp(stimmod, 'cyc')
       Time=Tspet(find( (Tspet>=1/FMAxis(k)*Onset)&(Tspet<=1/FMAxis(k)*(Onset+num)) ));
     else strcmp(stimmod, 'duration')
        Time=Tspet(find( (Tspet>=Onset)&(Tspet<=(Onset+num)) ));
     end
     
%       if isempty(Time)
%        psth=0;
%       else
%        psth = histc(Time,[(1/FMAxis(k)*OnsetC):binW:(1/FMAxis(k)*(OnsetC+numC))]);
%       end
   else (Flag==2)
     Time = Tspet; 
%      if isempty(Time)
%       psth=0;
%      else
%       psth = histc(Time,[(1/FMAxis(k)*OnsetC):binW:(1/FMAxis(k)*(OnsetC+10*numC))]);
%      end
   end  % end of if
   
   if isempty(Time)
       CYCH(k).hist=0;
   else
   
%    cyctime = mod(Time, 1/FMAxis(k));
%    CYCH(k).hist=histc(cyctime,[0:binW:binW*binspercyc]);
    cyctime = mod(Time,1/FMAxis(k)*Ncyc);
    CYCH(k).hist=hist(cyctime,[0:binW:binW*binspercyc*Ncyc]); % number of spikes per bin for all
   if strcmp(stimmod, 'cyc')
     CYCH(k).hist = CYCH(k).hist./(N*num);
   else strcmp(stimmod, 'duration')
%      numC=round(num*FMAxis(k));
     numC=round(num*FMAxis(k)/Ncyc);  % number of designed trials per original trial
     CYCH(k).hist = CYCH(k).hist./(N*numC); % number of spikes per binwidth
   end  % end of strcmp

   CYCH(k).time = cyctime;
   end  % end of isempty(Time)
end  % end of k



% function [CYCH] = psth2cych(psth, cycles, binspercyc, FMAxis, FMindex)
