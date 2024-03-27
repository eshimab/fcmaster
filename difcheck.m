%
%
%
%
% Version 1.0.0
%
function difcheck(outputFile)
    % outputFile: Path to the text file generated by compareXmlNodes

    % Open the file for reading
    fileId = fopen(outputFile, 'r');
    if fileId == -1
        error('Failed to open file for reading.');
    end
    
    % Prepare a pattern to match lines with differences
    pattern = 'Difference found at (.+): (.+) \((xmlstc\d+)\) vs (.+) \((xmlstc\d+)\)';
    
    % Loop over each line in the file
    while ~feof(fileId)
        line = fgetl(fileId);
        
        % Use regular expression to extract relevant parts of the line
        tokens = regexp(line, pattern, 'tokens');
        if ~isempty(tokens)
            tokens = tokens{1}; % Extract the first (and only) match group
            
            % Extract values and names
            path = tokens{1};
            value1 = tokens{2};
            name1 = tokens{3};
            value2 = tokens{4};
            name2 = tokens{5};
            
            % Check if the values are the same
            if strcmp(value1, value2)
                fprintf('No real difference at %s: %s (%s) vs %s (%s)\n', path, value1, name1, value2, name2);
            end
        end
    end
    
    % Close the file
    fclose(fileId);
end

%
%
%
%
%