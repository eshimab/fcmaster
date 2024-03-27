function myCompareStruct(s1, s2, path)
    if nargin < 3
        path = 'Root';
    end

    % Combine and unique fields from both structs
    fields1 = fieldnames(s1);
    fields2 = fieldnames(s2);
    allFields = unique([fields1; fields2]);

    % Iterate through all fields for comparison
    for i = 1:length(allFields)
        currentField = allFields{i};
        newPath = fullfile(path, currentField); % Using fullfile for easy path construction
        
        if isfield(s1, currentField) && isfield(s2, currentField)
    % If both fields are structs and recurse into them
    if isstruct(s1.(currentField)) && isstruct(s2.(currentField))
        % Recurse into nested structs
        myCompareStruct(s1.(currentField), s2.(currentField), newPath);
    else
        % For non-struct fields, check if they are equal
        if ~isequal(s1.(currentField), s2.(currentField))
            % Only use mat2str for simple types, check if not a struct before converting
            if ~isstruct(s1.(currentField)) && ~isstruct(s2.(currentField))
                disp(['Difference found at ', newPath, ': ',...
                    'in s1: ', mat2str(s1.(currentField)), ' vs ',...
                    'in s2: ', mat2str(s2.(currentField))]);
            else
                % For structs, indicate a difference without using mat2str
                disp(['Structural difference found at ', newPath]);
            end
        end
    end
else
    % Field is missing in one of the structs
    if isfield(s1, currentField)
        disp(['Field missing in s2 at ', newPath]);
    else
        disp(['Field missing in s1 at ', newPath]);
    end
end

    end
end
