clc
clear all

numSteps = 100;
decelLimLCW = -200;
decelLimHCW = -150;
bestGain_lcw = NaN;
bestGain_hcw = NaN;
optimalFactor = 0.01;
initialSpeeds = randi([20, 60], 1, numSteps);
totalCollision = inf;

% Markov Chain
P = [0.6 0.4; 0.85 0.15];
mc = dtmc(P);
scenario = simulate(mc,numSteps); % 2 is HCW, 1 is LCW


%% User 3 Profile - LCW

user3_HR_LCW = 61;
user3_std_HR_LCW = 14;
user3_RR_LCW = 17;
user3_std_RR_LCW = 8;

HR_samples_LCW_user3 = normrnd(user3_HR_LCW, user3_std_HR_LCW, numSteps, 1);
RR_samples_LCW_user3 = normrnd(user3_RR_LCW, user3_std_RR_LCW, numSteps, 1);
Rq_LCW_user3 = HR_samples_LCW_user3 ./ RR_samples_LCW_user3;
tr_LCW_user3 = optimalFactor * Rq_LCW_user3;


%% User 3 Profile - HCW

user3_HR_HCW = 92;
user3_std_HR_HCW = 23; 
user3_RR_HCW = 26;
user3_std_RR_HCW = 16;

HR_samples_HCW_user3 = normrnd(user3_HR_HCW, user3_std_HR_HCW, numSteps, 1);
RR_samples_HCW_user3 = normrnd(user3_RR_HCW, user3_std_RR_HCW, numSteps, 1);
Rq_HCW_user3 = HR_samples_HCW_user3 ./ RR_samples_HCW_user3;
tr_HCW_user3 = optimalFactor * Rq_HCW_user3;

% Generating random samples for HR and RR for LCW (Normal Condition)
lcw_switch_counts = inf;
hcw_switch_counts = inf;


for gain = 10000:10000:200000
    [A,B,C,D,Kess, Kr, Ke, uD] = designControl(secureRand(),gain);
    open_system('LaneMaintainSystem.slx')
    load_system('HumanActionModel.slx');
    switchcount_lcw = 0;  % Reset LCW switch counter for each gain value
    switchcount_hcw = 0;  % Reset HCW switch counter for each gain value
    cur_collision = 0;
    for i = 1:100
        if scenario(i)==1
            speed = initialSpeeds(i);
            tr = tr_LCW_user3(i);
            set_param('LaneMaintainSystem/VehicleKinematics/Saturation', 'LowerLimit', num2str(decelLimLCW));
            set_param('LaneMaintainSystem/VehicleKinematics/vx', 'InitialCondition', num2str(speed));
            simModel = sim('LaneMaintainSystem.slx');

            lastDistance = simModel.sx1.Data(end);
            lastTime = simModel.sx1.Time(end);
            for t = 1:length(simModel.sx1.Time)
                distance = simModel.sx1.Data(t);
                if distance > 0
                    lastTime = simModel.sx1.Time(t);
                    break; % Exit the loop as soon as distance exceeds 0
                end
            end

            set_param('HumanActionModel/Step', 'Time', num2str(tr));
            set_param('HumanActionModel/Step', 'After', num2str(decelLimLCW*1.1));
            simModel_new_lcw = sim('HumanActionModel.slx');
            ta = simModel_new_lcw.sx1.Time(end);

            h_stop = ta + tr;
            disp("H stop for LCW is " + h_stop);

            if lastDistance >= 0
                if h_stop < lastTime
                    switchcount_lcw = switchcount_lcw + 1;
                    disp("No Collision. Switch Human")
                else
                    disp("Collision")
                    cur_collision = cur_collision+1;
                end
            else
                disp("No Collision.")
            end
        else
            speed = initialSpeeds(i);
            tr = tr_HCW_user3(i);
            set_param('LaneMaintainSystem/VehicleKinematics/Saturation', 'LowerLimit', num2str(decelLimHCW));
            set_param('LaneMaintainSystem/VehicleKinematics/vx', 'InitialCondition', num2str(speed));
            simModel = sim('LaneMaintainSystem.slx');

            lastDistance = simModel.sx1.Data(end);
            lastTime = simModel.sx1.Time(end);
            for t = 1:length(simModel.sx1.Time)
                distance = simModel.sx1.Data(t);
                if distance > 0
                    lastTime = simModel.sx1.Time(t);
                    break; % Exit the loop as soon as distance exceeds 0
                end
            end

            set_param('HumanActionModel/Step', 'Time', num2str(tr));
            set_param('HumanActionModel/Step', 'After', num2str(decelLimHCW*1.1));
            simModel_new_hcw = sim('HumanActionModel.slx');
            ta = simModel_new_hcw.sx1.Time(end);

            h_stop = ta + tr;
            disp("H stop for LCW is " + h_stop);

            if lastDistance >= 0
                if h_stop < lastTime
                    switchcount_hcw = switchcount_hcw + 1;
                    disp("No Collision. Switch Human")
                else
                    disp("Collision")
                    cur_collision = cur_collision+1;
                end
            else
                disp("No Collision.")
            end
       end
    end

    if switchcount_lcw<lcw_switch_counts
        lcw_switch_counts = switchcount_lcw;
        bestGain_lcw = gain;
    end

    if switchcount_hcw<hcw_switch_counts
        hcw_switch_counts = switchcount_hcw;
        bestGain_hcw = gain;
    end

    if cur_collision<totalCollision
        totalCollision = cur_collision;
    end
end

disp("LCW Gain = " + bestGain_lcw);
disp("HCW Gain = " + bestGain_hcw);
disp("Min Collision = " + totalCollision);
disp("Switch for LCW = " +  lcw_switch_counts);
disp("Switch for HCW = " +  hcw_switch_counts);

