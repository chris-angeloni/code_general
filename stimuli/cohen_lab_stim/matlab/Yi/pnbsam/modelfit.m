% Yi Zheng, Jan2007

function [Hbound,Lbound]=modelfit(DATA,FMAxis)

binspercyc = 100;
time = 1:(binspercyc+1);
Hbound = zeros(1,length(FMAxis));  Lbound = zeros(1,length(FMAxis));

for FMindex = 1:length(FMAxis)
% t = (0:binspercyc)/binspercyc/FMAxis(FMindex);
data = DATA(FMindex).hist;
[beta] = lsqcurvefit('gaussmodel',[6 1],time,data);
mu = beta(1);
sigma = abs(beta(2));

Fit=gaussmodel([mu sigma],time);
Fit = Fit/max(Fit)*max(data);
% figure
% bar(time,data);
% hold on
% plot(time,Fit,'r');

Hbound(1,FMindex) = (mu+5*sigma)*(1/FMAxis(FMindex)/binspercyc);
Lbound(1,FMindex) = (mu-5*sigma)*(1/FMAxis(FMindex)/binspercyc);

end  % end of FMindex