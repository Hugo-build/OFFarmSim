function relativePath = getRelativePath(filePath, parentFolderPath)
    % Ensure both paths are absolute and consistent
    filePath = fullfile(fileparts(parentFolderPath), filePath);
    parentFolderPath = fullfile(fileparts(parentFolderPath), parentFolderPath);
    
    % Check if the parent folder path is actually a prefix of the file path
    if strncmp(filePath, parentFolderPath, length(parentFolderPath))
        % Get the relative path by removing the parent folder path
        relativePath = strrep(filePath, parentFolderPath, '');
        
        % Remove the leading file separator if it exists
        if startsWith(relativePath, filesep)
            relativePath = relativePath(length(filesep) + 1:end);
        end
    else
        error('The file is not located within the specified parent folder.');
    end
end