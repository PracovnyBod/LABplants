



datafile = "./dataRepo/dataFile__last.txt";




opts = detectImportOptions(datafile);

dataRepoData = readtable(datafile, opts);




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

prevodova_mean = [];
prevodova_var = [];

for i = 1:length(tmpdiffidx);
    tmpidx = tmpdiffidx(i);

    tmptime_e = raw_time(tmpidx);
    tmptime_b = tmptime_e - ssTinterval;

    tmpmask = (raw_time >= tmptime_b) & (raw_time <= tmptime_e);

    prevodova_mean(i, 1) = mean(raw_sig_in(tmpmask));
    prevodova_mean(i, 2) = mean(raw_sig_out(tmpmask));

    prevodova_var(i, 1) = var(raw_sig_out(tmpmask));

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

% plot(prevodova_mean(:, 1), prevodova_mean(:, 2), 'ok');

errorbar(prevodova_mean(:, 1), prevodova_mean(:, 2), prevodova_var(:, 1), 'ok');

% prevodova_var

