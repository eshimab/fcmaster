% function contable=cfpNano(loadstring,filenameis)
% Written by Eric Shimabukuro
% read in .xml files and converts the configuration files into a matlab table


clear xmlstc325 xmlstc326 xmlstc
loadstring = '/Users/eshim/hotfcm/DATA/HOT_FCM/HOT_2020_318_to_325/HOT325/HOT325_CONFIG/20210602_SURF-BDS.xml'
xmldata = xmlread(loadstring);
rootElement = xmldata.getDocumentElement;
xmlstc325 = myXml2Struct(rootElement)
clear xmldata rootElement loadstring
loadstring = '/Users/eshim/hotfcm/DATA/HOT_FCM/HOT_2022_335_to_339/HOT339/HOT339_CONFIG/20230211_SURF.xml'
xmldata = xmlread(loadstring);
rootElement = xmldata.getDocumentElement;
xmlstc339 = myXml2Struct(rootElement)

% myCompareStruct(xmlstc325, xmlstc339)

compareXmlNodes(xmlstc325,xmlstc339)

% Now xmlStruct mirrors the structure of your XML in MATLAB struct form


% Get the document's root element
rootElement = xmldata.getDocumentElement

% Find the CreationDate element. This returns a NodeList
creationDateElements = rootElement.getElementsByTagName('CreationDate');

% Check if the CreationDate element exists
if creationDateElements.getLength > 0
    % Assuming there's only one CreationDate element, get the first item
    creationDateElement = creationDateElements.item(0);
    
    % Get the text content of the CreationDate element
    disp(['Creation Date: ', creationDateText]);
else
    disp('CreationDate element not found.');
end




xmldata.Configuration.Name = '20210602_SURF-BDS'
xmldata.Configuration.CreationDate = '2021-06-02T10:36:30.515631-10:00'
...
xmldata.Configuration.Experiment = 'Version="1"'
xmldata.Configuration.Experiment.DataSource = 'Version="1"'
xmldata.Configuration.Experiment.DataSource.Element = 'Version="1"'
xmldata.Configuration.Experiment.DataSource.Name = 'Cytometer'
xmldata.Configuration.Experiment.DataSource.Element.Name = 'Version="1"'
xmldata.Configuration.Experiment.DataSource.Guid = '2e14b381-784e-443d-9f24-f7396faabacc'
...
xmldata.Configuration.Experiment.DataSource.EventSource.Settings.Laser.Name = {'Laser 1 (488)' 'Laser 2'}
xmldata.Configuration.Experiment.DataSource.EventSource.Settings.Laser.Delay = {'0' '5.2'} 
...
etc


loadCells = {
  '/Users/eshim/hotfcm/DATA/HOT_FCM/HOT_2021_326_to_334/HOT326/HOT326_CONFIG/20210603_SURF-BDS.xml',
  '/Users/eshim/hotfcm/DATA/HOT_FCM/HOT_2022_335_to_339/HOT339/HOT339_CONFIG/20230211_SURF.xml'
}



% for idxload = 1:length(loadCells)
for idxload = 1
  loadstring = loadCells{idxload}
  fid = fopen(loadstring);
  % ----------------- Loop Init -------------------
  idxline = 0;
  tline = '';
  linecells = {''};
  % ----------------- Get all lines into Cellstrings -------------------
  while ischar(tline)
    tline = fgetl(fid);
    idxline = idxline + 1;
    linecells{idxline} = tline;
  end
  fclose(fid);
  % ----------------- Prep CellStrings -------------------
  linecells = reshape(linecells,[],1); % Make Column
  % linecells = linecells(2:end-1); % Trim first and last lines
  linenums = (1:length(linecells))';
  indentlvl = cellfun(@(CELLSTR) regexp(CELLSTR,'(\s)(?=<)'), linecells, 'UniformOutput', false);
  indentzero = cellfun(@(CELLDBL) isempty(CELLDBL),indentlvl);
  [indentlvl{indentzero}] = deal(0);
  indentFinal = cell2mat(indentlvl) / 2;
  indentdbl = cell2mat(indentlvl) / 2;
  tagcells = cellfun(@(CELLSTR) regexp(CELLSTR,'(?<=\s*)(<)([a-zA-Z0-9]*)(>)','match'),linecells,'UniformOutput',false);

