
clear all










% Define serial port parameters
serPort = serial('COM4', 'BaudRate', 115200, 'Timeout', 5);

% Open the serial port
fopen(serPort);

% Read the first line from the serial port
serLine = fgets(serPort);
disp(serLine);

% Set initial control input value
u_send = 0;
u_send_string = num2str(u_send);


% ----------------------------------
% ----------------------------------

% Define time parameters

T_start = 0;

T_sample =    0.035;      % [sec]

T_stop =      10.0;      % [sec]


% ----------------------------------
% ----------------------------------



% Data save

DateString = convertCharsToStrings(datestr(datetime('now'), "yyyy_mm_dd_HH_MM_ss"))

datafileID = fopen("./dataRepo/" + "dataFile_" + DateString +".txt",'w');

% ----------------------------------
% ----------------------------------




% Get the initial time
time_start = datetime('now');
time_tick = time_start;


% Main loop
while true
    % Get current time
    time_curr = datetime('now');
    
    % Calculate time elapsed since last iteration
    time_delta = milliseconds(time_curr - time_tick);

    


    
    % Check if it's time to send a new command
    if (time_delta >= T_sample * 1000)
        time_tick = time_curr;
        
        % Calculate total time elapsed
        time_elapsed = seconds(time_curr - time_start);
        
        % Send control input to the serial port
        fprintf(serPort, '%s\n', u_send_string);
        
        % Read and parse the received data
        serLineList = str2num(fgets(serPort)); %#ok<ST2NM>
        
        % Extract values from the received data
        plant_time = serLineList(1);
        plant_potentiometer = serLineList(2);
        plant_output = serLineList(3);
        plant_input = serLineList(4);
        
        % Display the received data
        tmp_printlist = [time_elapsed, plant_time, plant_potentiometer, plant_output, plant_input, time_delta];
        if ((time_delta/1000) > (T_sample*1.05))
            fprintf(2,'%8.3f %6d %8.3f %8.3f %6d %8.3f\n', tmp_printlist);
        else
            fprintf('%8.3f %6d %8.3f %8.3f %6d %8.3f\n', tmp_printlist);
        end

        fprintf(datafileID, '%8.3f, %6d, %8.3f %8.3f, %6d, %8.3f\n', tmp_printlist);


        % ----------------------------------
        % ----------------------------------
        
   

        % ----------------------------------
        % ----------------------------------
 
 
        u = plant_potentiometer;
        u = round(u);

        % ----------------------------------
        % ----------------------------------

        u_send = u;

        if u_send > 100
            u_send = 100;
        end
        if u_send < 0
            u_send = 0;
        end        

        u_send_string = num2str(u_send);
        
        % Check if the simulation should stop
        if time_elapsed >= T_stop
            break;
        end
    end
end





% Send a final command and close the serial port
fprintf(serPort, '0\n');
fclose(serPort);

fclose(datafileID);



