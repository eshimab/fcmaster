%
%
%
%
% Version 2.0

function compareXmlNodes(node1, node2, nodeName1, nodeName2, varargin)
    % Open a file for writing the output
    fileId = fopen('/Users/eshim/FCM/fcodem/Master_Code/xmldifs.txt', 'w');
    
    p = inputParser;
    addParameter(p, 'Path', '', @ischar);
    addParameter(p, 'SilenceFields', {}, @iscell);
    parse(p, varargin{:});
    
    path = p.Results.Path;
    silenceFields = p.Results.SilenceFields;
    
    fields1 = fieldnames(node1);
    fields2 = fieldnames(node2);
    allFields = unique([fields1; fields2]);
    
    for i = 1:length(allFields)
        field = allFields{i};
        newPath = fullfile(path, field);

        silenceMatch = any(cellfun(@(pattern) ~isempty(regexp(newPath, pattern, 'once')), silenceFields));

        if silenceMatch
            continue; % Skip silenced fields
        end

        if isfield(node1, field) && isfield(node2, field)
            fieldVal1 = node1.(field);
            fieldVal2 = node2.(field);
            
            if isstruct(fieldVal1) && isstruct(fieldVal2)
                compareXmlNodes(fieldVal1, fieldVal2, nodeName1, nodeName2, 'Path', newPath, 'SilenceFields', silenceFields);
            else
                % Construct message
                message = sprintf('Difference found at %s: %s (%s) vs %s (%s)\n', newPath, convertToString(fieldVal1), nodeName1, convertToString(fieldVal2), nodeName2);
                % Print to MATLAB command window
                fprintf('%s', message);
                % Write to file
                fwrite(fileId, message);
            end
        else
            if isfield(node1, field)
                % Construct message for missing in node2
                message = sprintf('Missing in %s: %s\n', nodeName2, newPath);
            else
                % Construct message for missing in node1
                message = sprintf('Missing in %s: %s\n', nodeName1, newPath);
            end
            % Print to MATLAB command window
            fprintf('%s', message);
            % Write to file
            fwrite(fileId, message);
        end
    end
    
    fclose(fileId); % Close the file when done
end

function outStr = convertToString(val)
    if isnumeric(val) || islogical(val)
        outStr = mat2str(val);
    elseif ischar(val) || isstring(val)
        outStr = val;
    else
        outStr = 'Unsupported type';
    end
end

%
%
%
%
%