end


% indexTagBegin = cellfun(@(CELLCELL) ~isempty(CELLCELL),tagcells,'UniformOutput',true);
% tagsolos = cellfun(@(CELLSTR) regexp(CELLSTR,'(?<=\s*)(<)([a-zA-Z0-9]*)(?=\s)','match'),linecells,'UniformOutput',false);
% indexTagSolos = cellfun(@(CELLCELL) ~isempty(CELLCELL),tagsolos,'UniformOutput',true);

% Captures with <Prop>Value</Prop>
tagInline = cellfun(@(CELLSTR) regexp(CELLSTR,'(?<=\s*)(<)([a-zA-Z0-9]*)(>)([a-zA-Z0-9]|\.|\s|-|\(|\))*(<\/)([a-zA-Z0-9]*)(>)*(>)','match'),linecells,'UniformOutput',false);
indexTagInline = cellfun(@(CELLCELL) ~isempty(CELLCELL),tagInline,'UniformOutput',true);

% Captures lines with </Prop> only
tagBlockBeg   = cellfun(@(CELLSTR) regexp(CELLSTR,'(?<=\s)(<)([a-zA-Z]*)(>)(?=\s*)','match'),linecells,'UniformOutput',false);
indexBlockBeg = cellfun(@(CELLCELL) ~isempty(CELLCELL),tagBlockBeg,'UniformOutput',true);

% Captures lines with </Prop> only
tagBlockEnd = cellfun(@(CELLSTR) regexp(CELLSTR,'(?<=\s)(<\/)([A-Z])\w+.(>)','match'),linecells,'UniformOutput',false);
indexBlockEnd = cellfun(@(CELLCELL) ~isempty(CELLCELL),tagBlockEnd,'UniformOutput',true);
% Captures lines with <Prop> Version="1"> only
tagBlockVersion = cellfun(@(CELLSTR) regexp(CELLSTR,'(<)([a-zA-Z]*)\s(Version=")([0-9]*)','match'),linecells,'UniformOutput',false);
indexBlockVersion = cellfun(@(CELLCELL) ~isempty(CELLCELL),tagBlockVersion,'UniformOutput',true);
sum(indexBlockVersion)

lineMain = linecells;
lineMain(indexTagInline)    = linecells(indexTagInline);
lineMain(indexBlockBeg)     = linecells(indexBlockBeg);
lineMain(indexBlockEnd)     = linecells(indexBlockEnd);
lineMain(indexBlockVersion) = linecells(indexBlockVersion);

% Store Tag Type (Beg, End, Inline, Version)
tagType = zeros(length(tagMain),1);
tagType(indexTagInline)    =  1;
tagType(indexBlockBeg)     =  2;
tagType(indexBlockVersion) =  4;

sumTagType = sum(tagType == 0)

% Check for Empty Cells
indexEmpty = cellfun(@(CELLCELL) isempty(CELLCELL),lineMain);
sumEmptyCells = sum(indexEmpty);
if sumEmptyCells > 0
  sprintf([' Missing ' num2str(sumEmptyCells) ' Values! Returning\n'])
  return
end

