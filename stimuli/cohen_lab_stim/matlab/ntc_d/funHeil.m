function f = funHeil(x,xdata)
% function f = funHeil(paramHeil,xdata)
%
% function used for computing Peter Heil's representation of onset latency
% xdata is supposed to be max peak to peak acceleration of stimulus at onset
%  (in Pa/s/s)
% paramHeil is (from Heil's papers):  [Lmin A 10^(-S)]

% parameters are x
% data values are xdata

f = x(1) + x(2)*(log10(xdata/x(3)).^(-4));
% = lmin + A*log(X/U).^(-4)

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
