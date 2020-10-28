function [fields,nI] = tableInfo(dat)

% displays variable names and types for each table variable,
% returns field names and indices of numeric/logical fields

fields = dat.Properties.VariableNames;
for i = 1:length(fields)
    fprintf('%s:',fields{i})
    fprintf('  %d x %d %s\n',...
            size(dat.(fields{i}),1),...
            size(dat.(fields{i}),2),...
            class(dat.(fields{i})));
   
    % is numeric or logical?
    nI(i) = isnumeric(dat.(fields{i})) | islogical(dat.(fields{i}));
    
end