% Remove whitespace
lineMain = cellfun(@(CELLSTR) strtrim(CELLSTR),lineMain,'UniformOutput',false); 
tagMain = repmat({''},length(lineMain),1);
% 
regString = '(?<=<([a-zA-Z0-9]*)(>))([a-zA-Z0-9]|\.|\s|-|\(|\)|\_|\:)*(?=(<\/)([a-zA-Z0-9]*)(>)*(>))';
tagMain(indexTagInline | indexBlockBeg) = cellfun(@(CELLSTR) char(regexp(CELLSTR,'(?<=<)([a-zA-Z0-9])*(?=>)','match')),lineMain(indexTagInline | indexBlockBeg),'UniformOutput',false);
% 
regString = '(?<=<)(\/)([a-zA-Z0-9]|\.|\s|-|\(|\)|\_|\:)*(?=>)';
tagMain(indexBlockEnd) = cellfun(@(CELLSTR) char(regexp(CELLSTR, regString, 'match')),lineMain(indexBlockEnd),'UniformOutput',false);
% 
regString = '(?<=<([a-zA-Z0-9]*))([a-zA-Z0-9]|\.|\s|-|\(|\)|\_|\:)*(?=\sVersion)';
tagMain(indexBlockVersion) = cellfun(@(CELLSTR) char(regexp(CELLSTR, regString, 'match')),lineMain(indexBlockVersion),'UniformOutput',false);


% confMain = struct(); 
% prevIndent = 0;
maxindent = max([indentlvl{:}])/2;
% Get inline tags and block open tags w/o


% Loop thru tags and indent levels
curStruct = confMain;

propMain = horzcat()

confMain.source = linecells;

for idxlvl = 1:curIndent
  curFields = fieldnames(confMain);
  if ismember(curTag,curFields)

  end
  % end if ismember()

  for idxf = 1:length(curFields)
    fname = curFields{idxf};
    % end for idxf
  end
  % end for idxlvl  
end








indentVec = [indentlvl{:}] / 2;

confMainOrig = confMain;
% for idxTag = 1:length(tagMain)
for idxTag = 1:50
  idxTag = 1
  % idxTag = 39
  curString = tagMain{idxTag}
  curTag = char(regexp(curString,'(?<=<)([a-zA-Z0-9])*(?=>)','match'))
  
  curIndent = indentVec(idxTag)
  curTagType = tagType(idxTag)
  
  confMini = confMain;
  

  idxlvl = 0;
  while idxlvl < curIndent
    idxlvl = idxlvl + 1
    
    % If we are at the correct indent lvl yet
    if idxlvl == curIndent
      % get the fields
      curfields = fieldnames(confMini);
      % see if our current tag is among the fields
      % if it is not, add it.
      if ~ismember(curTag,curfields)
        confMini.(curTag) = [];
        % If our tag is among the fields
      elseif ismember(curTag,curfields)
        % extract the substruct with our curent tag
        confMini = confMini.(curTag);
        % Find out what kind of tag this is
        % if tag type is inline value
        if curTagType == 1
          confMini.('Value') = curString;
          % elseif tag type is the beginning of a block
        elseif curTagType == 2
        elseif curTagType == 3
        elseif curTagType == 4
        end
        % end if curTagType
        % 
      end
      % end if ~ismember() 
    end
    % end if idxlvl
    
  end
  % end while idxlvl

  
return
  % pathCells{curIndent} =  curTag

  % pathCells = {'CreationDate' 'Experiment' 'DataSource' 'EventSource' 'Settings' 'Configuration' 'FilterBlock' 'FilterPath' }
  % curPath = pathCells(1:curIndent)
  % curStruct = struct

  


  % pathCells = {''};
  regString = '(?<=<([a-zA-Z0-9]*)(>))([a-zA-Z0-9]|\.|\s|-|\(|\)|\_|\:)*(?=(<\/)([a-zA-Z0-9]*)(>)*(>))';
  % curValue = char(regexp(curString,regString,'match'))
      idxpath = 0
      try  
        while isa(curStruct.(pathString),'struct') & idxpath < curIndent
          idxpath = idxpath + 1
          sprintf(['On Indent Level: ' num2str(idxPath)])
          pathString = pathCells{idxPath}         
        end
      catch
        curStruct.(pathString) = []
      end
      curStruct.(pathString)
    % end

    
end




