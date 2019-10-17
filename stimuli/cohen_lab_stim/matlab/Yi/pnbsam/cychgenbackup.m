% function [CYCH]= cychgen(RASspet,FMAxis,binspercyc,OnsetC,numC,N)

%  DESCRIPTION      : Generate normalized cycle histgram

%   RAStt           : raster of time vs trial format
%   FMAxis          :
%   binspercyc      : the number of bins per cycle
%   N               : number of trials per stimulus

function [CYCH]= cychgen(RASspet,Flag,FMAxis,binspercyc,OnsetC,numC,N)

for k = 1:length(FMAxis)
   spet = [];
   binW = 1/FMAxis(k)/binspercyc;  % width of bin in sec
   for n=1:N
     spet = [spet RASspet((k-1)*N+n).spet];
   end
   Tspet = spet./RASspet(k).Fs;  % spet time
   
   if (Flag == 0 | Flag ==1)
     Time=Tspet(find( (Tspet>=1/FMAxis(k)*OnsetC)&(Tspet<=1/FMAxis(k)*(OnsetC+numC)) ));
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
   
   cyctime = mod(Time, 1/FMAxis(k));
   CYCH(k).hist=histc(cyctime,[0:binW:binW*binspercyc]);
   CYCH(k).hist = CYCH(k).hist./(N*numC);
   CYCH(k).time = cyctime;
   end
end



% function [CYCH] = psth2cych(psth, cycles, binspercyc, FMAxis, FMindex)
