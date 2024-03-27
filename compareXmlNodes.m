%
%
%
%
% Version 2.2

function compareXmlNodes(node1, node2, nodeName1, nodeName2, varargin)
    % Initialize input parser
    p = inputParser();
    % p = inputParser;
    addParameter(p, 'Path', '', @ischar);
    addParameter(p, 'SilenceFields', {}, @iscell);
    addParameter(p, 'FileId', -1, @(x) isnumeric(x) && (x >= -1)); % Correctly handling FileId
    parse(p, varargin{:});
    
    path = p.Results.Path;
    silenceFields = p.Results.SilenceFields;
    fileId = p.Results.FileId;
    
    % Open a file for writing the output if FileId is not provided
    if fileId == -1
        fileId = fopen('/Users/eshim/FCM/fcodem/Master_Code/xmldifs.txt', 'w');
        if fileId == -1
            error('Failed to open file for writing.');
        end
        shouldCloseFile = true; % Flag to close file later
    else
        shouldCloseFile = false;
    end
    
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
              compareXmlNodes(fieldVal1, fieldVal2, nodeName1, nodeName2, 'Path', newPath, 'SilenceFields', silenceFields, 'FileId', fileId);
            else
              messageString = ['Difference found at ' newPath ': ' convertToString(fieldVal1) ' (' nodeName1 ') vs ' convertToString(fieldVal2) ' (' nodeName2 ')'];
              message = sprintf('%s\n', messageString);
              % Construct and print message
              fprintf('%s', message);
              fprintf(fileId, '%s', message);
            end
        else
            if isfield(node1, field)
                % Construct and print message for missing in node2
                message = sprintf('Missing in %s: %s\n', nodeName2, newPath);
            else
                % Construct and print message for missing in node1
                message = sprintf('Missing in %s: %s\n', nodeName1, newPath);
            end
            fprintf('%s', message);
            fprintf(fileId, '%s', message);
        end
    end
    
    % Close the file if it was opened in this function
    if shouldCloseFile
        fclose(fileId);
    end
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