end


  if isempty(confMain) || prevIndent = 0
    regString = '(?<=<([a-zA-Z0-9]*)(>))([a-zA-Z0-9]|\.|\s|-|\(|\)|\_|\:)*(?=(<\/)([a-zA-Z0-9]*)(>)*(>))';
    curValue = char(regexp(curString,regString,'match'))
    curStructPath = confMain.()
    confMain.(curTag).('Value') = curValue
  elseif curTagType == 1
    % Setup regexp to extract valur between the <tags>
    regString = '(?<=<([a-zA-Z0-9]*)(>))([a-zA-Z0-9]|\.|\s|-|\(|\)|\_|\:)*(?=(<\/)([a-zA-Z0-9]*)(>)*(>))';
    curValue = char(regexp(curString,regString,'match'))

  end


end
% end For idxTag




return
% ----------------- Getting  FCS Files -------------------
indexFcsFile = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<FCSFile>.*)(([a-zA-Z0-9]|\_|-)*\.fcs)(?=<\/FCSFile>)','match')),linecells);
  idxFcsFileNums = linenums(indexFcsFile);
  % fcsFileCells = cellfun(@(CELLSTR) char(regexp(CELLSTR,'(?<=<FCSFile>.*)(([a-zA-Z0-9]|\_|-)*\.fcs)(?=<\/FCSFile>)','match')),linecells(indexFcsFile),'UniformOutput',false); % Get FCS name strings
  idxvec = idxFcsFileNums; %
% ----------------- Getting Tubes  -------------------
indexTubesStart = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<)(Tube)(?=\s)','match')),linecells);
  idxTubesStart = linenums(indexTubesStart);
indexTubesEnd = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=</)(Tube)(?=>)','match')),linecells);
  idxTubesEnd = linenums(indexTubesEnd);
  idxvec = [idxvec ; idxTubesStart; idxTubesEnd]; %
% ----------------- Compensation ------------------
indexCompensationStart = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<)(Compensation)(?=\s)','match')),linecells);
  idxCompensationStart = linenums(indexCompensationStart);
indexCompensationEnd = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=</)(Compensation)(?=>)','match')),linecells);
  idxCompensationEnd = linenums(indexCompensationEnd);
compensationCells = reshape(arrayfun(@(VEC1,VEC2) [VEC1:VEC2], idxCompensationStart, idxCompensationEnd, 'UniformOutput', false),1,[]);
idxCompensationRange = [compensationCells{:}];
% ----------------- Get Active Channels -------------------
indexNamesFSC = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Name>)(FSC-488)(?=<\/Name>)','match')),linecells);
indexNamesSSC = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Name>)(SSC-488)(?=<\/Name>)','match')),linecells);
indexNamesRED = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Name>)(RED-488\s692\/40)(?=<\/Name>)','match')),linecells);
indexNamesGRN = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Name>)(GRN-488\s542\/27)(?=<\/Name>)','match')),linecells);
indexNamesORG = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Name>)(ORG-488\s585\/40)(?=<\/Name>)','match')),linecells);
indexChannelNames = (indexNamesFSC | indexNamesSSC | indexNamesRED | indexNamesGRN | indexNamesORG );
idxChannelNames = linenums(indexChannelNames);
idxChannelNames = idxChannelNames(~ismember(idxChannelNames,idxCompensationRange)); % Ignore entries in compensation sections
idxvec = [idxvec;idxChannelNames];
% ----------------- Detector Index -------------------
indexDetectors = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<DetectorIndex>)([a-zA-Z0-9])*(?=<\/DetectorIndex>)','match')),linecells);
idxDetectors = linenums(indexDetectors);
idxDetectorMini = idxDetectors(ismember(idxDetectors,idxChannelNames + 4) | idxDetectors < idxTubesStart(1));
  idxvec = [idxvec; idxDetectorMini];
