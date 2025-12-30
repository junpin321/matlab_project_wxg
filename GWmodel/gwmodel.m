function popcons = gwmodel(pwell)
% Running groundwater model
% pwell: Decision Variables (Multipliers for the 7 Groups)
% pwell is a vector of length 7.

% Define Model Directory
ModelPath = 'modflow';
% Store current directory to return later
OriginalDir = pwd;

% Use try-catch to ensure we return to OriginalDir even if error occurs
try
    % Change to model directory
    cd(ModelPath);

    % Input File Name (relative to ModelPath)
    WEL_FILE = '2000.wel';
    NAME_FILE = '2000.mfn';
    HEAD_FILE = '2000.hed';
    EXE_NAME = 'mf2k_h5.exe';

    % Model Dimensions (from 2000.dis)
    NLAY = 6;
    NROW = 150;
    NCOL = 150;
    % Simulation Time (from 2000.dis)
    SIM_TIME = 2556.0;

    %% 1. Read and Modify 2000.wel
    % Read the entire file content
    file_content = fileread(WEL_FILE);
    lines = strsplit(file_content, '\n');
    new_lines = lines;

    % Identify data block
    % Typically between "BEGIN PERIOD 1" and "END PERIOD"
    start_idx = -1;
    end_idx = -1;

    for i = 1:length(lines)
        if contains(lines{i}, 'BEGIN PERIOD 1')
            start_idx = i + 1;
        elseif contains(lines{i}, 'END PERIOD') && start_idx ~= -1
            end_idx = i - 1;
            break;
        end
    end

    TotalPumping = 0.0;

    if start_idx ~= -1 && end_idx ~= -1
        for i = start_idx:end_idx
            line = lines{i};
            % Skip comments or empty lines
            if isempty(trim_string(line)) || startsWith(trim_string(line), '#')
                continue;
            end

            % Parse line: Layer Row Col Flux ... GroupID
            % We look for the last column as GroupID
            data = sscanf(line, '%f');
            if length(data) >= 7
                groupID = data(end);

                % Check if GroupID is valid (1-7)
                if groupID >= 1 && groupID <= 7
                    multiplier = pwell(groupID);
                    base_flux = data(4);

                    % Apply multiplier
                    new_flux = base_flux * multiplier;

                    % Update Total Pumping (Sum of absolute flux - assumed pumping is negative)
                    if new_flux < 0
                        TotalPumping = TotalPumping + abs(new_flux);
                    end

                    % Reconstruct the line
                    % Assuming 7 columns: L R C Flux IFACE QFACT CELLGRP
                    % Adjust formatting as needed.
                    if length(data) == 7
                         new_line = sprintf(' %5d %5d %5d %15.6f %5d %10.4f %5d', ...
                            data(1), data(2), data(3), new_flux, data(5), data(6), data(7));
                         new_lines{i} = new_line;
                    elseif length(data) > 4
                         % Generic reconstruction if column count varies
                         % Update the 4th element (Flux)
                         data(4) = new_flux;
                         fmt = repmat('%g ', 1, length(data));
                         new_lines{i} = sprintf(fmt, data);
                    end
                end
            end
        end
    end

    % Write back to 2000.wel
    fid = fopen(WEL_FILE, 'w');
    for i = 1:length(new_lines)
        fprintf(fid, '%s\n', new_lines{i});
    end
    fclose(fid);

    %% 2. Run MODFLOW
    if isunix
        % Assume Wine or Linux executable available, or just try to run the provided exe
        % command = ['wine ' EXE_NAME ' ' NAME_FILE];
        % For now, using ./ to attempt run (user provided .exe but might be linux executable renamed?)
        command = ['./' EXE_NAME ' ' NAME_FILE];
    else
        command = [EXE_NAME ' ' NAME_FILE];
    end

    % Execute
    % Using system() to run the model
    [status, cmdout] = system(command);

    %% 3. Post-Process
    popcons = [0, 0]; % [DryCellFlag, TotalPumping]

    % Check if Head file exists
    if exist(HEAD_FILE, 'file')
        try
            % Read Head File
            % gwmprocess arguments: ElapseTime, FNAME, nlay, ncol, nrow
            % We assume gwmprocess is in the path.
            heads = gwmprocess(SIM_TIME, HEAD_FILE, NLAY, NCOL, NROW);

            % Check for Dry Cells
            % Common dry values: -1e30, -999, or very small/large numbers
            dry_thresh = -1e20;
            dry_value_999 = -999.0;

            if any(heads(:) < dry_thresh) || any(heads(:) == dry_value_999)
                popcons(1) = 1;
            end

            % Total Pumping
            popcons(2) = TotalPumping;

        catch ME
            % If reading fails
            disp(['Error reading head file: ' ME.message]);
            popcons(1) = 1; % Penalize
            popcons(2) = 0;
        end
    else
        % Output file not found
        % disp('Head file not found.');
        popcons(1) = 1; % Penalize
        popcons(2) = 0;
    end

    % Return to original directory
    cd(OriginalDir);

catch ME
    cd(OriginalDir);
    rethrow(ME);
end

return
end

function s = trim_string(s)
    s = regexprep(s, '^\s+', '');
    s = regexprep(s, '\s+$', '');
end

function s = startsWith(str, pattern)
    s = strncmp(str, pattern, length(pattern));
end

function containsVal = contains(str, pattern)
    containsVal = ~isempty(strfind(str, pattern));
end
