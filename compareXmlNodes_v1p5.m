
%
%
%
%
% Version 1.5 with Metrics

function compareXmlNodes(node1, node2, nodeName1, nodeName2, varargin)
  % Initialize counters
  totalDifferences = 0;
  displayedDifferences = 0;
  totalMissingInNode1 = 0;
  totalMissingInNode2 = 0;
  displayedMissingInNode1 = 0;
  displayedMissingInNode2 = 0;

  % Create an input parser instance
  p = inputParser;

  % Define parameters 'Path' and 'SilenceFields'
  addParameter(p, 'Path', '', @ischar);
  addParameter(p, 'SilenceFields', {}, @iscell);

  % Parse the inputs
  parse(p, varargin{:});

  % Extract the variables from the parsed input
  path = p.Results.Path;
  silenceFields = p.Results.SilenceFields;

  fields1 = fieldnames(node1);
  fields2 = fieldnames(node2);
  allFields = unique([fields1; fields2]);

  for i = 1:length(allFields)
    field = allFields{i};
    newPath = fullfile(path, field);

    % Check if the current path or its parent is in the list of fields to be silenced
    if any(strcmp(newPath, silenceFields)) || any(startsWith(silenceFields, strcat(newPath, '/')))
      continue; % Skip the comparison for this field and its children (if indicated by a trailing /)
    end

    if isfield(node1, field) && isfield(node2, field)
      fieldVal1 = node1.(field);
      fieldVal2 = node2.(field);
      
      if isstruct(fieldVal1) && isstruct(fieldVal2)
        compareXmlNodes(fieldVal1, fieldVal2, nodeName1, nodeName2, 'Path', newPath, 'SilenceFields', silenceFields);
      else
        valStr1 = convertToString(fieldVal1);
        valStr2 = convertToString(fieldVal2);
        if ~strcmp(valStr1, valStr2)
          % Increment counters for differences
          totalDifferences = totalDifferences + 1;
          displayedDifferences = displayedDifferences + 1;
          fprintf('Difference found at %s: %s (%s) vs %s (%s)\n', newPath, valStr1, nodeName1, valStr2, nodeName2);
        end
      end
    else
      if isfield(node1, field)
        % Increment counters for missing in node2
        totalMissingInNode2 = totalMissingInNode2 + 1;
        displayedMissingInNode2 = displayedMissingInNode2 + 1;
        fprintf('Missing in %s: %s\n', nodeName2, newPath);
      else
        % Increment counters for missing in node1
        totalMissingInNode1 = totalMissingInNode1 + 1;
        displayedMissingInNode1 = displayedMissingInNode1 + 1;
        fprintf('Missing in %s: %s\n', nodeName1, newPath);
      end
    end
  end

  % At the end, print the statistics
  fprintf('\nTotal Differences: %d\n', totalDifferences);
  fprintf('Displayed Differences: %d\n', displayedDifferences);
  fprintf('Total Missing in %s: %d\n', nodeName1, totalMissingInNode1);
  fprintf('Displayed Missing in %s: %d\n', nodeName1, displayedMissingInNode1);
  fprintf('Total Missing in %s: %d\n', nodeName2, totalMissingInNode2);
  fprintf('Displayed Missing in %s: %d\n', nodeName2, displayedMissingInNode2);
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