% ----------------- Trigger Threshold -------------------
indexTriggerThreshhold = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<)(TriggerThreshold)(?=)','match')),linecells);
idxTriggerThreshhold = linenums(indexTriggerThreshhold);
  trigThreshCells = cellfun(@(CELLSTR) str2double(char(regexp(CELLSTR,'(?<=<TriggerThreshold>)([0-9]|.|)*(?=</)','match'))),linecells(indexTriggerThreshhold),'UniformOutput',false);
  idxvec = [idxvec; idxTriggerThreshhold];
% ----------------- Trigger Detector -------------------
indexTriggerChannel = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<)(TriggerDetector)(?=)','match')),linecells);
idxTriggerChannel = linenums(indexTriggerChannel);
  trigChanCells = cellfun(@(CELLSTR) str2double(char(regexp(CELLSTR,'(?<=<TriggerDetector>)([0-9]|.|)*(?=</)','match'))),linecells(indexTriggerChannel),'UniformOutput',false);
  idxvec = [idxvec; idxTriggerChannel];
% ----------------- Elimintate Params without PmtVoltage -------------------
indexPmtVoltage = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<PmtVoltage>)([0-9]|.)+([0-9]|.)(?=<)','match')),linecells);
idxPmtVoltage = linenums(indexPmtVoltage);
  idxvec = [idxvec;idxPmtVoltage];
% ----------------- Strip idxvec -------------------
idxvec = sort(unique(idxvec,'stable'),'ascend');
idxvecmini = idxvec;
% ----------------- Link Sections to Tubes ------------------- % This is where the magic happens
indexTubeMatch = idxvecmini >= idxTubesStart' & idxvecmini <= idxTubesEnd';
  % indexTubeMatch cols represent the tubes, and rows are the idxnums within that range
% ----------------- Init -------------------
conmat = NaN(width(indexTubeMatch) + 1,12);
concells = repmat({[]},width(indexTubeMatch) + 1,2);
% -----------------  -------------------
for idxfcs = 1:width(indexTubeMatch) + 1
  % ----------------- Init -------------------
  if idxfcs == 1
    % ----------------- First set has no tube (Tube = 0) -------------------
    idxvectiny = idxvecmini(idxvecmini < idxTubesStart(1)); % lines before first tube
    tinycells = linecells(idxvectiny);
    tinynums = (1:length(tinycells));
    funcilMakeMicroCells = @(idx) tinycells(tinynums(idx) + 1 : tinynums(idx) + 2); % Different from the tube sections
  else
    idxvectiny = idxvecmini(indexTubeMatch(:,idxfcs - 1));
    tinycells = linecells(idxvectiny);
    tinynums = (1:length(tinycells));
    funcilMakeMicroCells = @(idx) tinycells(tinynums(idx) + 1);
  end % END IF idxfcs
  % ----------------- Tube Meta -------------------
  conmat(idxfcs,13) = min(idxvectiny);
  conmat(idxfcs,14) = max(idxvectiny);
  % ----------------- Get Main Channels ------------------
  indexFSC = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Name>)(FSC-488)(?=<\/Name>)','match')),tinycells);
  indexSSC = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Name>)(SSC-488)(?=<\/Name>)','match')),tinycells);
  indexRED = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Name>)(RED-488\s692\/40)(?=<\/Name>)','match')),tinycells);
  indexGRN = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Name>)(GRN-488\s542\/27)(?=<\/Name>)','match')),tinycells);
  indexORG = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Name>)(ORG-488\s585\/40)(?=<\/Name>)','match')),tinycells);
  indexCHAN = [indexFSC indexSSC indexRED indexGRN  indexORG];
  % ----------------- Loop thru chans for Voltage (gain) and DetectorIndex -------------------
  for idxch = 1:5
    % ----------------- Get Fluor Channel Gains and Index -------------------
    microcells = funcilMakeMicroCells(indexCHAN(:,idxch));
    conmat(idxfcs,idxch) = str2double(char(regexp(microcells{2},'(?<=<PmtVoltage>)([0-9]|\.)*(?=</PmtVoltage>)','match')));
    conmat(idxfcs,idxch + 7) = str2double(char(regexp(microcells{1},'(?<=<DetectorIndex>)([0-9]|\.)*(?=</DetectorIndex>)','match')));
  end
  % ----------------- Other Props -------------------
  % ----------------- THRESH -------------------
  indexTHRESH = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<TriggerThreshold>)([0-9]|\.)*(?=<\/TriggerThreshold>)','match')),tinycells);
  conmat(idxfcs,6) = cellfun(@(CELLSTR) str2double(char(regexp(CELLSTR,'(?<=<TriggerThreshold>)([0-9]|\.)*(?=<\/TriggerThreshold>)','match'))),tinycells(indexTHRESH));
  % ----------------- TRIG -------------------
  indexTRIG = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<TriggerDetector>)([0-9])*(?=<\/TriggerDetector>)','match')),tinycells);
  conmat(idxfcs,7) = cellfun(@(CELLSTR) str2double(char(regexp(CELLSTR,'(?<=<TriggerDetector>)([0-9])*(?=<\/TriggerDetector>)','match'))),tinycells(indexTRIG));
  % ----------------- FCSFIle -------------------
  indexFILE = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<FCSFile>.*)(([a-zA-Z0-9]|\_|-)*\.fcs)(?=<\/FCSFile>)','match')),tinycells);
  if sum(indexFILE) == 0
    concells(idxfcs,1) = {'primary'};
  else
    concells(idxfcs,1) = cellfun(@(CELLSTR) char(regexp(CELLSTR,'(?<=<FCSFile>.*)(([a-zA-Z0-9]|\_|-)*\.fcs)(?=<\/FCSFile>)','match')),tinycells(indexFILE),'UniformOutput',false);
  end
  concells{idxfcs,2} = idxfcs - 1;
