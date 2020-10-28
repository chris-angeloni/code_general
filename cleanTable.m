function t = cleanTable(t,fn)

if ~exist('fn','var') | isempty(fn)
    fn = t.Properties.VariableNames;
end

% for each fieldname
for i = 1:length(fn)
    
    tmp = t.(fn{i});
    
    if isa(tmp,'cell')
        if isa(tmp{1},'double')
            
            % check for 1d vectors
            if any(size(tmp{1})==1)
                
                % check if vector is vertical
                if size(tmp{1},1) > 1
                    
                    % if its vertical, reshape so it is horizontal
                    % when concatenating to a matrix
                    t.(fn{i}) = reshape(vertcat(tmp{:}), ...
                                        max(size(tmp{1})),[])';
                else
                    
                    % if it is already horizontal, just vertcat
                    t.(fn{i}) = vertcat(tmp{:});
                    
                end
                
            end

        end
        
    end
    
end
