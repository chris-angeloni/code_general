function appendAttributes

global allAttributes newAttributes allComments

INCLUDE_DEFS;

if ~isempty(newAttributes),
    [hobj] = gcbo;

    set(hobj,'backgroundcolor',NORMBUTTONCOLOR);
    if ~isempty(allAttributes),
        if any(newAttributes(1) == allAttributes(:,1)),
            hmessages = findobj('tag','MessageText');
            set(hmessages,'backgroundcolor',WARNCOLOR);
            set(hmessages,'string', ...
                '*** WARNING *** multiple entries for filename in allAttributes');
          end
      end

    newAttributes(DEPTH) = str2num(get(findobj('tag','DepthEdit'),'string'));
    newAttributes(ATTENC) = str2num(get(findobj('tag','AttenCEdit'),'string'));
    newAttributes(ATTENI) = str2num(get(findobj('tag','AttenIEdit'),'string'));

    unitString =get(findobj('tag','UnitEdit'),'string');
    if ~strcmp(unitString, 'NaN') & isletter(unitString(end)),
        unitChar = unitString(end);
        unitString = unitString(1:(end-1));
        newAttributes(UNITNUM) = str2num(unitString)+(unitChar-'A'+1)/100;
      else
        newAttributes(UNITNUM) = str2num(unitString);
      end

    allAttributes = [allAttributes; newAttributes];
    newRow = size(allAttributes,1);
    hCE = findobj('tag','TCCommentEdit');
    newComment = get(hCE, 'string');
    if isempty(newComment) | strcmp(newComment, noCommentString),
        allComments{newRow,1} = '';
      else
        allComments{newRow,1} = newComment;
      end; % (if)

    hSB = findobj('tag','SaveButton');
    set(hSB,'backgroundcolor',WARNCOLOR);
  end; % (if)
  
return
