function filePath = writeBinary(data, fileName)
    % Validate inputs
    if nargin < 2
        error('Not enough input arguments. Provide data and file name.');
    end

    % Get the full file path
    filePath = fullfile(pwd, fileName);

    % Open the file for writing in binary mode
    fileID = fopen(filePath, 'w');
    if fileID == -1
        error('Cannot open file for writing: %s', filePath);
    end

    % Write data to the file
    fwrite(fileID, data, 'double'); % Change 'double' to the appropriate data type if needed

    % Close the file
    fclose(fileID);

    % Display the file path (optional)
    fprintf('Data written to binary file: %s\n', filePath);
end