%
%
%
%
%

function compareXmlNodes(node1, node2, path)
  if nargin < 3
    path = '';
  end

  fields1 = fieldnames(node1);
  fields2 = fieldnames(node2);
  allFields = unique([fields1; fields2]);

  for i = 1:length(allFields)
    field = allFields{i};
    newPath = fullfile(path, field); % Enhanced path construction for clarity

    if isfield(node1, field) && isfield(node2, field)
      fieldVal1 = node1.(field);
      fieldVal2 = node2.(field);

      if iscell(fieldVal1) && iscell(fieldVal2)
        % Check for cell arrays of structs
        if length(fieldVal1) == length(fieldVal2)
          for j = 1:length(fieldVal1)
            if isstruct(fieldVal1{j}) && isstruct(fieldVal2{j})
              compareXmlNodes(fieldVal1{j}, fieldVal2{j}, sprintf('%s[%d]', newPath, j));
            else
              fprintf('Difference in cell array element at %s[%d]\n', newPath, j);
            end
          end
        else
          fprintf('Mismatch in cell array lengths at %s\n', newPath);
        end
      elseif isstruct(fieldVal1) || isstruct(fieldVal2)
        if isstruct(fieldVal1) && isstruct(fieldVal2)
          compareXmlNodes(fieldVal1, fieldVal2, newPath); % Recursively compare structs
        else
          fprintf('Type mismatch found at %s\n', newPath); % Report type mismatch
        end
      else
        valStr1 = convertToString(fieldVal1);
        valStr2 = convertToString(fieldVal2);
        if ~strcmp(valStr1, valStr2)
          fprintf('Difference found at %s: %s vs %s\n', newPath, valStr1, valStr2); % Report value difference
        end
      end
    else
      if isfield(node1, field)
        fprintf('Missing in node2: %s\n', newPath); % Report missing field in node2
      else
        fprintf('Missing in node1: %s\n', newPath); % Report missing field in node1
      end
    end
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
