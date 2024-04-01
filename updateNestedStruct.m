function updatedStruct = updateNestedStruct(struct, path, value)
    % Base case: If the path is of length 1, update or add the field directly
    if length(path) == 1
        struct.(path{1}) = value;
        updatedStruct = struct;
        return;
    end

    % Recursive case: Navigate down the structure
    currentField = path{1};
    % If the current field does not exist, initialize it as an empty struct
    if ~isfield(struct, currentField)
        struct.(currentField) = struct()
    end

    % Recursively update the nested structure
    % Pass the remainder of the path (excluding the current field) and the value
    struct.(currentField) = updateNestedStruct(struct.(currentField), path(2:end), value)

    % Return the updated structure
    updatedStruct = struct;
end
