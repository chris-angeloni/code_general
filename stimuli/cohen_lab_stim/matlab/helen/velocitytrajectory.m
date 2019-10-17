%
%function  [VelData]=velocitytrajectory(T,X,Y,Cm,Fsd,Fc,disp)
%
%DESCRIPTION: Coherence for multi channel data from NCS file
%
%   T       : Time stamp (micro seconds)
%   X       : X position trajectory
%   Y       : Y position trajectory
%   Cm      : Number of pixels in 10 cm (unique for each track). If
%             length(Cm)==2, then Cm(1) is the resolution for the
%             horizontal component (X) and Cm(2) is for the vertivcal
%             component (Y)
%   Fsd     : Desired sampling rate (100 Hz)
%   Fc      : Lowpass filter cutoff frequency (0.25 Hz)
%   disp    : if 'y', then plots Xn over time
%
%RETURNED VARIABLES
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
%             
%
%Monty A. Escabi, June 2, 2008
%
function  [VelData]=velocitytrajectory(T,X,Y,Cm,Fsd,Fc,disp)

%Input Arguments
if nargin<7
    Disp='n';
end

%Convert pixels to cm
if length(Cm)==2
    X=X*(10/Cm(1));
    Y=Y*(10/Cm(2));
else 
    X=X*(10/Cm);
    Y=Y*(10/Cm);
end

%Find Missing Position Points and discard
index=find(X~=0);
T=T(index)*1E-6;    %Converts to seconds
X=X(index);
Y=Y(index);

%Interpolate to a Fixed Sampling Rate
MinT=min(T);
MaxT=max(T);
Ti=MinT:1/Fsd:MaxT;
Xi = interp1(T,X,Ti,'cubic');
Yi = interp1(T,Y,Ti,'cubic');

%Finding Velocity and Speed
Vx=diff(Xi)*Fsd;
Vy=diff(Yi)*Fsd;
V=Vx+Vy*i;
S=abs(V);

%Arranging Data as Data Structure
VelData.T=Ti(1:length(V));
VelData.X=Xi(1:length(V));
VelData.Y=Yi(1:length(V));
VelData.V=V;
VelData.S=S;

%Filtering and Regenerating Velocity Trajectories
[H] = lowpass(Fc,2.5,Fsd,40,'n');
H=H/sum(H)          %Escabi 2013, Make passband gain=1
N=(length(H)-1)/2;
Xi=conv(Xi,H);
Yi=conv(Yi,H);
Xi=Xi(N+1:length(Xi)-N);
Yi=Yi(N+1:length(Yi)-N);

%Finding Velocity and Speed
Vx=diff(Xi)*Fsd;
Vy=diff(Yi)*Fsd;
V=Vx+Vy*i;
S=abs(V);

%Arranging Data as Data Structure
%VelData.T=Ti(1:length(V));
VelData.Xh=Xi(1:length(V));
VelData.Yh=Yi(1:length(V));
VelData.Vh=V;
VelData.Sh=S;
VelData.Xn=(VelData.X-min(VelData.X))/(max(VelData.X)-min(VelData.X)); 
VelData.Xhn=(VelData.Xh-min(VelData.Xh))/(max(VelData.Xh)-min(VelData.Xh));

%Plotting normalized X-position data over time, which is used to determine
%Xthresh for segmentvelocity

if disp == 'y'
    figure
    plot(VelData.T,VelData.Xn)
end


