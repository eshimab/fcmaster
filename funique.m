%
%
%
%
% Version 1.0.2

function fileId = funique(baseFilename)
    % Generate a unique filename for the compareXmlNodes output
    % baseFilename: Base name for the file, without extension

    % Construct the output directory path
    functionDir = fileparts(mfilename('fullpath'));
    outputDir = fullfile(functionDir, 'xmldifs');
    
    % Check if the directory exists, create it if it doesn't
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    % Construct the filename with timestamp for uniqueness
    uniqueFilename = [baseFilename '_' datestr(now, 'yyyymmdd_HHMMSS') '.txt'];

    % Construct the full path to the output file
    outputFileFullPath = fullfile(outputDir, uniqueFilename);

    % Open the file for writing and return the file ID
    fileId = fopen(outputFileFullPath, 'w');
    if fileId == -1
        error(['Failed to open file for writing: ', outputFileFullPath]);
    end
end

%
%
%
%
%
