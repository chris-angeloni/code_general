%function [taxisshift]=timeshift(gau_Elpt,Elpt,taxis1);
%
%Function   
%                to change the time scale for the temporal evenlope in strfmodel_ctc.m
%Input
%         gau_Elpt      Gaussian evelope for the temporal evenlope
%         Elpt          Original temporal evenlope
%         taxis1        extended time vector [-fliplr(taxis) taxis]
%Output
%         taxisshift    new time vector at which gau_Elpt has the same value with Elpt
%
%  Anqi Qiu
%  11/6/2001

function [taxisshift]=timeshift(gau_Elpt,Elpt,taxis1);

taxishift=zeros(1,length(Elpt));
for n=1:length(Elpt),
   i=find(gau_Elpt>=Elpt(n)/max(Elpt));
   if n>min(find(Elpt==max(Elpt)))
      taxisshift(n)=taxis1(max(i));
   else
      taxisshift(n)=taxis1(min(i));        
   end
end

      