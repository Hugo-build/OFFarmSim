function allFiles = findAllFiles(folder)
    % Initialize cell array to hold file names
    allFiles = {};

    % Get list of all files and folders in the specified directory
    filesAndFolders = dir(folder);
    % Remove the '.' and '..' entries
    filesAndFolders(ismember({filesAndFolders.name}, {'.', '..'})) = [];

    % Loop through each item in the directory
    for k = 1:length(filesAndFolders)
        % Get the full path of the item
        fullPath = fullfile(folder, filesAndFolders(k).name);
        
        % If the item is a directory, recursively call the function
        if filesAndFolders(k).isdir
            % Get files in the subdirectory
            subFiles = findAllFiles(fullPath);
            % Append them to the list
            allFiles = [allFiles; subFiles];
        else
            % If the item is a file, add it to the list
            allFiles = [allFiles; {fullPath}];
        end
    end
end