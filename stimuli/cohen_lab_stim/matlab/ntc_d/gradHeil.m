function g = gradHeil(paramHeil,xdata)
% function g = gradHeil(paramHeil,xdata)
%
% gradient used for computing Peter Heil's representation of onset latency
% g is gradient
% xdata is supposed to be max peak to peak acceleration of stimulus at onset
%  (in Pa/s/s)
% paramHeil is (from Heil's papers):  [Lmin A 10^(-S)]


g1 = ones(size(xdata));
g2 = log10(xdata/paramHeil(3)).^(-4);
%  = log10(paramHeil/U).^(-4)
g3 = 4*paramHeil(2)*log(10)^4/paramHeil(3)*(log(xdata/paramHeil(3))).^(-5);
%  = 4*A*log(10)^4/U*log(paramHeil/U).^(-5)

g = [g1; g2; g3];

return

% for example, for a sinusoid (pure tone):
% peak sound pressure (in Pascals) = sqrt(2)*(2E-5 Pa)*10^(db_SPL/20)

% so for sin^2 onset (e.g., for a slow 0.03 ms onset time -> 
%                     full period = T = 0.06):
% APP = (2*pi/T)^2 * sqrt(2) * 2E-5 * 10^(db_SPL/20)

tOnset = 0.03;
db_SPL = 0:10:90;
APP = splToMaxPeakAccel(db_SPL, tOnset);
% APP = (2*pi/T).^2 * sqrt(2) * 2E-5 * 10 .^(db_SPL/20);   % in Pa/s/s
xdata = APP;

lmin = 13;          % minimum latency (ms)
A = 13000;          % latency factor (ms)
S = 4.5;            % 
U = 10.^(-S);       % normalization factor (Pa/s/s)

xdata = APP;
ydata = lmin + A*(log10(xdata/U)).^-4;
noisyYData = ydata+10*(rand(1,length(xdata))-0.5);

semilogx(xdata,ydata,'o-');  
hold on;
semilogx(xdata, noisyYData, 'go-');
xlabel('max acceleration of peak pressure (Pa/s/s)');
ylabel('mean minimum latency (ms)');

paramHeil0 = [12; 12000; 10^(-5)];    % initial guess
paramHeil=curvefit('funHeil',paramHeil0,xdata,noisyYData,[],'gradHeil')
semilogx(xdata, funHeil(paramHeil, xdata), 'ro-');

% should return values near [lmin; A; U]
