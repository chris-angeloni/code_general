function colmap=rainbow(mapLength);

% function colmap=rainbow(mapLength);

if nargin + nargout == 0
    h = get(gca,'child');
    mapLength = length(h);
  elseif nargin == 0
    mapLength = size(get(gcf,'colormap'),1);
  end

if mapLength>1,
  R=zeros(mapLength,3);
  R(:,1) = interp1(1:5,[0  0 .9   1 .9], 1:4/(mapLength-1):5)';  % red
  R(:,2) = interp1([1 1.5 2 3 4 5],[0 .5 .7 .9 .45  0], 1:4/(mapLength-1):5)';  % green
  R(:,3) = interp1(1:5,[1  0  0   0  0], 1:4/(mapLength-1):5)';  % blue

  if nargin + nargout == 0
      % Apply to lines in current axes.
      for k = 1:mapLength
        if strcmp(get(h(k),'type'),'line')
          set(h(k),'color',R(k,:))
          end % (if strcmp)
        end % (for k)
    else
      colmap = R;
    end % (if nargin)

  end % (if mapLength)

return
