
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

T_sample =    0.050;      % [sec]

T_stop =      30.0;      % [sec]


% ----------------------------------
% ----------------------------------

% Plot

plot_window = 20;
plot_idx_num = floor(plot_window/T_sample);

plot_t = nan(plot_idx_num,1);
plot_sig_1 = nan(plot_idx_num,1);
plot_sig_2 = nan(plot_idx_num,1);
plot_sig_3 = nan(plot_idx_num,1);

figure(666);
clf;

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
        serLineList = str2num(fgets(serPort));
        
        % Extract values from the received data
        plant_time = serLineList(1);
        plant_potentiometer = serLineList(2);
        plant_output = serLineList(3);
        plant_input = serLineList(4);
        
        % Display the received data
        tmp_printlist = [time_elapsed, plant_time, plant_potentiometer, plant_output, plant_input, time_delta];
        if ((time_delta/1000) > (T_sample*1.05))
            fprintf(2,'%8.3f | %6d %8.3f %8.3f %8.3f %8.3f\n', tmp_printlist);
        else
            fprintf('%8.3f | %6d %8.3f %8.3f %8.3f %8.3f\n', tmp_printlist);
        end

        fprintf(datafileID, '%8.3f, %6d, %8.3f %8.3f, %6d, %8.3f\n', tmp_printlist);


        % ----------------------------------
        % ----------------------------------
        
        plot_t = circshift(plot_t, -1);
        plot_t(end) = time_elapsed;

        plot_sig_1 = circshift(plot_sig_1, -1);
        plot_sig_1(end) = plant_output;

        plot_sig_2 = circshift(plot_sig_2, -1);
        plot_sig_2(end) = plant_potentiometer;

        plot_sig_3 = circshift(plot_sig_3, -1);
        plot_sig_3(end) = plant_input;

        plot(plot_t, plot_sig_3,'.b', plot_t, plot_sig_2,'.r', plot_t, plot_sig_1,'.-k' )
        xlim([min(plot_t), max(plot_t)+T_sample])
%         ylim([-127, 1023]);
        grid on;

        drawnow nocallbacks    


        % ----------------------------------
        % ----------------------------------
 
 
        u = plant_potentiometer;
        % u = round(u);

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
        
        % Check if the program should stop
        if time_elapsed >= T_stop
            break;
        end
    end
end





% Send a final command and close the serial port
fprintf(serPort, '0\n');
fclose(serPort);

fclose(datafileID);





% Load data from the saved file
data = load("./dataRepo/" + "dataFile_" + DateString + ".txt");

% Extract columns from the loaded data
time_elapsed = data(:, 1);
plant_time = data(:, 2);
plant_potentiometer = data(:, 3);
plant_output = data(:, 4);
plant_input = data(:, 5);
time_delta = data(:, 6);

% Plot the loaded data
figure(667);
subplot(3, 1, 1);
plot(time_elapsed, plant_output, '.-k');
title('Plant Output');
xlabel('Time Elapsed [s]');
ylabel('Output');
grid on;

subplot(3, 1, 2);
plot(time_elapsed, plant_potentiometer, '-r');
title('Plant Potentiometer');
xlabel('Time Elapsed [s]');
ylabel('Potentiometer');
grid on;

subplot(3, 1, 3);
plot(time_elapsed, plant_input, '-b');
title('Plant Input');
xlabel('Time Elapsed [s]');
ylabel('Input');
grid on;