end % ----------------- END FOR: idxfcs -------------------
% ----------------- Make Final Table -------------------
concells = [repmat({filenameis},height(concells),1) concells];
contable = cell2table([concells num2cell(conmat)]);
contable.Properties.VariableNames = { 'configfile' 'fcsfile' 'tube_num' 'fsc488' 'ssc488' 'red488' 'grn488' 'org488' 'trig_lvl' 'trig_idx' 'fsc_idx' 'ssc_idx' 'red_idx' 'grn_idx' 'org_idx' 'tube_startline' 'tube_endline'};
% ----------------- Save Output -------------------
% savestring = [filediris filesep() 'matfiles' filesep() strrep([ 'cfp_' filenameis],'.xml','.mat') ];
% save(savestring,'contable','-v7.3')
% fprintf([newline()' Saving contable output for '  filenameis' newline() newline() '  ' ]);
% --------------------------- END: OF CONFIG PARSE -----------------------------
% Return to cfpMacro
return

% ----------------- Error Check -------------------
% indexTagEnd = cellfun(@(CELLSTR) (strcmp(CELLSTR(2), '/' ) & ~strcmp(CELLSTR(end-1), '/' )), linecells, 'UniformOutput',true);
% indexTagBegin = cellfun(@(CELLSTR) ( ~strcmp(CELLSTR(2), '/')  & ~strcmp(CELLSTR(end-1), '/' )), linecells, 'UniformOutput',true);
% indexTagCont = cellfun(@(CELLSTR) (~strcmp(CELLSTR(2), '/' ) & strcmp(CELLSTR(end-1), '/' )), linecells, 'UniformOutput',true);
% if sum([indexTagCont indexTagBegin indexTagEnd]) == ~length(linecells)
  % return
% end
% ----------------- Build Main Setting Structure -------------------
% indexSettingsStart = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<)(Settings)(?=\s)','match')),linecells);
% ----------------- Getting DataSource  -------------------
% indexDataSourceStart = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<)(DataSource)(?=\s)','match')),linecells);
% ----------------- EventSource ------------------
% indexEventSourceStart = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<)(EventSource)(?=>)','match')),linecells);
% ----------------- Channel Index -------------------
% indexChannelIndex = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<)(ChannelIndex>)(?=)','match')),linecells);
% idxChanIndexMini = idxChannelIndex(ismember(idxChannelIndex,idxChannelNames + 10));
% ----------------- Configuration ------------------
% indexConfigurationStart = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<)(Configuration)(?=\s)','match')),linecells);
% ----------------- Model (helps debugging) ------------------
% indexModel = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Model>)([a-zA-Z0-9]|\(|\)|\s)*(?=</Model>)','match')),linecells);
% ----------------- Secondary fcs file -------------------
% indexFcsNames = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Name>.*)(([a-zA-Z0-9]|\_|-)*\.fcs)(?=<\/Name>)','match')),linecells);
% ----------------- Find ParameterType == Measured -------------------
% indexParameterType = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<ParameterType>)(Measured)(?=<)','match')),linecells);
% ----------------- Get Parameter Start and end tags -------------------
% indexParameterStart = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<)(Parameter)(?=>)','match')),linecells);
% Only get <Parameter> if next line is <ParameterType>Measured</>
% idxParamMiniStart = idxParameterStart(ismember(idxParameterStart,idxParamTypeMini - 1));
% ----------------- Get Channel Start and end tags -------------------
% indexChannelStart = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<)(Channel)(?=>)','match')),linecells);
  % idxChannelStart = linenums(indexChannelStart); % Only get <Channel> if next line is one of our channels
