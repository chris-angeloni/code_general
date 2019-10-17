%
%function  [SMean,ShMean]=velocitytrajectorymean(VelData,T1,T2)
%
%DESCRIPTION: Computes the mean of the speed trajectory between two time
%             points
%
%   VelData : Velocity data structure
%             T - Time Axis using Fsd
%             X - X Trajectory using Fsd
%             Y - Y Trajectory using Fsd
%             V - Velocity trajectory 
%             S - Speed trajectory
%             Xh- Lowpass filtered X Trajectory using Fsd
%             Yh- Lowpass filtered Y Trajectory using Fsd
%             Vh- Lowpass filtered Velocity trajectory 
%             Sh- Lowpass filtered Speed trajectory
%             Xn- Normalized X Trajectory (use to determine appropriate
%                 Xthresh to use in segmentvelocity)
%   T1      : Start time (sec)
%   T2      : End time (sec)
%
%RETURNED VARIABLES
%
%   SMean   : Mean speed
%   ShMean  : Mean filtered speed
%
%Monty A. Escabi, June 2009
%
function  [SMean,ShMean]=velocitytrajectorymean(VelData,T1,T2)

%Finding Mean speed between T1 and T2
for k=1:length(T1)
    i=find(VelData.T>T1(k) & VelData.T<T2(k));
    SMean(k)=mean(VelData.S(i));
    ShMean(k)=mean(VelData.Sh(i));
end