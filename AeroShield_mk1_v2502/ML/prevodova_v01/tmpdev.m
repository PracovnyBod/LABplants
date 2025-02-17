




opts = detectImportOptions("./dataRepo/dataFile_2024_11_02_16_34_38_mer1.txt");

dataRepoData = readtable("./dataRepo/dataFile_2024_11_02_16_34_38_mer1.txt", opts);




raw_time = dataRepoData{:, 1};
raw_sig_in = dataRepoData{:, 5};
raw_sig_out = dataRepoData{:, 4};


figure(31);

subplot(2, 1, 1);
stairs(raw_time, raw_sig_out, '-k');
xlabel('Time [s]');
ylabel('Output [deg]');
% hold on
% plot(raw_time, raw_sig_out, '.k');
% hold off

subplot(2, 1, 2);
stairs(raw_time, raw_sig_in, '-k');
xlabel('Time [s]');
ylabel('Input [%]');
% plot(raw_time, raw_sig_in, '.k');






tmpdiffidx = find(diff(raw_sig_in));
tmpdiffidx = [tmpdiffidx; length(raw_sig_in)];

ssTinterval = 5;

prevodova = [];

for i = 1:length(tmpdiffidx);
    tmpidx = tmpdiffidx(i);

    tmptime_e = raw_time(tmpidx);
    tmptime_b = tmptime_e - ssTinterval;

    tmpmask = (raw_time >= tmptime_b) & (raw_time <= tmptime_e);

    prevodova(i, 1) = mean(raw_sig_in(tmpmask));
    prevodova(i, 2) = mean(raw_sig_out(tmpmask));

    figure(31);
    subplot(2, 1, 1);
    hold on;
    plot(raw_time(tmpmask), raw_sig_out(tmpmask), '.r');
    hold off;
    subplot(2, 1, 2);
    hold on;
    plot(raw_time(tmpmask), raw_sig_in(tmpmask), '.r');
    hold off;


end


figure(32);

plot(prevodova(:, 1), prevodova(:, 2), 'ok');

prevodova



% 