% idxChanMiniStart = idxChannelStart(ismember(idxChannelStart,idxChannelNames - 1));
% ----------------- Pmt Amp Type -------------------
% indexPmtAmpType = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<PmtAmpType>)(Log)(?=<\/PmtAmpType>)','match')),linecells);
% idxPmtAmpType = linenums(indexPmtAmpType);
  % linecells(indexPmtAmpType);
  % idxvec = [idxvec ; idxPmtAmpType]; %
  % idxvec = sort(unique(idxvec,'stable'),'ascend');
% ----------------- Name -------------------
  % indexNamesAll = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Name>)([a-zA-Z0-9]|-|\/|\s|\(|\)|\_)+(?=<\/Name>)','match')),linecells);
  % ----------------- Uni Names -------------------
  % allNameCells = cellfun(@(CELLSTR) char(regexp(CELLSTR,'(?<=<Name>)([a-zA-Z0-9]|-|\/|\s|\(|\)|\_)+(?=<\/Name>)','match')),linecells(indexNamesAll),'UniformOutput',false);
  % [uniNames, idxUniNames, idxAllNames] = unique(allNameCells,'stable');
  % idxAllNameNums = linenums(indexNamesAll);
  % Find <Name>PMT 11</Name>
  % indexNamesPmtEmpty = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Name>)(PMT\s[0-9]+)(?=<\/Name>)','match')),linecells);
  % linecells(indexNamesPmtEmpty); %
  % Find <Name>All Events</Name>
  % indexNamesAllEvents = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<Name>)(All\sEvents)(?=<\/Name>)','match')),linecells);
  % linecells(indexNamesAllEvents); %
% ----------------- Pmt Power -------------------
% indexPmtPower = cellfun(@(CELLSTR) ~isempty(regexp(CELLSTR,'(?<=<PmtPower>)(true)(?=<\/PmtPower>)','match')),linecells);
% idxPmtPowerNums = linenums(indexPmtPower);
  % pmtPowerVec = cellfun(@(CELLSTR) strcmpi(char(regexp(CELLSTR,'(?<=<PmtPower>)([a-zA-Z0-9])*(?=<\/PmtPower>)','match')),'true'),linecells(indexPmtPower),'UniformOutput',true);
  % idxvec = [idxvec; idxPmtPowerNums];
  % idxvec = sort(unique(idxvec,'stable'),'ascend');



% -----------------  -------------------
