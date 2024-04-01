

% loadCells = {
%   '/Users/eshim/hotfcm/DATA/HOT_FCM/HOT_2020_318_to_325/HOT325/HOT325_CONFIG/20210602_SURF-BDS.xml',
%   '/Users/eshim/hotfcm/DATA/HOT_FCM/HOT_2022_335_to_339/HOT339/HOT339_CONFIG/20230211_SURF.xml'
% }

% 
% 
% Version 1.0.0
% 
% Initialize the structure and variables for path tracking
xmlstc = struct();
prevCurrentPath = {}; % Keeps track of the nesting level
prevIndentlvls = [];
idxline = 0;
fid = fopen('/Users/eshim/hotfcm/DATA/HOT_FCM/HOT_2022_335_to_339/HOT339/HOT339_CONFIG/20230211_SURF.xml', 'r');
if fid == -1
    error('File could not be opened.');
end

while ~feof(fid)
    tline = fgetl(fid);
    if isa(tline, 'double') % Check if the end of file is reached
        break;
    end
    idxline = idxline + 1;
    currentPath = prevCurrentPath;
    indentLevel = (length(tline) - length(strtrim(tline))) / 2 + 1   
    tagValue = '' 
    % Open Tags without Attributes
    if ~isempty(regexp(tline, '^<\w+>$', 'once'))
        % This matches tags like <EventSource>
        tagName = regexp(tline, '^<(\w+)>$', 'tokens', 'once')
        tagType = 'openTagWithoutAttributes';
        currentPath{indentLevel} = tagName
    % Open Tags with Attributes
    elseif ~isempty(regexp(tline, '^<\w+\s+[^>]+>$', 'once'))
        % This matches tags like <Element Version="1">
        [tagName, attributes] = regexp(tline, '^<(\w+)\s+([^>]+)>$', 'tokens', 'once');
        tagType = 'openTagWithAttributes';
    % Inline Tags
    elseif ~isempty(regexp(tline, '^<\w+>.*</\w+>$', 'once'))
        % This matches tags like <Name>Cytometer</Name>
        [tagName, tagContent] = regexp(tline, '^<(\w+)>([^<]+)</\1>$', 'tokens', 'once');
        tagType = 'inlineTag';
        tagValue = char(regexp(tline,'(?<=\s*)(<)([a-zA-Z0-9]*)(>)([a-zA-Z0-9]|\.|\s|-|\(|\))*(<\/)([a-zA-Z0-9]*)(>)*(>)','match'))
    % Closing Tags
    elseif ~isempty(regexp(tline, '^</\w+>$', 'once'))
        % This matches tags like </EventSource>
        tagName = regexp(tline, '^</(\w+)>$', 'tokens', 'once');
        tagType = 'closingTag';
    else
        % Unrecognized or complex line format
        tagType = 'unrecognized';
    end
    end
end

prevCurrentPath = {'Configuration' 'CytometerConfiguration' 'Experiment' 'DataSource' 'Element'}
% We will add 1 to each indent level so the indexing starts at 1 and not 0
prevIndentlvls = [1 2 3 4]
currentLineTag = 'Name'
currentLineIndent = 5
currentLineValue = 'Cytometer'
currentPath = horzcat(prevCurrentPath,{currentLineTag})
currentIndentlvls = [prevIndentlvls currentLineIndent]

% Update the nested structure
xmlstc2 = updateNestedStruct(xmlstc, currentPath, currentLineValue)




xmlstc = struct;
xmlstc.Configuration.Attr_Version = '1';
xmlstc.Configuration.Name.Value = '20230211_SURF';
xmlstc.Configuration.Name.Line = 2; % Assuming the line numbers start from 1
xmlstc.Configuration.CreationDate.Value = '2023-02-11T14:16:24.966871-10:00';
xmlstc.Configuration.CreationDate.Line = 3;
xmlstc.Configuration.Description.Value = '';
xmlstc.Configuration.Description.Line = 4;
xmlstc.Configuration.CytometerConfiguration.Attr_Version = '1';
xmlstc.Configuration.CytometerConfiguration.Name.Value = '';
xmlstc.Configuration.CytometerConfiguration.Name.Line = 6;
xmlstc.Configuration.CytometerConfiguration.CreationDate.Value = '2023-02-11T14:16:24.966871-10:00';
xmlstc.Configuration.CytometerConfiguration.CreationDate.Line = 7;
xmlstc.Configuration.CytometerConfiguration.Description.Value = '';
xmlstc.Configuration.CytometerConfiguration.Description.Line = 8;
xmlstc.Configuration.CytometerConfiguration.Experiment.Attr_Version = '1';
xmlstc.Configuration.CytometerConfiguration.Experiment.DataSource.Attr_Version = '1';
xmlstc.Configuration.CytometerConfiguration.Experiment.DataSource.Element.Attr_Version = '1';
xmlstc.Configuration.CytometerConfiguration.Experiment.DataSource.Element.Name = ''
xmlstc.Configuration.CytometerConfiguration.Experiment.DataSource.Guid.Value = '2e14b381-784e-443d-9f24-f7396faabacc';
xmlstc.Configuration.CytometerConfiguration.Experiment.DataSource.HasData.Value = 'false';
xmlstc.Configuration.CytometerConfiguration.Experiment.DataSource.NumEvents.Value = '10000';





tempStruct = xmlstc;
for idxInd = 1:currentLineIndent
  if isfield(tempStruct,currentPath{idxInd})
    tempStruct = tempStruct.(currentPath{idxInd})
  elseif ~isfield(tempStruct,currentPath{currentLineIndent})
    tempStruct = addfield(tempStruct,currentPath{idxInd})
  end
end
tempStruct.(currentLineTag) = currentLineValue

% Here we would reinster the tempStruct 
% xmlstc.Configuration.CytometerConfiguration.Experiment.DataSource.Element.Name
% Into the appropriate part of xmlstc


fclose(fid);

  % ----------------- Prep CellStrings -------------------
  linecells = reshape(linecells,[],1); % Make Column
  % linecells = linecells(2:end-1); % Trim first and last lines
  linenums = (1:length(linecells))';
  indentlvl = cellfun(@(CELLSTR) regexp(CELLSTR,'(\s)(?=<)'), linecells, 'UniformOutput', false);
  indexZero = cellfun(@(CELLDBL) isempty(CELLDBL),indentlvl);
  [indentlvl{indexZero}] = deal(0);
  % indentFinal = cell2mat(indentlvl) / 2;
  indentdbl = cell2mat(indentlvl) / 2;
  tagcells = cellfun(@(CELLSTR) regexp(CELLSTR,'(?<=\s*)(<)([a-zA-Z0-9]*)(>)','match'),linecells,'UniformOutput',false);

% end
% end for idxload