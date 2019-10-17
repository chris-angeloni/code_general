function paramHeil = compHeilParms(paramHeil0);
% function paramHeil = compHeilParms(paramHeil0);
%
% try this:
%  global fMin nOctaves extAtten
%  [dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);
%  ph = compHeilParms
%% (if ph is not almost real, something is wrong, so don't bother with 
%%   the rest.  you may get warnings about bad conditioning, though...))
%  ph = real(ph);
%  figure
%  plot(dispAmps, firstSigSpikes, 'bo');
%  hold on;
%  plot(dispAmps, funHeil(ph, splToMaxPeakAccel(dispAmps, 0.003)), 'rx-');
%

global fMin nOctaves extAtten

if nargin<1,
    % typical cortical values, from one of Heil's papers   
    paramHeil0 = [13; 13000; 10.^(-4.5)];    
  end % (if)   
tOnset = 0.003;   % onset time for stimulus (sin^2 ramp time)

[dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);

ydata = firstSigSpikes;
xdata = splToMaxPeakAccel(dispAmps(isfinite(ydata)), tOnset);
ydata = ydata(isfinite(ydata))';

paramHeil=curvefit('funHeil',paramHeil0,xdata,ydata,[],'gradHeil');

return
